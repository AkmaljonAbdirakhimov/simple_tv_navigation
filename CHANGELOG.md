## 0.0.1+12

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

## 0.0.1+11

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
