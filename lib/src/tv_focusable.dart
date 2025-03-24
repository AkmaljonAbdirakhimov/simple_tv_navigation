import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'models/tv_focus_element.dart';
import 'navigation_provider.dart';
import 'models/focus_direction.dart';

/// A widget that can be focused in TV navigation.
///
/// Wraps a child widget and makes it focusable using the TV navigation system.
class TVFocusable extends StatefulWidget {
  /// Unique identifier for this focusable element
  final String id;

  /// Callback that returns the current ID. If provided, this will be used instead of the static id.
  final String Function()? dynamicId;

  /// ID of the element to the left, if any
  final String? leftId;

  /// Callback that returns the ID of the element to the left
  final String? Function()? dynamicLeftId;

  /// ID of the element to the right, if any
  final String? rightId;

  /// Callback that returns the ID of the element to the right
  final String? Function()? dynamicRightId;

  /// ID of the element above, if any
  final String? upId;

  /// Callback that returns the ID of the element above
  final String? Function()? dynamicUpId;

  /// ID of the element below, if any
  final String? downId;

  /// Callback that returns the ID of the element below
  final String? Function()? dynamicDownId;

  /// Child widget to render
  final Widget? child;

  /// Callback triggered when this element is selected
  final VoidCallback? onSelect;

  /// Callback triggered when this element receives focus
  final VoidCallback? onFocus;

  /// Callback triggered when this element loses focus
  /// The direction parameter indicates which direction the focus moved
  final void Function(FocusDirection? direction)? onBlur;

  /// Builder function for custom focus appearance
  final Widget Function(
          BuildContext context, bool isFocused, bool isSelected, Widget? child)?
      focusBuilder;

  /// Builder function for complete widget customization
  final Widget Function(
          BuildContext context, bool isFocused, bool isSelected, Widget? child)?
      builder;

  /// Whether to show the default focus decoration
  final bool showDefaultFocusDecoration;

  /// Whether to automatically scroll to ensure this element is visible when focused
  final bool ensureVisible;

  /// Alignment for scrolling when ensuring visibility (0.0 is start, 0.5 is center, 1.0 is end)
  final double scrollAlignment;

  /// Duration for the scroll animation when ensuring visibility
  final Duration scrollDuration;

  /// Creates a new TV focusable widget.
  const TVFocusable({
    super.key,
    required this.id,
    this.dynamicId,
    this.leftId,
    this.dynamicLeftId,
    this.rightId,
    this.dynamicRightId,
    this.upId,
    this.dynamicUpId,
    this.downId,
    this.dynamicDownId,
    this.child,
    this.onSelect,
    this.onFocus,
    this.onBlur,
    this.focusBuilder,
    this.builder,
    this.showDefaultFocusDecoration = false,
    this.ensureVisible = true,
    this.scrollAlignment = 0.5,
    this.scrollDuration = const Duration(milliseconds: 300),
  }) : assert(child != null || builder != null,
            'Either child or builder must be provided');

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable> {
  late TVFocusElement _element;
  TVNavigationState? _navigationState;
  bool _isRegistered = false;
  String? _lastId;
  String? _lastLeftId;
  String? _lastRightId;
  String? _lastUpId;
  String? _lastDownId;

  // Global key for the widget to use with Scrollable.ensureVisible
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _lastId = widget.dynamicId?.call() ?? widget.id;
    _updateNavigationIds();
  }

  void _updateNavigationIds() {
    // Get new IDs from callbacks or static values
    final newLeftId = widget.dynamicLeftId?.call() ?? widget.leftId;
    final newRightId = widget.dynamicRightId?.call() ?? widget.rightId;
    final newUpId = widget.dynamicUpId?.call() ?? widget.upId;
    final newDownId = widget.dynamicDownId?.call() ?? widget.downId;

    // Check if we need to update
    bool needsUpdate = newLeftId != _lastLeftId ||
        newRightId != _lastRightId ||
        newUpId != _lastUpId ||
        newDownId != _lastDownId;

    // Always update in initState, or when IDs change later
    if (needsUpdate || !_isRegistered) {
      _lastLeftId = newLeftId;
      _lastRightId = newRightId;
      _lastUpId = newUpId;
      _lastDownId = newDownId;

      // Create or update the element with new IDs
      _element = TVFocusElement(
        id: _lastId!,
        leftId: _lastLeftId,
        rightId: _lastRightId,
        upId: _lastUpId,
        downId: _lastDownId,
        onSelect: () {
          widget.onSelect?.call();
          // Update navigation IDs when focused
          _updateNavigationIds();
        },
        onFocus: () {
          widget.onFocus?.call();
          // Update navigation IDs when focused
          _updateNavigationIds();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _ensureVisible();
            }
          });
        },
        onBlur: widget.onBlur,
      );

      // If already registered, update the element in the navigation system
      if (_isRegistered) {
        _navigationState?.updateElement(_element);
      }
    }
  }

  // Function to ensure the widget is visible by scrolling to it
  void _ensureVisible() {
    // Skip if auto-scrolling is disabled
    if (!widget.ensureVisible) return;

    final BuildContext? context = _widgetKey.currentContext;
    if (context != null) {
      // Use a post-frame callback to ensure the widget is laid out
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Scrollable.ensureVisible(
            context,
            alignment: widget.scrollAlignment,
            duration: widget.scrollDuration,
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Register after build completes using microtask to avoid build-phase setState
    if (!_isRegistered) {
      _navigationState = Provider.of<TVNavigationState>(context, listen: false);

      // Use a microtask to defer the registration until after the build is complete
      Future.microtask(() {
        if (mounted) {
          // Register with the navigation system
          _navigationState?.registerElement(_element);

          // Mark as the element to restore focus to if needed
          // if its ID matches lastFocusedId
          final bool shouldRestoreFocus =
              (_navigationState?.lastFocusedId == _lastId);

          if (shouldRestoreFocus) {
            _navigationState?.setRestoreId(_lastId!);
            _navigationState?.setFocus(_lastId!);
          }

          _isRegistered = true;
        }
      });
    }
  }

  @override
  void didUpdateWidget(TVFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsUpdate = false;
    bool wasFocused = false;

    // Get current ID from callback or static value
    String? newId = widget.dynamicId?.call() ?? widget.id;

    // Check if this widget was focused before the update
    if (_navigationState != null) {
      wasFocused = _navigationState!.currentFocusId == _lastId;
    }

    // Update if ID changed
    if (newId != _lastId) {
      _lastId = newId;
      needsUpdate = true;
    }

    // Update navigation IDs
    _updateNavigationIds();

    // Handle restoreFocus changes
    bool needsRestoreFocus = false;

    // Check if this widget's ID matches the last focused ID
    if (_navigationState != null) {
      needsRestoreFocus = _navigationState!.lastFocusedId == _lastId;
    }

    // Schedule updates after build using microtask
    if (needsUpdate || needsRestoreFocus) {
      Future.microtask(() {
        if (mounted) {
          if (needsUpdate) {
            // If this widget was focused, maintain focus after update
            if (wasFocused) {
              _navigationState?.setFocus(_lastId!);
            }
          }

          if (needsRestoreFocus) {
            _navigationState?.setRestoreId(_lastId!);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // Unregister from the navigation system using a post-frame callback
    // to avoid calling setState during build/layout
    if (_isRegistered) {
      // Schedule the unregister operation after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigationState?.unregisterElement(_lastId!);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TVNavigationState>(
      builder: (context, navigationState, _) {
        // Set default focus states
        const bool isFocused = false;
        const bool isSelected = false;
        Widget result;

        if (!navigationState.enabled) {
          // Even when navigation is disabled, respect builder callbacks
          if (widget.builder != null) {
            result =
                widget.builder!(context, isFocused, isSelected, widget.child);
          } else if (widget.focusBuilder != null) {
            result = widget.focusBuilder!(
                context, isFocused, isSelected, widget.child);
          } else {
            // No builder, use the child directly
            result = widget.child ?? const SizedBox.shrink();
          }

          // Add the key to the result
          return KeyedSubtree(
            key: _widgetKey,
            child: result,
          );
        }

        // Navigation is enabled, use the regular focus logic
        final bool elementIsFocused = navigationState.currentFocusId == _lastId;

        // Prepare the child or result from builder
        if (widget.builder != null) {
          result = widget.builder!(
              context, elementIsFocused, isSelected, widget.child);
        } else if (widget.focusBuilder != null) {
          result = widget.focusBuilder!(
              context, elementIsFocused, isSelected, widget.child);
        } else {
          // No builder, use the child directly
          result = widget.child ?? const SizedBox.shrink();
        }

        // Add the key to the result
        result = KeyedSubtree(
          key: _widgetKey,
          child: result,
        );

        // Apply default focus decoration if requested, regardless of whether
        // we're using a builder or not
        if (widget.showDefaultFocusDecoration) {
          return DefaultFocusDecoration(
            isFocused: elementIsFocused,
            child: result,
          );
        }

        return result;
      },
    );
  }
}

/// Default focus decoration for TV focusable elements.
class DefaultFocusDecoration extends StatelessWidget {
  /// Whether the element is focused
  final bool isFocused;

  /// Child widget to decorate
  final Widget child;

  /// Creates a new default focus decoration.
  const DefaultFocusDecoration({
    super.key,
    required this.isFocused,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: isFocused ? Border.all(color: Colors.blue, width: 2) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
