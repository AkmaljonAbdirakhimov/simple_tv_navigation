import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_tv_navigation/src/framework/platform.dart';
import 'package:simple_tv_navigation/src/framework/remote_controller.dart';

import '../../../simple_tv_navigation.dart';

/// Static class to handle key events from RemoteController
class TvNavigationKeyHandler {
  static _TvNavigationBlocBuilderState? _activeHandler;

  /// Register the active navigation handler
  static void registerHandler(_TvNavigationBlocBuilderState handler) {
    _activeHandler = handler;
  }

  /// Unregister the active navigation handler
  static void unregisterHandler(_TvNavigationBlocBuilderState handler) {
    if (_activeHandler == handler) {
      _activeHandler = null;
    }
  }

  /// Handle key events and delegate to the active handler
  static bool handleKeyEvent(KeyEvent event) {
    if (_activeHandler != null) {
      return _activeHandler!._handleKeyEvent(event);
    }
    return false;
  }
}

class TvNavigationProvider extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const TvNavigationProvider({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = TvNavigationBloc();
        // If not enabled, immediately disable the navigation system
        if (!enabled) {
          bloc.add(const SetEnabled(false));
        }
        return bloc;
      },
      child: _TvNavigationBlocBuilder(
        child: child,
      ),
    );
  }
}

class _TvNavigationBlocBuilder extends StatefulWidget {
  final Widget child;
  const _TvNavigationBlocBuilder({
    required this.child,
  });

  @override
  State<_TvNavigationBlocBuilder> createState() =>
      _TvNavigationBlocBuilderState();
}

class _TvNavigationBlocBuilderState extends State<_TvNavigationBlocBuilder> {
  late final TvNavigationBloc _navigationBloc;
  final remoteController = RemoteController();

  @override
  void initState() {
    super.initState();
    _navigationBloc = context.tvBloc;
    ServicesBinding.instance.keyboard.addHandler(_handleKeyEvent);
    TvNavigationKeyHandler.registerHandler(this);

    if (MyPlatform.isTVOS) {
      remoteController.init();
    }
  }

  // Handle key events
  bool _handleKeyEvent(KeyEvent event) {
    // If TV navigation is disabled, don't handle any keys
    if (!_navigationBloc.state.enabled) return false;

    // Only handle KeyDownEvent
    if (event is! KeyDownEvent) return false;

    bool handled = false;

    try {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          context.moveFocus(TvFocusDirection.left);
          handled = true;
          break;
        case LogicalKeyboardKey.arrowRight:
          context.moveFocus(TvFocusDirection.right);
          handled = true;
          break;
        case LogicalKeyboardKey.arrowUp:
          context.moveFocus(TvFocusDirection.up);
          handled = true;
          break;
        case LogicalKeyboardKey.arrowDown:
          context.moveFocus(TvFocusDirection.down);
          handled = true;
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          context.selectCurrent();
          handled = true;
          break;
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.browserBack:
          handled = true;
          break;
        default:
          handled = false;
      }
    } catch (e) {
      debugPrint('Error handling key event: $e');
      handled = false;
    }

    return handled;
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyEvent);
    TvNavigationKeyHandler.unregisterHandler(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TvNavigationBloc, TvNavigationState, bool>(
      selector: (state) => state.excludeFocus && state.enabled,
      builder: (context, excludeFocus) {
        return ExcludeFocus(
          excluding: excludeFocus,
          child: widget.child,
        );
      },
    );
  }
}
