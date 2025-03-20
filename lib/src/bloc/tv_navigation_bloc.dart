import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import '../models/focus_direction.dart';
import '../models/focus_element.dart';
import '../models/navigation_event.dart';

part 'tv_navigation_event.dart';
part 'tv_navigation_state.dart';

/// The main Bloc for managing TV navigation focus state and operations
class TVNavigationBloc extends Bloc<TVNavigationEvent, TVNavigationState> {
  /// Maximum events to store in the navigation history
  static const int _maxHistorySize = 100;

  /// Default initial focus ID
  static const String _defaultInitialFocusId = 'default_initial_focus';

  /// Constructor
  TVNavigationBloc({String? initialFocusId})
      : super(TVNavigationState.initial(
            initialFocusId: initialFocusId ?? _defaultInitialFocusId)) {
    on<RegisterElement>(_onRegisterElement);
    on<UnregisterElement>(_onUnregisterElement);
    on<MoveFocus>(_onMoveFocus);
    on<SetFocus>(_onSetFocus);
    on<SelectFocused>(_onSelectFocused);
    on<ClearSelection>(_onClearSelection);
    on<NavigateBack>(_onNavigateBack);
    on<ResetNavigation>(_onResetNavigation);
    on<UpdateElementMetrics>(_onUpdateElementMetrics);
  }

  /// Register a new focusable element
  FutureOr<void> _onRegisterElement(
    RegisterElement event,
    Emitter<TVNavigationState> emit,
  ) {
    final existingElement = state.elements[event.element.id];

    // If the element already exists, update it, preserving its focus state
    final updatedElement = event.element.copyWith(
      isFocused: existingElement?.isFocused ?? false,
      isSelected: existingElement?.isSelected ?? false,
      lastFocusedTime: existingElement?.lastFocusedTime,
      isRegistered: true,
    );

    final updatedElements = Map<String, FocusElement>.from(state.elements);
    updatedElements[event.element.id] = updatedElement;

    emit(state.copyWith(elements: updatedElements));

    // If this is the first registered element and no focused element exists yet,
    // focus it automatically if specified
    if (state.focusedElementId == null &&
        state.elements.length == 1 &&
        event.focusImmediately) {
      add(SetFocus(id: event.element.id));
    }
  }

  /// Unregister a focusable element
  FutureOr<void> _onUnregisterElement(
    UnregisterElement event,
    Emitter<TVNavigationState> emit,
  ) {
    final updatedElements = Map<String, FocusElement>.from(state.elements);
    final element = updatedElements[event.id];

    if (element != null) {
      // If we're removing the currently focused element, we need to handle focus transfer
      if (element.isFocused) {
        // Try to find a suitable element to focus instead
        final nextFocusableId =
            _findNextFocusableElement(element, updatedElements);

        if (nextFocusableId != null) {
          // First unregister the current element
          updatedElements[event.id] = element.unregister();

          emit(state.copyWith(
            elements: updatedElements,
            focusedElementId: nextFocusableId,
          ));

          // Then focus the next element (separate state update to ensure proper event sequence)
          add(SetFocus(id: nextFocusableId));
          return null;
        }
      }

      // Standard unregister without focus transfer
      updatedElements[event.id] = element.unregister();

      emit(state.copyWith(
        elements: updatedElements,
        focusedElementId: element.isFocused ? null : state.focusedElementId,
      ));
    }
  }

  /// Find the next focusable element when the current one is removed
  String? _findNextFocusableElement(
    FocusElement currentElement,
    Map<String, FocusElement> elements,
  ) {
    // Try the most recently focused element first
    if (state.focusHistory.isNotEmpty) {
      for (final event in state.focusHistory.reversed) {
        if (event.targetId != currentElement.id &&
            elements.containsKey(event.targetId) &&
            elements[event.targetId]!.isRegistered) {
          return event.targetId;
        }
      }
    }

    // Try to find any neighboring element that's still registered
    final neighborIds = [
      currentElement.rightId,
      currentElement.leftId,
      currentElement.downId,
      currentElement.upId,
    ].where((id) => id != null).toList();

    for (final id in neighborIds) {
      if (elements.containsKey(id) && elements[id]!.isRegistered) {
        return id;
      }
    }

    // If all else fails, find any registered element
    for (final element in elements.values) {
      if (element.id != currentElement.id && element.isRegistered) {
        return element.id;
      }
    }

    // No suitable element found
    return null;
  }

  /// Move focus in a specified direction
  FutureOr<void> _onMoveFocus(
    MoveFocus event,
    Emitter<TVNavigationState> emit,
  ) {
    // If there's no current focus, we can't move
    if (state.focusedElementId == null) return null;

    final currentElement = state.elements[state.focusedElementId!];
    if (currentElement == null) return null;

    String? targetId;

    // Determine the target ID based on the direction
    switch (event.direction) {
      case FocusDirection.left:
        targetId = currentElement.leftId;
        break;
      case FocusDirection.right:
        targetId = currentElement.rightId;
        break;
      case FocusDirection.up:
        targetId = currentElement.upId;
        break;
      case FocusDirection.down:
        targetId = currentElement.downId;
        break;
      default:
        // Other directions like select or back are not relevant here
        return null;
    }

    // If no target is specified for this direction, try to find one automatically
    if (targetId == null && event.useAutoFallback) {
      targetId = _findSpatialNeighbor(currentElement, event.direction);
    }

    // If we found a target, move focus to it
    if (targetId != null && state.elements.containsKey(targetId)) {
      final updatedHistory = _recordNavigationEvent(
        sourceId: currentElement.id,
        targetId: targetId,
        direction: event.direction,
        successful: true,
      );

      emit(state.copyWith(focusHistory: updatedHistory));
      add(SetFocus(id: targetId));
    } else {
      // Navigation failed - no target element found
      final updatedHistory = _recordNavigationEvent(
        sourceId: currentElement.id,
        targetId: null,
        direction: event.direction,
        successful: false,
      );

      emit(state.copyWith(focusHistory: updatedHistory));
    }
  }

  /// Find a neighbor in the specified direction using spatial information
  String? _findSpatialNeighbor(FocusElement element, FocusDirection direction) {
    if (element.renderBox == null || !element.renderBox!.attached) return null;

    // Get the render box and position of the current element
    final currentBox = element.renderBox!;
    final currentRect = currentBox.localToGlobal(
          currentBox.paintBounds.topLeft,
        ) &
        currentBox.size;

    String? bestElementId;
    double bestDistance = double.infinity;

    // Check all registered elements to find the closest one in the requested direction
    for (final candidateElement in state.elements.values) {
      if (!candidateElement.isRegistered ||
          candidateElement.id == element.id ||
          candidateElement.renderBox == null ||
          !candidateElement.renderBox!.attached) {
        continue;
      }

      final candidateBox = candidateElement.renderBox!;
      final candidateRect = candidateBox.localToGlobal(
            candidateBox.paintBounds.topLeft,
          ) &
          candidateBox.size;

      // Check if the candidate is in the right direction
      bool isCorrectDirection = false;
      switch (direction) {
        case FocusDirection.left:
          isCorrectDirection = candidateRect.right <= currentRect.left;
          break;
        case FocusDirection.right:
          isCorrectDirection = candidateRect.left >= currentRect.right;
          break;
        case FocusDirection.up:
          isCorrectDirection = candidateRect.bottom <= currentRect.top;
          break;
        case FocusDirection.down:
          isCorrectDirection = candidateRect.top >= currentRect.bottom;
          break;
        default:
          return null;
      }

      if (!isCorrectDirection) continue;

      // Calculate distance between the centers
      final currentCenter = currentRect.center;
      final candidateCenter = candidateRect.center;

      // Calculate Manhattan distance, but weight the primary direction more heavily
      double distance;
      switch (direction) {
        case FocusDirection.left:
        case FocusDirection.right:
          // For left/right navigation, prioritize horizontal alignment
          distance = (currentCenter.dx - candidateCenter.dx).abs() * 2 +
              (currentCenter.dy - candidateCenter.dy).abs();
          break;
        case FocusDirection.up:
        case FocusDirection.down:
          // For up/down navigation, prioritize vertical alignment
          distance = (currentCenter.dx - candidateCenter.dx).abs() +
              (currentCenter.dy - candidateCenter.dy).abs() * 2;
          break;
        default:
          continue;
      }

      if (distance < bestDistance) {
        bestDistance = distance;
        bestElementId = candidateElement.id;
      }
    }

    return bestElementId;
  }

  /// Set focus to a specific element by ID
  FutureOr<void> _onSetFocus(
    SetFocus event,
    Emitter<TVNavigationState> emit,
  ) {
    final targetElement = state.elements[event.id];

    // If the target element doesn't exist or isn't registered, do nothing
    if (targetElement == null || !targetElement.isRegistered) return null;

    // If it's already focused, do nothing
    if (targetElement.isFocused) return null;

    // First unfocus the currently focused element (if any)
    final updatedElements = Map<String, FocusElement>.from(state.elements);

    if (state.focusedElementId != null) {
      final currentElement = updatedElements[state.focusedElementId!];
      if (currentElement != null) {
        updatedElements[currentElement.id] = currentElement.unfocus();
      }
    }

    // Then focus the new element
    updatedElements[event.id] = targetElement.focus();

    // Record focus change in history if there was a previous focus
    if (state.focusedElementId != null) {
      final updatedHistory = _recordNavigationEvent(
        sourceId: state.focusedElementId!,
        targetId: event.id,
        direction: FocusDirection
            .select, // Using select as a placeholder for direct focus
        successful: true,
      );

      emit(state.copyWith(
        elements: updatedElements,
        focusedElementId: event.id,
        focusHistory: updatedHistory,
      ));
    } else {
      emit(state.copyWith(
        elements: updatedElements,
        focusedElementId: event.id,
      ));
    }
  }

  /// Select the currently focused element
  FutureOr<void> _onSelectFocused(
    SelectFocused event,
    Emitter<TVNavigationState> emit,
  ) {
    if (state.focusedElementId == null) return null;

    final focusedElement = state.elements[state.focusedElementId!];
    if (focusedElement == null) return null;

    final updatedElements = Map<String, FocusElement>.from(state.elements);

    // If requested to clear other selections first
    if (event.clearOtherSelections) {
      for (final elementId in updatedElements.keys) {
        final element = updatedElements[elementId]!;
        if (element.isSelected) {
          updatedElements[elementId] = element.unselect();
        }
      }
    }

    // Select the focused element
    updatedElements[focusedElement.id] = focusedElement.select();

    final updatedHistory = _recordNavigationEvent(
      sourceId: focusedElement.id,
      targetId: focusedElement.id,
      direction: FocusDirection.select,
      successful: true,
    );

    emit(state.copyWith(
      elements: updatedElements,
      selectedElementId: focusedElement.id,
      focusHistory: updatedHistory,
    ));
  }

  /// Clear selection from all elements
  FutureOr<void> _onClearSelection(
    ClearSelection event,
    Emitter<TVNavigationState> emit,
  ) {
    final updatedElements = Map<String, FocusElement>.from(state.elements);

    for (final elementId in updatedElements.keys) {
      final element = updatedElements[elementId]!;
      if (element.isSelected) {
        updatedElements[elementId] = element.unselect();
      }
    }

    emit(state.copyWith(
      elements: updatedElements,
      selectedElementId: null,
    ));
  }

  /// Navigate back by focusing the previous element
  FutureOr<void> _onNavigateBack(
    NavigateBack event,
    Emitter<TVNavigationState> emit,
  ) {
    // If the history is empty, nothing to do
    if (state.focusHistory.isEmpty) return null;

    // Find the most recent element that's still registered
    String? previousElementId;

    for (final historyEvent in state.focusHistory.reversed) {
      final sourceElement = state.elements[historyEvent.sourceId];

      if (sourceElement != null && sourceElement.isRegistered) {
        previousElementId = historyEvent.sourceId;
        break;
      }
    }

    if (previousElementId != null) {
      final updatedHistory = _recordNavigationEvent(
        sourceId: state.focusedElementId ?? 'unknown',
        targetId: previousElementId,
        direction: FocusDirection.back,
        successful: true,
      );

      emit(state.copyWith(focusHistory: updatedHistory));
      add(SetFocus(id: previousElementId));
    }
  }

  /// Reset the navigation system
  FutureOr<void> _onResetNavigation(
    ResetNavigation event,
    Emitter<TVNavigationState> emit,
  ) {
    emit(TVNavigationState.initial(
        initialFocusId: event.initialFocusId ?? _defaultInitialFocusId));
  }

  /// Update the render metrics for an element
  FutureOr<void> _onUpdateElementMetrics(
    UpdateElementMetrics event,
    Emitter<TVNavigationState> emit,
  ) {
    final element = state.elements[event.id];
    if (element == null) return null;

    final updatedElements = Map<String, FocusElement>.from(state.elements);
    updatedElements[event.id] = element.copyWith(
      elementKey: event.key ?? element.elementKey,
      renderBox: event.renderBox ?? element.renderBox,
    );

    emit(state.copyWith(elements: updatedElements));
  }

  /// Record a navigation event in the history
  List<NavigationEvent> _recordNavigationEvent({
    required String sourceId,
    required String? targetId,
    required FocusDirection direction,
    required bool successful,
  }) {
    final event = NavigationEvent(
      sourceId: sourceId,
      targetId: targetId,
      direction: direction,
      successful: successful,
    );

    // Create a new list with the event added to the end, keeping only the most recent items
    List<NavigationEvent> updatedHistory = [
      ...state.focusHistory,
      event,
    ];

    if (updatedHistory.length > _maxHistorySize) {
      updatedHistory = updatedHistory.sublist(
        updatedHistory.length - _maxHistorySize,
      );
    }

    return updatedHistory;
  }
}
