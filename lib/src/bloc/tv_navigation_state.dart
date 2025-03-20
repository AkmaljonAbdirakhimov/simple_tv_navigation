part of 'tv_navigation_bloc.dart';

/// Represents the state of the TV navigation system
class TVNavigationState extends Equatable {
  /// Map of all registered focus elements by their ID
  final Map<String, FocusElement> elements;

  /// ID of the currently focused element (if any)
  final String? focusedElementId;

  /// ID of the currently selected element (if any)
  final String? selectedElementId;

  /// History of navigation events for tracking and back navigation
  final List<NavigationEvent> focusHistory;

  /// Performance metrics for optimization
  final Map<String, dynamic> metrics;

  /// Constructor
  const TVNavigationState({
    required this.elements,
    this.focusedElementId,
    this.selectedElementId,
    required this.focusHistory,
    this.metrics = const {},
  });

  /// Create an initial state for the navigation system
  factory TVNavigationState.initial({required String initialFocusId}) {
    return TVNavigationState(
      elements: {},
      focusedElementId: null,
      selectedElementId: null,
      focusHistory: [],
    );
  }

  /// Create a copy of this state with modified properties
  TVNavigationState copyWith({
    Map<String, FocusElement>? elements,
    String? focusedElementId,
    String? selectedElementId,
    List<NavigationEvent>? focusHistory,
    Map<String, dynamic>? metrics,
  }) {
    return TVNavigationState(
      elements: elements ?? this.elements,
      focusedElementId: focusedElementId ?? this.focusedElementId,
      selectedElementId: selectedElementId ?? this.selectedElementId,
      focusHistory: focusHistory ?? this.focusHistory,
      metrics: metrics ?? this.metrics,
    );
  }

  /// Get the currently focused element (if any)
  FocusElement? get focusedElement =>
      focusedElementId != null ? elements[focusedElementId] : null;

  /// Get the currently selected element (if any)
  FocusElement? get selectedElement =>
      selectedElementId != null ? elements[selectedElementId] : null;

  /// Check if the navigation system is empty (no registered elements)
  bool get isEmpty => elements.isEmpty;

  /// Check if the navigation system has any elements registered
  bool get isNotEmpty => elements.isNotEmpty;

  /// Get the number of registered elements
  int get size => elements.length;

  @override
  List<Object?> get props => [
        elements,
        focusedElementId,
        selectedElementId,
        focusHistory,
        metrics,
      ];
}
