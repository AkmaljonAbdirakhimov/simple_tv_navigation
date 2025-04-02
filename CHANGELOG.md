# Changelog

## 0.0.1 - April 2, 2024

Initial release of the simple_tv_navigation package.

### Features

- ID-based navigation system for TV-like interfaces
- TvNavigationProvider widget for application wrapping
- TVFocusable widget for creating focusable elements
- Built-in keyboard/remote navigation support
- TvFocusElement model for defining navigation connections
- Four-way directional navigation (up, down, left, right)
- Support for dynamic navigation paths
- Automatic scrolling to focused elements
- Focus, blur, selection and navigation event callbacks
- Customizable focus highlighting
- Built on Flutter BLoC architecture for clean state management
- Support for enabling/disabling navigation
- ExcludeFocus functionality (enabled by default) to prevent Flutter's system focus interference

### Dependencies

- Flutter 1.17.0 or higher
- Dart SDK 3.6.1 or higher
- flutter_bloc 9.1.0
- equatable 2.0.7
