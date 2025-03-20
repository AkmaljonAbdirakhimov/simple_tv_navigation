import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tv_navigation_bloc.dart';
import '../models/focus_element.dart';

/// A widget that makes any child navigable within the TV interface.
///
/// This widget wraps any UI element and makes it navigable within the TV navigation system.
/// It provides explicit references to neighboring elements in all four directions.
class TVFocusable extends StatefulWidget {
  /// Unique identifier for this element
  final String id;

  /// The widget to be displayed
  final Widget child;

  /// ID of the element to focus when navigating left
  final String? leftId;

  /// ID of the element to focus when navigating right
  final String? rightId;

  /// ID of the element to focus when navigating up
  final String? upId;

  /// ID of the element to focus when navigating down
  final String? downId;

  /// Callback triggered when this element is selected
  final VoidCallback? onSelect;

  /// Callback triggered when this element gets focus
  final VoidCallback? onFocus;

  /// Callback triggered when this element loses focus
  final VoidCallback? onBlur;

  /// Builder function for customizing the appearance based on focus state
  final Widget Function(
          BuildContext context, bool isFocused, bool isSelected, Widget child)?
      focusBuilder;

  /// Whether this element should automatically register itself when built
  final bool autoRegister;

  /// Whether this element should focus itself immediately when autoRegistered
  /// (if it's the first element)
  final bool autoFocus;

  /// Animation duration for focus transitions
  final Duration focusAnimationDuration;

  /// Constructor
  const TVFocusable({
    super.key,
    required this.id,
    required this.child,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    this.onSelect,
    this.onFocus,
    this.onBlur,
    this.focusBuilder,
    this.autoRegister = true,
    this.autoFocus = false,
    this.focusAnimationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable> {
  final GlobalKey _elementKey = GlobalKey();
  bool _isRegistered = false;
  TVNavigationBloc? _cachedBloc;

  @override
  void initState() {
    super.initState();
    // Cache the bloc reference when the widget is first built
    _cachedBloc = BlocProvider.of<TVNavigationBloc>(context);
    // We register in post-frame callback to ensure the widget is fully built
    if (widget.autoRegister) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _registerElement();
      });
    }
  }

  @override
  void didUpdateWidget(TVFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the ID or navigation properties changed, we need to update the element
    if (oldWidget.id != widget.id ||
        oldWidget.leftId != widget.leftId ||
        oldWidget.rightId != widget.rightId ||
        oldWidget.upId != widget.upId ||
        oldWidget.downId != widget.downId) {
      _registerElement();
    }
  }

  @override
  void dispose() {
    // Unregister this element when the widget is disposed
    if (_isRegistered && _cachedBloc != null) {
      _cachedBloc!.add(UnregisterElement(id: widget.id));
      _isRegistered = false;
    }
    super.dispose();
  }

  /// Register this element with the navigation system
  void _registerElement() {
    _cachedBloc ??= BlocProvider.of<TVNavigationBloc>(context);

    final element = FocusElement(
      id: widget.id,
      leftId: widget.leftId,
      rightId: widget.rightId,
      upId: widget.upId,
      downId: widget.downId,
    );

    _cachedBloc!.add(RegisterElement(
      element: element,
      focusImmediately: widget.autoFocus,
    ));

    _isRegistered = true;

    // After we've registered, update the render metrics
    _updateElementMetrics();
  }

  /// Update the render metrics (size and position) of this element
  void _updateElementMetrics() {
    // We need to wait for the render box to be attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final RenderObject? renderObject =
          _elementKey.currentContext?.findRenderObject();
      if (renderObject is RenderBox && _cachedBloc != null) {
        _cachedBloc!.add(UpdateElementMetrics(
          id: widget.id,
          key: _elementKey,
          renderBox: renderObject,
        ));
      }
    });
  }

  /// Ensures this widget is visible when it's inside a scrollable container
  void _ensureVisible() {
    final BuildContext? elementContext = _elementKey.currentContext;
    if (elementContext == null) return;

    // Wait for the next frame to make sure everything is laid out correctly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Find the closest scrollable ancestor and ensure this widget is visible
      Scrollable.ensureVisible(
        elementContext,
        alignment: 0.5, // Center the item
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Handle selection (when the user presses "OK" on this element)
  void _handleSelect() {
    if (widget.onSelect != null) {
      widget.onSelect!();
    }
  }

  /// Handle focus (when this element gets focus)
  void _handleFocus() {
    if (widget.onFocus != null) {
      widget.onFocus!();
    }

    // Ensure the element is visible when it gets focus
    _ensureVisible();

    // Update metrics each time we gain focus to ensure accurate measurements
    _updateElementMetrics();
  }

  /// Handle blur (when this element loses focus)
  void _handleBlur() {
    if (widget.onBlur != null) {
      widget.onBlur!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TVNavigationBloc, TVNavigationState, (bool, bool)>(
      selector: (state) {
        final element = state.elements[widget.id];
        final isFocused = element?.isFocused ?? false;
        final isSelected = element?.isSelected ?? false;
        return (isFocused, isSelected);
      },
      builder: (context, focusState) {
        final (isFocused, isSelected) = focusState;

        // Handle callbacks
        if (isFocused) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _handleFocus());
        } else {
          // Only call onBlur if we were previously focused
          final element =
              context.read<TVNavigationBloc>().state.elements[widget.id];
          if (element?.isFocused ?? false) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _handleBlur());
          }
        }

        // Handle selection
        if (isSelected) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _handleSelect());
        }

        // Default focus styling if no builder provided
        Widget result = widget.child;

        if (widget.focusBuilder != null) {
          result = widget.focusBuilder!(
              context, isFocused, isSelected, widget.child);
        } else {
          // Apply default focus styling
          result = AnimatedContainer(
            duration: widget.focusAnimationDuration,
            decoration: BoxDecoration(
              border: isFocused
                  ? Border.all(color: const Color(0xFF2196F3), width: 2.0)
                  : null,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: widget.child,
          );
        }

        return KeyedSubtree(
          key: _elementKey,
          child: result,
        );
      },
    );
  }
}
