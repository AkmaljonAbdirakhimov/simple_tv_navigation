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
    Key? key,
    required this.child,
    this.customKeyHandlers,
    this.handleSelectAction = true,
    this.handleBackNavigation = true,
  }) : super(key: key);

  @override
  State<TVNavigationListener> createState() => _TVNavigationListenerState();
}

class _TVNavigationListenerState extends State<TVNavigationListener> {
  /// Focus node to capture key events
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle key events
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Only process key down events to avoid duplicates
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Check for custom key handlers first
    if (widget.customKeyHandlers != null &&
        widget.customKeyHandlers!.containsKey(event.logicalKey)) {
      widget.customKeyHandlers![event.logicalKey]!();
      return KeyEventResult.handled;
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
          return KeyEventResult.handled;

        case FocusDirection.select:
          if (widget.handleSelectAction) {
            bloc.add(const SelectFocused());
            return KeyEventResult.handled;
          }
          break;

        case FocusDirection.back:
          if (widget.handleBackNavigation) {
            bloc.add(const NavigateBack());
            return KeyEventResult.handled;
          }
          break;
      }
    }

    return KeyEventResult.ignored;
  }

  /// Map keyboard keys to navigation directions
  FocusDirection? _getNavigationDirection(LogicalKeyboardKey key) {
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
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
