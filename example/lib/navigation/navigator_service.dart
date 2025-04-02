import 'package:flutter/material.dart';

import 'custom_page_transitions.dart';

class NavigatorService {
  // Main navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Nested navigator key for content screens
  static GlobalKey<NavigatorState>? _nestedNavigatorKey;

  // Main navigator state
  static NavigatorState? get navigator => navigatorKey.currentState;

  // Get the active navigator (nested if available, otherwise main)
  static NavigatorState? get activeNavigator =>
      _nestedNavigatorKey?.currentState ?? navigatorKey.currentState;

  // Register a nested navigator key
  static void registerNestedNavigatorKey(GlobalKey<NavigatorState> nestedKey) {
    _nestedNavigatorKey = nestedKey;
  }

  // Unregister the nested navigator key
  static void unregisterNestedNavigatorKey() {
    _nestedNavigatorKey = null;
  }

  static Future<T?> push<T>(Widget page) {
    return activeNavigator!.push<T>(
      FadePageRoute(builder: (context) => page),
    );
  }

  static Future<T?> pushReplacement<T>(Widget page) {
    return activeNavigator!.pushReplacement<T, dynamic>(
      FadePageRoute(builder: (context) => page),
    );
  }

  static void pop<T>([T? result]) {
    return activeNavigator!.pop<T>(result);
  }

  static bool canPop() {
    return activeNavigator!.canPop();
  }
}
