# Simple TV Navigation Example

This example demonstrates how to use the Simple TV Navigation package to create a TV-friendly user interface in Flutter.

## Features Demonstrated

1. Basic Navigation Grid
   - Shows how to create a grid of navigable items
   - Demonstrates proper connected navigation using left/right/up/down IDs

2. Focus Restoration
   - Shows how to save and restore the last focused position
   - Uses the `restoreFocus` flag to identify elements to focus

3. Custom Focus Appearance
   - Demonstrates using `focusBuilder` for custom focus effects
   - Shows usage of `showDefaultFocusDecoration`

4. Navigation Control
   - Shows how to enable/disable the entire navigation system
   - Provides manual navigation examples

## Running the Example

1. Ensure you have Flutter installed
2. Run the example:

```bash
cd example
flutter run -d windows  # or -d linux, -d macos, etc.
```

## Usage

- Use arrow keys to navigate between items
- Press Enter/Space to select items
- Toggle the switch in the app bar to enable/disable navigation

## Implementation Details

The example implements a simple grid of items, each connected to its neighbors. It also demonstrates how to store and restore focus, which is useful for maintaining state across screen changes or app restarts.

Key code snippet:

```dart
// Restoring focus
TVFocusable(
  id: itemId,
  leftId: leftId,
  rightId: rightId,
  upId: upId,
  downId: downId,
  // Example of focus restoration
  restoreFocus: _lastFocusedId == itemId,
  onFocus: () {
    // Remember the last focused ID
    setState(() {
      _lastFocusedId = itemId;
    });
  },
  // ... rest of the widget
)
```

The focus is restored by:
1. Storing the `_lastFocusedId` whenever an item receives focus
2. Marking the item with `restoreFocus: true` when it matches the stored ID
3. The navigation system automatically focuses on it when it becomes available 