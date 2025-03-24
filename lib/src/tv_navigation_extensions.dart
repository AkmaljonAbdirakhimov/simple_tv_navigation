import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/focus_direction.dart';
import 'navigation_provider.dart';

/// Extension methods for TV navigation on [BuildContext].
extension TVNavigationExtensions on BuildContext {
  /// The current TV navigation state from the widget tree.
  TVNavigationState? get _navigationState {
    try {
      return Provider.of<TVNavigationState>(this, listen: false);
    } catch (e) {
      debugPrint('TVNavigationState not found in the widget tree. '
          'Make sure you have a TVNavigationProvider above this widget.');
      return null;
    }
  }

  /// Moves focus in the specified direction.
  ///
  /// Returns true if focus was successfully moved, false otherwise.
  bool moveFocus(FocusDirection direction) {
    return _navigationState?.moveFocus(direction) ?? false;
  }

  /// Sets focus to the specified element ID.
  ///
  /// Returns true if focus was successfully set, false otherwise.
  bool setFocus(String id) {
    return _navigationState?.setFocus(id) ?? false;
  }

  /// Selects the currently focused element.
  ///
  /// Returns true if an element was selected, false otherwise.
  bool selectFocused() {
    return _navigationState?.selectFocused() ?? false;
  }

  /// Navigates back to the previously focused element.
  ///
  /// Returns true if successfully navigated back, false otherwise.
  bool navigateBack() {
    return _navigationState?.navigateBack() ?? false;
  }

  /// Checks if an element with the specified ID exists.
  bool hasElement(String id) {
    return _navigationState?.hasElement(id) ?? false;
  }

  /// Sets an ID to restore focus to when it becomes available.
  void setRestoreId(String id) {
    _navigationState?.setRestoreId(id);
  }

  /// Gets the ID of the currently focused element, if any.
  String? get currentFocusId => _navigationState?.currentFocusId;
  
  /// Gets the last direction in which focus was moved, if any.
  FocusDirection? get lastDirection => _navigationState?.lastDirection;
}
