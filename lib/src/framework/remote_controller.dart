import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../simple_tv_navigation.dart';

class RemoteController {
  static RemoteController? _instance;

  num swipeStartX = 0.0;
  num swipeStartY = 0.0;
  bool isMoving = false;
  static const gamePadChannelName = 'flutter/gamepadtouchevent';

  static const codec = JSONMessageCodec();

  static const channel =
      BasicMessageChannel<dynamic>(gamePadChannelName, codec);

  factory RemoteController() => _instance ?? RemoteController._();

  RemoteController._();

  void init() {
    channel.setMessageHandler(_onMessage);
    HardwareKeyboard.instance.addHandler(handleKeyMessage);
  }

  bool handleKeyMessage(KeyEvent message) {
    if (LogicalKeyboardKey.goBack == message.logicalKey &&
        message is KeyDownEvent) {
      final message = const JSONMethodCodec()
          .encodeMethodCall(const MethodCall('popRoute'));
      ServicesBinding.instance.channelBuffers
          .push(SystemChannels.navigation.name, message, (_) {});
      return true;
    }
    return false;
  }

  void triggerKey(LogicalKeyboardKey key) {
    // Map the logical key to an appropriate physical key
    PhysicalKeyboardKey physicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      physicalKey = PhysicalKeyboardKey.arrowLeft;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      physicalKey = PhysicalKeyboardKey.arrowRight;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      physicalKey = PhysicalKeyboardKey.arrowUp;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      physicalKey = PhysicalKeyboardKey.arrowDown;
    } else if (key == LogicalKeyboardKey.enter) {
      physicalKey = PhysicalKeyboardKey.enter;
    } else if (key == LogicalKeyboardKey.select) {
      physicalKey = PhysicalKeyboardKey.select;
    } else {
      physicalKey = PhysicalKeyboardKey.keyA; // Just a placeholder
    }

    final keyEvent = KeyDownEvent(
      physicalKey: physicalKey,
      logicalKey: key,
      timeStamp: Duration.zero,
    );

    // Let the TvNavigationProvider handle the key event
    // If there's no handler or it returns false, fall back to FocusManager
    if (!TvNavigationKeyHandler.handleKeyEvent(keyEvent)) {
      if (LogicalKeyboardKey.arrowLeft == key) {
        FocusManager.instance.primaryFocus!
            .focusInDirection(TraversalDirection.left);
      } else if (LogicalKeyboardKey.arrowRight == key) {
        FocusManager.instance.primaryFocus!
            .focusInDirection(TraversalDirection.right);
      } else if (LogicalKeyboardKey.arrowUp == key) {
        FocusManager.instance.primaryFocus!
            .focusInDirection(TraversalDirection.up);
      } else if (LogicalKeyboardKey.arrowDown == key) {
        FocusManager.instance.primaryFocus!
            .focusInDirection(TraversalDirection.down);
      }
    }
  }

  Future<void> _onMessage(dynamic arguments) async {
    num x = arguments['x'];
    num y = arguments['y'];
    String type = arguments['type'];
    late LogicalKeyboardKey key;

    if (type == 'started') {
      swipeStartX = x;
      swipeStartY = y;
      isMoving = true;
    } else if (type == 'move') {
      if (isMoving) {
        var moveX = swipeStartX - x;
        var moveY = swipeStartY - y;

        // need to move min distance in any direction
        // the 400px needs tweaking and might needs to be variable based on location of the widget on screen and duration/time of the movement to make it smoother
        if ((moveX.abs() >= 400) || (moveY.abs() >= 400)) {
          // determine direction horizontal or vertical
          if (moveX.abs() >= moveY.abs()) {
            if (moveX >= 0) {
              key = LogicalKeyboardKey.arrowLeft;
            } else {
              key = LogicalKeyboardKey.arrowRight;
            }
          } else {
            if (moveY >= 0) {
              key = LogicalKeyboardKey.arrowUp;
            } else {
              key = LogicalKeyboardKey.arrowDown;
            }
          }
          triggerKey(key);
          // reset start point (direction could change based on next cooordinates received)
          swipeStartX = x;
          swipeStartY = y;
        }
      }
    } else if (type == 'ended') {
      isMoving = false;
    } else if (type == 'cancelled') {
    } else if (type == 'loc') {
    } else if (type == 'click_s') {
      // Create a KeyDownEvent for enter key
      triggerKey(LogicalKeyboardKey.enter);
    } else if (type == 'click_e') {
      // We don't need to handle key up events in the TV navigation system
    }
  }
}
