/// A highly optimized TV navigation system for Flutter applications.
///
/// This package provides an ID-based approach to TV navigation where elements are
/// connected through explicit ID references rather than relying on position or
/// automatic detection.
///
/// # Core Features
///
/// - **ID-based Navigation**: Each navigable element has explicit references to its
///   neighbors in all directions (left, right, up, down)
/// - **Optimized Rendering**: Focus updates only trigger re-renders of affected elements
/// - **Smart Fallback**: Automatically finds the best element to focus if explicit
///   IDs are missing
/// - **Focus History**: Tracks navigation history for handling back navigation
/// - **Custom Focus Appearance**: Highly customizable focus indicators and transitions
/// - **Spatial Awareness**: Intelligent navigation based on element positions when
///   explicit connections are missing
///
/// # Basic Usage
///
/// Wrap your application with `TVNavigationProvider`:
///
/// ```dart
/// TVNavigationProvider(
///   initialFocusId: 'firstItem',
///   child: YourAppContent(),
/// )
/// ```
///
/// Make any widget navigable by wrapping it with `TVFocusable`:
///
/// ```dart
/// TVFocusable(
///   id: 'item1',
///   leftId: null, // No element to the left
///   rightId: 'item2', // ID of element to the right
///   upId: null, // No element above
///   downId: 'item3', // ID of element below
///   onSelect: () {
///     // Handle selection (e.g., when user presses Enter/OK)
///   },
///   onFocus: () {
///     // Handle focus (e.g., for analytics or pre-loading)
///   },
///   child: YourWidget(),
/// )
/// ```
///
/// # Architecture
///
/// The library uses a BLoC-based architecture:
///
/// 1. `TVFocusable` widgets register themselves with the navigation system
/// 2. `TVNavigationBloc` manages focus state and handles navigation events
/// 3. `TVNavigationListener` captures input events and converts them to navigation actions
/// 4. `TVNavigationProvider` provides the navigation context to the widget tree
// Core components
export 'src/models/models.dart';
export 'src/widgets/widgets.dart';
export 'src/bloc/tv_navigation_bloc.dart';
export 'src/utils/utils.dart';
export 'src/tv_navigation_provider.dart';
