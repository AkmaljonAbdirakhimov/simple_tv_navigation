import 'dart:async';

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

  /// Whether holding a key repeats the action it triggers.
  ///
  /// Disable this to restore the legacy one-press-per-key behavior.
  final bool enableHoldToRepeat;

  /// How long an arrow key must be held before it starts repeating.
  final Duration holdToRepeatDelay;

  /// Interval between repeats once [holdToRepeatDelay] has elapsed.
  final Duration holdToRepeatInterval;

  /// How long the select key must be held before [TVFocusable.onLongPress]
  /// starts repeating.
  final Duration longPressThreshold;

  const TvNavigationProvider({
    super.key,
    required this.child,
    this.enabled = true,
    this.enableHoldToRepeat = true,
    this.holdToRepeatDelay = const Duration(milliseconds: 450),
    this.holdToRepeatInterval = const Duration(milliseconds: 90),
    this.longPressThreshold = const Duration(milliseconds: 450),
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
        enableHoldToRepeat: enableHoldToRepeat,
        holdToRepeatDelay: holdToRepeatDelay,
        holdToRepeatInterval: holdToRepeatInterval,
        longPressThreshold: longPressThreshold,
        child: child,
      ),
    );
  }
}

class _TvNavigationBlocBuilder extends StatefulWidget {
  final Widget child;
  final bool enableHoldToRepeat;
  final Duration holdToRepeatDelay;
  final Duration holdToRepeatInterval;
  final Duration longPressThreshold;

  const _TvNavigationBlocBuilder({
    required this.child,
    required this.enableHoldToRepeat,
    required this.holdToRepeatDelay,
    required this.holdToRepeatInterval,
    required this.longPressThreshold,
  });

  @override
  State<_TvNavigationBlocBuilder> createState() =>
      _TvNavigationBlocBuilderState();
}

class _TvNavigationBlocBuilderState extends State<_TvNavigationBlocBuilder> {
  late final TvNavigationBloc _navigationBloc;
  final remoteController = RemoteController();
  Timer? _holdTimer;

  /// Keys this widget owns end to end, including the release that ends a hold.
  static bool _isHoldableKey(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
        return true;
      default:
        return false;
    }
  }

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

  /// Runs [action] once after [delay], then every [holdToRepeatInterval].
  ///
  /// The bloc is used instead of the context because the callback outlives the
  /// synchronous key handler and must stay safe across frames.
  void _startHold(VoidCallback action, Duration delay) {
    _cancelHold();
    if (!widget.enableHoldToRepeat) return;

    _holdTimer = Timer(delay, () {
      _runHoldAction(action);
      _holdTimer = Timer.periodic(
        widget.holdToRepeatInterval,
        (_) => _runHoldAction(action),
      );
    });
  }

  void _runHoldAction(VoidCallback action) {
    if (!mounted || !_navigationBloc.state.enabled) {
      _cancelHold();
      return;
    }
    action();
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  /// Moves focus once, then keeps moving in [direction] while held.
  void _moveAndHold(TvFocusDirection direction) {
    context.moveFocus(direction);
    _startHold(
      () => _navigationBloc.add(MoveFocus(direction)),
      widget.holdToRepeatDelay,
    );
  }

  // Handle key events
  bool _handleKeyEvent(KeyEvent event) {
    // If TV navigation is disabled, don't handle any keys
    if (!_navigationBloc.state.enabled) {
      _cancelHold();
      return false;
    }

    // Swallow repeats generated by the platform so a single held key produces
    // one predictable rate owned by [_startHold] instead of stacking on top of
    // an OS-defined one.
    if (event is KeyRepeatEvent) {
      return _isHoldableKey(event.logicalKey);
    }

    // Releasing the key ends any in-flight hold.
    if (event is KeyUpEvent) {
      _cancelHold();
      return _isHoldableKey(event.logicalKey);
    }

    // Only handle KeyDownEvent
    if (event is! KeyDownEvent) return false;

    bool handled = false;

    try {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _moveAndHold(TvFocusDirection.left);
          handled = true;
          break;
        case LogicalKeyboardKey.arrowRight:
          _moveAndHold(TvFocusDirection.right);
          handled = true;
          break;
        case LogicalKeyboardKey.arrowUp:
          _moveAndHold(TvFocusDirection.up);
          handled = true;
          break;
        case LogicalKeyboardKey.arrowDown:
          _moveAndHold(TvFocusDirection.down);
          handled = true;
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          // Read before selecting: without onLongPress the key stays a plain
          // on-press and never enters the repeat path.
          final repeatsOnHold =
              _navigationBloc.state.currentlyFocusedElement?.onLongPress !=
                  null;
          context.selectCurrent();
          if (repeatsOnHold) {
            // Re-read the element on every tick: the focused element can
            // change or unregister while the key is held.
            _startHold(
              () => _navigationBloc.state.currentlyFocusedElement?.onLongPress
                  ?.call(),
              widget.longPressThreshold,
            );
          }
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
    _cancelHold();
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
