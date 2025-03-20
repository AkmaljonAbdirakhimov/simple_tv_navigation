import 'package:flutter/services.dart';
import '../models/focus_direction.dart';

/// Utility class for handling key events in TV interfaces
class KeyHandler {
  /// Convert a logical keyboard key to a focus direction
  static FocusDirection? keyToDirection(LogicalKeyboardKey key) {
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

  /// Map a gamepad button to a focus direction
  static FocusDirection? gamepadButtonToDirection(int buttonCode) {
    // These mappings are approximate and may need adjustment for specific gamepads
    switch (buttonCode) {
      case 14: // D-pad left
        return FocusDirection.left;
      case 15: // D-pad right
        return FocusDirection.right;
      case 12: // D-pad up
        return FocusDirection.up;
      case 13: // D-pad down
        return FocusDirection.down;
      case 0: // A button (Xbox) / X button (PlayStation)
        return FocusDirection.select;
      case 1: // B button (Xbox) / Circle button (PlayStation)
        return FocusDirection.back;
      default:
        return null;
    }
  }

  /// Check if a key is a navigation key
  static bool isNavigationKey(LogicalKeyboardKey key) {
    return keyToDirection(key) != null;
  }

  /// Get a human-readable name for a key
  static String getKeyName(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowLeft) {
      return 'Left Arrow';
    } else if (key == LogicalKeyboardKey.arrowRight) {
      return 'Right Arrow';
    } else if (key == LogicalKeyboardKey.arrowUp) {
      return 'Up Arrow';
    } else if (key == LogicalKeyboardKey.arrowDown) {
      return 'Down Arrow';
    } else if (key == LogicalKeyboardKey.enter) {
      return 'Enter';
    } else if (key == LogicalKeyboardKey.select) {
      return 'Select';
    } else if (key == LogicalKeyboardKey.space) {
      return 'Space';
    } else if (key == LogicalKeyboardKey.escape) {
      return 'Escape';
    } else if (key == LogicalKeyboardKey.browserBack) {
      return 'Back';
    } else if (key == LogicalKeyboardKey.goBack) {
      return 'Go Back';
    } else {
      // Try to get a reasonable name from the key itself
      String keyLabel = key.keyLabel;
      if (keyLabel.isNotEmpty) {
        return keyLabel;
      }

      // Fall back to the key's debug name
      return key.debugName ?? 'Unknown Key';
    }
  }
}
