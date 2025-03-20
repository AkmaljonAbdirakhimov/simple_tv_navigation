import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tv_navigation_bloc.dart';
import '../models/focus_direction.dart';

/// A widget that listens for key events and translates them to TV navigation actions.
///
/// This widget should wrap the entire section of your UI that uses the TV navigation system.
/// It captures key events (arrow keys, enter, back, etc.) and converts them to the
/// appropriate navigation events.
class TVNavigationListener extends StatefulWidget {
  /// The child widget that contains navigable elements
  final Widget child;

  /// Optional callbacks for custom key handling
  final Map<LogicalKeyboardKey, VoidCallback>? customKeyHandlers;

  /// Whether to handle select actions automatically
  final bool handleSelectAction;

  /// Whether to handle back navigation automatically
  final bool handleBackNavigation;

  /// Constructor
  const TVNavigationListener({
    super.key,
    required this.child,
    this.customKeyHandlers,
    this.handleSelectAction = true,
    this.handleBackNavigation = true,
  });

  @override
  State<TVNavigationListener> createState() => _TVNavigationListenerState();
}

class _TVNavigationListenerState extends State<TVNavigationListener> {
  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  /// Handle key events
  bool _handleKeyEvent(KeyEvent event) {
    // Only process key down events to avoid duplicates
    if (event is! KeyDownEvent) {
      return false;
    }

    // Check for custom key handlers first
    if (widget.customKeyHandlers != null &&
        widget.customKeyHandlers!.containsKey(event.logicalKey)) {
      widget.customKeyHandlers![event.logicalKey]!();
      return true;
    }

    // Process standard navigation keys
    final navigationType = _getNavigationDirection(event.logicalKey);
    if (navigationType != null) {
      final bloc = context.read<TVNavigationBloc>();

      switch (navigationType) {
        case FocusDirection.left:
        case FocusDirection.right:
        case FocusDirection.up:
        case FocusDirection.down:
          bloc.add(MoveFocus(direction: navigationType));
          return true;

        case FocusDirection.select:
          if (widget.handleSelectAction) {
            bloc.add(const SelectFocused());
            return true;
          }
          break;

        case FocusDirection.back:
          if (widget.handleBackNavigation) {
            bloc.add(const NavigateBack());
            return true;
          }
          break;
      }
    }

    return false;
  }

  /// Map keyboard keys to navigation directions
  FocusDirection? _getNavigationDirection(LogicalKeyboardKey key) {
    // Standard keyboard and remote D-pad keys
    if (key == LogicalKeyboardKey.arrowLeft) {
      return FocusDirection.left;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      return FocusDirection.right;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      return FocusDirection.up;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      return FocusDirection.down;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      return FocusDirection.select;
    } else if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.browserBack ||
        key == LogicalKeyboardKey.goBack) {
      return FocusDirection.back;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
