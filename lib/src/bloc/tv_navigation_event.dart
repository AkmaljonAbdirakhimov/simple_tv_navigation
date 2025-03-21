part of 'tv_navigation_bloc.dart';

/// Base class for all TV navigation events
@immutable
abstract class TVNavigationEvent extends Equatable {
  const TVNavigationEvent();

  @override
  List<Object?> get props => [];
}

/// Register a new focusable element
class RegisterElement extends TVNavigationEvent {
  /// The element to register
  final FocusElement element;

  /// Whether to automatically focus this element if it's the first one registered
  final bool focusImmediately;

  /// Constructor
  const RegisterElement({
    required this.element,
    this.focusImmediately = true,
  });

  @override
  List<Object?> get props => [element, focusImmediately];
}

/// Unregister a focusable element
class UnregisterElement extends TVNavigationEvent {
  /// The ID of the element to unregister
  final String id;

  /// Constructor
  const UnregisterElement({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Move focus in a specific direction
class MoveFocus extends TVNavigationEvent {
  /// The direction to move focus
  final FocusDirection direction;

  /// Whether to use automatic fallback if no explicit neighbor is defined
  final bool useAutoFallback;

  /// Constructor
  const MoveFocus({
    required this.direction,
    this.useAutoFallback = true,
  });

  @override
  List<Object?> get props => [direction, useAutoFallback];
}

/// Set focus directly to a specific element
class SetFocus extends TVNavigationEvent {
  /// The ID of the element to focus
  final String id;

  /// Constructor
  const SetFocus({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Select the currently focused element
class SelectFocused extends TVNavigationEvent {
  /// Whether to clear any other selections first
  final bool clearOtherSelections;

  /// Constructor
  const SelectFocused({this.clearOtherSelections = true});

  @override
  List<Object?> get props => [clearOtherSelections];
}

/// Clear selection from all elements
class ClearSelection extends TVNavigationEvent {
  /// Constructor
  const ClearSelection();
}

/// Navigate back to the previous element
class NavigateBack extends TVNavigationEvent {
  /// Constructor
  const NavigateBack();
}

/// Reset the navigation system to its initial state
class ResetNavigation extends TVNavigationEvent {
  /// The ID of the element to focus initially after reset
  final String? initialFocusId;

  /// Constructor
  const ResetNavigation({this.initialFocusId});

  @override
  List<Object?> get props => [initialFocusId];
}

/// Update the render metrics for an element
class UpdateElementMetrics extends TVNavigationEvent {
  /// The ID of the element to update
  final String id;

  /// The key to use for the element
  final GlobalKey? key;

  /// The render box of the element
  final RenderBox? renderBox;

  /// Constructor
  const UpdateElementMetrics({
    required this.id,
    this.key,
    this.renderBox,
  });

  @override
  List<Object?> get props => [id, key, renderBox];
}

/// Restore focus to the last focused element
class RestoreFocus extends TVNavigationEvent {
  /// ID to restore focus to, if null it will attempt to restore the last known focus
  final String? id;

  /// Constructor
  const RestoreFocus({this.id});

  @override
  List<Object?> get props => [id];
}
