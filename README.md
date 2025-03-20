<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Simple TV Navigation

A highly optimized and efficient TV navigation system for Flutter applications. This package provides an ID-based approach to TV navigation, where elements are connected through explicit ID references rather than relying on position or automatic detection.

## Features

- **ID-based Navigation**: Each navigable element has explicit references to its neighbors in all directions (left, right, up, down)
- **Optimized Rendering**: Focus updates only trigger re-renders of affected elements
- **Smart Fallback**: Automatically finds the best element to focus if explicit IDs are missing
- **Focus History**: Tracks navigation history for handling back navigation
- **Custom Focus Appearance**: Highly customizable focus indicators and transitions
- **Spatial Awareness**: Intelligent navigation based on element positions when explicit connections are missing
- **Memory Management**: Efficient storage of the navigation graph and cleanup of unused elements
- **Debugging Tools**: Navigation path analysis and validation
- **Input Handling**: Support for keyboard, remote controls, and gamepads

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  simple_tv_navigation: ^0.0.1
```

## Basic Usage

Wrap your application (or a section of it) with `TVNavigationProvider`:

```dart
TVNavigationProvider(
  initialFocusId: 'firstItem',
  child: Scaffold(
    body: YourAppContent(),
  ),
)
```

Make any widget navigable by wrapping it with `TVFocusable`:

```dart
TVFocusable(
  id: 'item1',
  leftId: null, // No element to the left
  rightId: 'item2', // ID of element to the right
  upId: null, // No element above
  downId: 'item3', // ID of element below
  onSelect: () {
    // Handle selection (e.g., when user presses Enter/OK)
    print('Item 1 selected!');
  },
  onFocus: () {
    // Handle focus (e.g., for analytics or pre-loading)
    print('Item 1 focused!');
  },
  child: YourWidget(),
)
```

## Advanced Features

### Custom Focus Appearance

Use the `focusBuilder` parameter to customize the appearance when an element is focused:

```dart
TVFocusable(
  id: 'customItem',
  // ... other parameters
  focusBuilder: (context, isFocused, isSelected, child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: isFocused 
          ? (Matrix4.identity()..scale(1.1))
          : Matrix4.identity(),
      decoration: BoxDecoration(
        border: isFocused
            ? Border.all(color: Colors.blue, width: 3)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  },
  child: YourWidget(),
)
```

### Programmatic Navigation

You can control the navigation programmatically using the extension methods:

```dart
// Move focus in a direction
context.moveFocus(FocusDirection.right);

// Set focus to a specific element by ID
context.setFocus('item3');

// Select the currently focused element
context.selectFocused();

// Navigate back to the previous element
context.navigateBack();
```

### Nested Navigation Contexts

You can create nested navigation contexts (e.g., for dialogs or modals):

```dart
showDialog(
  context: context,
  builder: (dialogContext) {
    return TVNavigationProvider(
      initialFocusId: 'dialogButton1',
      child: AlertDialog(
        // ... dialog content
        actions: [
          TVFocusable(
            id: 'dialogButton1',
            rightId: 'dialogButton2',
            child: TextButton(
              onPressed: () { /* ... */ },
              child: Text('OK'),
            ),
          ),
          TVFocusable(
            id: 'dialogButton2',
            leftId: 'dialogButton1',
            child: TextButton(
              onPressed: () { /* ... */ },
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  },
);
```

### Analyzing Navigation Paths

## Additional Information

### Contributing
We welcome contributions! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Issues and Support
If you encounter any issues or have questions, please file an issue on our [GitHub repository](https://github.com/yourusername/simple_tv_navigation/issues).

### Response Time
We aim to respond to issues and pull requests within 48 hours. For critical issues, we'll try to respond as quickly as possible.

### Documentation
For more detailed documentation and examples, please visit our [documentation site](https://github.com/yourusername/simple_tv_navigation/wiki).

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
