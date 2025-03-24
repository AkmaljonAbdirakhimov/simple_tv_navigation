## 0.0.1+25

- Enhanced focus management by moving lastFocusedId tracking to TVNavigationState
- Added lastFocusedId getter to TVNavigationState to retrieve persistent focus state
- Properly updated lastFocusedId in all focus state changes (setFocus, navigateBack)
- Removed redundant focus state tracking from UI layer
- Improved TVNavigationProvider to handle initial focus ID changes

## 0.0.1+24

- Simplified focus management system by removing screen-based focus tracking
- Removed `initialScreen` and `initialScreenFocusMap` parameters from TVNavigationProvider
- Removed `currentScreen`, `screenFocusMap`, `changeScreen`, and `setLastFocusedIdForScreen` from TVNavigationState
- Improved performance by reducing unnecessary state tracking
- Reduced API complexity for easier integration

## 0.0.1+23

- Improved screen-based focus memory with automatic management inside TVFocusable
- Removed the need for manual calls to setLastFocusedIdForScreen
- TVFocusable now automatically tracks and updates the last focused ID for each screen
- Enhanced example app to demonstrate automatic focus memory management
- Simplified integration of focus memory with existing code

## 0.0.1+22

- Added screen-based focus memory to maintain focus state per screen
- Added `changeScreen` method to switch between screens while preserving focus state
- Added `setLastFocusedIdForScreen` to manually set the last focused ID for a specific screen
- Added `initialScreen` and `initialScreenFocusMap` parameters to TVNavigationProvider
- Enhanced the example app with screen-based navigation and focus restoration
- Improved focus management during screen transitions

## 0.0.1+21

- Added auto-scrolling functionality with `Scrollable.ensureVisible`
- Added `ensureVisible` property to control whether elements auto-scroll into view
- Added `scrollAlignment` and `scrollDuration` properties to customize scrolling behavior
- Improved focus handling to automatically scroll to focused elements

## 0.0.1+20

- Fixed "setState() called during build" exception by properly scheduling state updates
- Improved state management to avoid modifications during the build phase
- Added safety checks to ensure widget is still mounted before updating state

## 0.0.1+19

- Added focus restoration functionality with `restoreFocus` parameter to TVFocusable
- Added `setRestoreId` method to manually set the ID to restore focus to
- Improved focus restoration logic to automatically focus elements when they become available
- Fixed default decoration to work properly with custom builders when `showDefaultFocusDecoration` is true

## 0.0.1+18

- Added `hasElement(id)` method to check if a specific element exists in the navigation system
- Added option to enable or disable the TVNavigationProvider with `enabled` parameter
- Added new `builder` parameter to TVFocusable for complete widget customization
- Made child parameter optional when a builder is provided
- Added option to toggle default focus decoration with `showDefaultFocusDecoration`
- Fixed selection handling to properly work with repeated selections
- Improved error handling in TVFocusable when TVNavigationBloc isn't available
- Added accessibility support with Semantics
- Optimized performance with more efficient BlocListener implementation
- Fixed handling of disabled TVNavigationProvider to prevent assertion errors
- Added option to enable or disable the TVNavigationProvider with `enabled` parameter

## 0.0.1

- Initial release
- Core navigation system implementation
- TVFocusable widget
- TVNavigationProvider
- Focus management with ID-based navigation
- Directional navigation (left, right, up, down)
- Selection support
- Back navigation
- History tracking
- Spatial awareness for automatic navigation
- Navigation analyzer utilities
