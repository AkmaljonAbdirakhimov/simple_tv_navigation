import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/tv_navigation_bloc.dart';
import 'models/focus_direction.dart';
import 'widgets/tv_navigation_listener.dart';

/// Provider widget that sets up the TV navigation system.
///
/// This widget should be placed high in the widget tree to provide the navigation system
/// to all descendant widgets.
class TVNavigationProvider extends StatelessWidget {
  /// The child widget that will use the TV navigation system
  final Widget child;

  /// ID of the element to focus initially
  final String? initialFocusId;

  /// Whether to automatically listen for key events
  final bool autoListen;

  /// Custom key handlers for the TVNavigationListener
  final Map<LogicalKeyboardKey, VoidCallback>? customKeyHandlers;

  /// Whether to handle select actions automatically
  final bool handleSelectAction;

  /// Whether to handle back navigation automatically
  final bool handleBackNavigation;

  /// Whether the TV navigation system is enabled
  /// When disabled, all navigation events are ignored
  /// and no focus styling is applied
  final bool enabled;

  /// Constructor
  const TVNavigationProvider({
    super.key,
    required this.child,
    this.initialFocusId,
    this.autoListen = true,
    this.customKeyHandlers,
    this.handleSelectAction = true,
    this.handleBackNavigation = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // If navigation is disabled, just return the child without the bloc
    if (!enabled) {
      return child;
    }

    return BlocProvider<TVNavigationBloc>(
      create: (context) => TVNavigationBloc(initialFocusId: initialFocusId),
      child: autoListen
          ? TVNavigationListener(
              customKeyHandlers: customKeyHandlers,
              handleSelectAction: handleSelectAction,
              handleBackNavigation: handleBackNavigation,
              child: child,
            )
          : child,
    );
  }
}

/// Extension methods for BuildContext to easily access the TV navigation bloc
extension TVNavigationContextExtension on BuildContext {
  /// Get the TVNavigationBloc from the current context
  TVNavigationBloc get tvNavigation => read<TVNavigationBloc>();

  /// Move focus in a specific direction
  void moveFocus(FocusDirection direction) {
    read<TVNavigationBloc>().add(MoveFocus(direction: direction));
  }

  /// Set focus to a specific element by ID
  void setFocus(String id) {
    read<TVNavigationBloc>().add(SetFocus(id: id));
  }

  /// Select the currently focused element
  void selectFocused({bool clearOtherSelections = true}) {
    read<TVNavigationBloc>().add(SelectFocused(
      clearOtherSelections: clearOtherSelections,
    ));
  }

  /// Clear selection from all elements
  void clearSelection() {
    read<TVNavigationBloc>().add(const ClearSelection());
  }

  /// Navigate back to the previous element
  void navigateBack() {
    read<TVNavigationBloc>().add(const NavigateBack());
  }

  /// Get the ID of the currently focused element
  String? get focusedElementId =>
      read<TVNavigationBloc>().state.focusedElementId;

  /// Get the ID of the currently selected element
  String? get selectedElementId =>
      read<TVNavigationBloc>().state.selectedElementId;

  /// Check if an element with the specified ID exists in the navigation system
  bool hasElement(String id) {
    try {
      final bloc = read<TVNavigationBloc>();
      return bloc.state.elements.containsKey(id) &&
          bloc.state.elements[id]!.isRegistered;
    } catch (e) {
      // Return false if TVNavigationBloc is not available
      return false;
    }
  }

  /// Attempt to restore the focus to the most recent element
  /// Useful after hot reloads or when navigating between screens
  void restoreFocus({String? id}) {
    try {
      read<TVNavigationBloc>().add(RestoreFocus(id: id));
    } catch (e) {
      // Silently fail if TVNavigationBloc is not available
    }
  }
}
