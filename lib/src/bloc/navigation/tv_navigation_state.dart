part of 'tv_navigation_bloc.dart';

class TvNavigationState extends Equatable {
  final Map<String, TvFocusElement> focusElements;
  final TvFocusElement? currentlyFocusedElement;
  final bool enabled;
  final bool excludeFocus;

  const TvNavigationState({
    this.focusElements = const {},
    this.currentlyFocusedElement,
    this.enabled = true,
    this.excludeFocus = true,
  });

  TvNavigationState copyWith({
    Map<String, TvFocusElement>? focusElements,
    TvFocusElement? currentlyFocusedElement,
    bool? enabled,
    bool? excludeFocus,
  }) {
    return TvNavigationState(
      focusElements: focusElements ?? this.focusElements,
      currentlyFocusedElement:
          currentlyFocusedElement ?? this.currentlyFocusedElement,
      enabled: enabled ?? this.enabled,
      excludeFocus: excludeFocus ?? this.excludeFocus,
    );
  }

  bool get hasFocus => currentlyFocusedElement != null;
  bool isElementFocused(String id) => currentlyFocusedElement?.id == id;
  bool hasElement(String id) => focusElements[id] != null;

  @override
  List<Object?> get props => [
        focusElements,
        currentlyFocusedElement,
        enabled,
        excludeFocus,
      ];
}
