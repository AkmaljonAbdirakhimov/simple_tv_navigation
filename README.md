# simple_tv_navigation

A highly optimized TV navigation system for Flutter applications, providing efficient ID-based focus management for TVs, set-top boxes, and game consoles.

## Features

- **ID-based navigation**: Navigate between UI elements using unique IDs
- **Direction-based focus management**: Define clear navigation paths with up, down, left, and right connections
- **Dynamic navigation paths**: Support for dynamic navigation paths that can change at runtime
- **Autofocus support**: Automatically focus elements when they appear
- **Keyboard navigation**: Built-in support for remote control and keyboard arrow keys
- **Focus visualization**: Customizable focus highlighting
- **Scroll to focused element**: Automatically scrolls to bring focused elements into view
- **Focus events**: Callbacks for focus, blur, selection, and navigation events
- **BLoC architecture**: Clean, testable architecture using Flutter BLoC pattern

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  simple_tv_navigation: ^0.0.1+28
```

## Usage

### Basic Setup

Wrap your app with the `TvNavigationProvider`:

```dart
void main() {
  runApp(
    TvNavigationProvider(
      child: MyApp(),
    ),
  );
}
```

### Creating Focusable Elements

Add focusable elements to your UI:

```dart
TVFocusable(
  id: 'button1',
  leftId: 'sidebar_item',
  rightId: 'button2', 
  upId: 'top_menu',
  downId: 'bottom_button',
  showDefaultFocusDecoration: true,
  onSelect: () {
    // Handle selection
    print('Button 1 selected');
  },
  child: Container(
    padding: const EdgeInsets.all(16),
    color: Colors.blue,
    child: const Text('Button 1'),
  ),
)
```

### Custom Focus Styling

Use the builder to create custom focus effects:

```dart
TVFocusable(
  id: 'custom_button',
  builder: (context, isFocused, child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: isFocused 
          ? Matrix4.identity()..scale(1.1)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: isFocused ? Colors.red : Colors.grey,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isFocused
            ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10)]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        'Custom Button',
        style: TextStyle(
          color: Colors.white,
          fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  },
)
```

### Dynamic Navigation Paths

Use dynamic ID callbacks for complex navigation scenarios:

```dart
TVFocusable(
  id: 'dynamic_button',
  dynamicLeftId: () {
    // Return different IDs based on state
    return isSpecialCase ? 'special_button' : 'normal_button';
  },
  child: Text('Dynamic Navigation'),
)
```

### Programmatic Navigation

Control focus programmatically using context extensions:

```dart
// Move focus in a direction
context.moveFocus(TvFocusDirection.right);

// Set focus to a specific element
context.setFocus('settings_button');

// Select currently focused element
context.selectCurrent();

// Check if element is focused
bool isFocused = context.isElementFocused('my_button');

// Enable/disable TV navigation
context.setTvNavigationEnabled(false);
```

## Advanced Features

### Managing Multiple Navigation Areas

For complex UIs with multiple navigation areas (like sidebars and main content):

1. Use separate TvNavigationProvider widgets for each area
2. Enable/disable navigation areas as needed

```dart
// In your sidebar state:
context.setTvNavigationEnabled(true);  // Enable sidebar navigation
// In your content area:
context.setTvNavigationEnabled(false); // Disable content navigation
```

### Controlling System Focus

The package includes functionality to exclude Flutter's system focus when using TV navigation. This prevents interference between the TV navigation system and Flutter's default focus system:

```dart
// Enable exclude focus (default is true)
context.disableFocus();

// Disable exclude focus
context.enableFocus();
```

When exclude focus is enabled (the default), Flutter's system focus will be prevented while TV navigation is active, ensuring a consistent navigation experience.

### Focus Management with Lists

When working with dynamic lists, generate unique IDs and connections:

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final String itemId = 'item_$index';
    return TVFocusable(
      id: itemId,
      upId: index > 0 ? 'item_${index - 1}' : null,
      downId: index < items.length - 1 ? 'item_${index + 1}' : null,
      child: ListTile(title: Text(items[index])),
    );
  },
)
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
