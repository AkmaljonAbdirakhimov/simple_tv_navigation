import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/tv_focus_direction.dart';
import '../../domain/models/tv_focus_element.dart';

part 'tv_navigation_event.dart';
part 'tv_navigation_state.dart';

class TvNavigationBloc extends Bloc<TvNavigationEvent, TvNavigationState> {
  TvNavigationBloc() : super(const TvNavigationState()) {
    on<RegisterElement>(_onRegisterElement);
    on<UnregisterElement>(_onUnregisterElement);
    on<UpdateElement>(_onUpdateElement);
    on<SetFocus>(_onSetFocus);
    on<MoveFocus>(_onMoveFocus);
    on<Select>(_onSelect);
    on<SetEnabled>(_onSetEnabled);
    on<SetExcludeFocusEnabled>(_onSetExcludeFocusEnabled);
  }

  String? pendingFocusId;

  void _onRegisterElement(
    RegisterElement event,
    Emitter<TvNavigationState> emit,
  ) {
    if (!state.enabled) return;

    final element = event.element;
    final newElements = Map<String, TvFocusElement>.from(state.focusElements);

    if (!state.focusElements.containsKey(element.id)) {
      newElements[element.id] = element;

      TvFocusElement? newCurrentlyFocusedElement;
      if (pendingFocusId != null && element.id == pendingFocusId) {
        newCurrentlyFocusedElement = element;
        pendingFocusId = null;
      } else {
        newCurrentlyFocusedElement =
            element.autofocus || state.currentlyFocusedElement == null
                ? element
                : state.currentlyFocusedElement;
      }

      emit(state.copyWith(
        focusElements: newElements,
        currentlyFocusedElement: newCurrentlyFocusedElement,
      ));
    }
  }

  void _onUnregisterElement(
    UnregisterElement event,
    Emitter<TvNavigationState> emit,
  ) {
    // Don't process navigation events if the system is disabled
    if (!state.enabled) return;

    final newElements = Map<String, TvFocusElement>.from(state.focusElements);
    newElements.remove(event.id);

    // If we're removing the currently focused element, clear the focus
    final newCurrentlyFocusedElement =
        state.currentlyFocusedElement?.id == event.id
            ? (newElements.isNotEmpty ? newElements.values.first : null)
            : state.currentlyFocusedElement;

    emit(TvNavigationState(
      focusElements: newElements,
      currentlyFocusedElement: newCurrentlyFocusedElement,
    ));
  }

  void _onUpdateElement(
    UpdateElement event,
    Emitter<TvNavigationState> emit,
  ) {
    // Don't process navigation events if the system is disabled
    if (!state.enabled) return;

    final element = event.element;
    final newElements = Map<String, TvFocusElement>.from(state.focusElements);
    newElements[element.id] = element;

    emit(state.copyWith(
      focusElements: newElements,
    ));
  }

  void _onSetFocus(
    SetFocus event,
    Emitter<TvNavigationState> emit,
  ) {
    // Don't process navigation events if the system is disabled
    if (!state.enabled) return;

    if (state.focusElements.containsKey(event.id) &&
        state.currentlyFocusedElement?.id != event.id) {
      emit(
        state.copyWith(currentlyFocusedElement: state.focusElements[event.id]),
      );
    } else {
      pendingFocusId = event.id;
    }
  }

  void _onMoveFocus(
    MoveFocus event,
    Emitter<TvNavigationState> emit,
  ) {
    // Don't process navigation events if the system is disabled
    if (!state.enabled) return;

    final currentElement = state.currentlyFocusedElement;
    if (currentElement == null) return;

    String? newFocusId;

    switch (event.direction) {
      case TvFocusDirection.up:
        newFocusId = currentElement.dynamicUpId?.call() ?? currentElement.upId;
        break;
      case TvFocusDirection.down:
        newFocusId =
            currentElement.dynamicDownId?.call() ?? currentElement.downId;
        break;
      case TvFocusDirection.left:
        newFocusId =
            currentElement.dynamicLeftId?.call() ?? currentElement.leftId;
        break;
      case TvFocusDirection.right:
        newFocusId =
            currentElement.dynamicRightId?.call() ?? currentElement.rightId;
        break;
    }

    state.currentlyFocusedElement?.onNavigationRequest?.call(event.direction);

    if (newFocusId != null && state.focusElements.containsKey(newFocusId)) {
      state.currentlyFocusedElement?.onBlur?.call(event.direction);
      emit(
        state.copyWith(
            currentlyFocusedElement: state.focusElements[newFocusId]),
      );
      state.focusElements[newFocusId]?.onFocus?.call();
    }
  }

  void _onSelect(
    Select event,
    Emitter<TvNavigationState> emit,
  ) {
    // Don't process selection if the system is disabled
    if (!state.enabled) return;

    if (state.hasFocus) {
      // emit(state.copyWith());
      state.currentlyFocusedElement?.onSelect?.call();
    }
  }

  void _onSetEnabled(
    SetEnabled event,
    Emitter<TvNavigationState> emit,
  ) {
    emit(state.copyWith(enabled: event.enabled));
  }

  void _onSetExcludeFocusEnabled(
    SetExcludeFocusEnabled event,
    Emitter<TvNavigationState> emit,
  ) {
    if (!state.enabled) return;
    emit(state.copyWith(excludeFocus: event.enabled));
  }
}
