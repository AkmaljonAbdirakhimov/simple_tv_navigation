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
  /// Optional if builder is provided
  final Widget? child;

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
          BuildContext context, bool isFocused, bool isSelected, Widget? child)?
      focusBuilder;

  /// General builder function that provides access to focus state
  /// This will be called instead of child if provided, giving more
  /// control over the entire widget rendering
  final Widget Function(
          BuildContext context, bool isFocused, bool isSelected, Widget? child)?
      builder;

  /// Whether this element should automatically register itself when built
  final bool autoRegister;

  /// Whether this element should focus itself immediately when autoRegistered
  /// (if it's the first element)
  final bool autoFocus;

  /// Whether to show the default focus decoration
  /// If false, no decoration will be applied unless focusBuilder is provided
  final bool showDefaultFocusDecoration;

  /// Animation duration for focus transitions
  final Duration focusAnimationDuration;

  /// Constructor
  const TVFocusable({
    super.key,
    required this.id,
    this.child,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    this.onSelect,
    this.onFocus,
    this.onBlur,
    this.focusBuilder,
    this.builder,
    this.autoRegister = true,
    this.autoFocus = false,
    this.showDefaultFocusDecoration = false,
    this.focusAnimationDuration = const Duration(milliseconds: 200),
  }) : assert(
          child != null || builder != null,
          'Either child or builder must be provided',
        );

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

    // Try to find the TVNavigationBloc in a safer way with proper error handling
    bool isNavigationAvailable = false;
    try {
      _cachedBloc = BlocProvider.of<TVNavigationBloc>(context);
      isNavigationAvailable = true;
    } catch (e) {
      // When TVNavigationProvider is disabled, this is expected and shouldn't cause an assertion
      isNavigationAvailable = false;
    }

    // Only assert if we're in a context where navigation should be available
    // but the bloc is missing
    if (!isNavigationAvailable) {
      // Check if we're inside a BlocProvider that should provide a TVNavigationBloc
      bool hasNavigationProvider = false;
      try {
        hasNavigationProvider = context.findAncestorWidgetOfExactType<
                BlocProvider<TVNavigationBloc>>() !=
            null;
      } catch (_) {
        // Ignore errors when checking for ancestor widgets
      }

      if (hasNavigationProvider) {
        assert(
          false,
          'No TVNavigationBloc found in the widget tree. '
          'Make sure to wrap your widget tree with TVNavigationProvider.',
        );
      }
    }

    // We register in post-frame callback to ensure the widget is fully built
    if (widget.autoRegister && isNavigationAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _registerElement();
      });
    }
  }

  @override
  void didUpdateWidget(TVFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When hot reloading, we need to check if this was the focused element
    // and preserve its focused state
    if (_cachedBloc != null) {
      final wasFocused = _cachedBloc!.state.focusedElementId == oldWidget.id;

      // If the ID changed but this was the focused element, update focus to the new ID
      if (oldWidget.id != widget.id && wasFocused) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Set focus to the new ID
          _cachedBloc!.add(SetFocus(id: widget.id));
        });
      }
    }

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
    if (_isRegistered && _cachedBloc != null) {
      _cachedBloc!.add(UnregisterElement(id: widget.id));
    }
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    // Hot reload has occurred, attempt to restore focus
    if (_cachedBloc != null) {
      _cachedBloc!.add(const RestoreFocus());
    }
  }

  /// Register this element with the navigation system
  void _registerElement() {
    if (_cachedBloc == null) {
      // Try to find the TVNavigationBloc, but don't show errors if navigation is disabled
      try {
        _cachedBloc = BlocProvider.of<TVNavigationBloc>(context);
      } catch (e) {
        // Only log debug messages in debug mode, and only if we're supposed to have a bloc
        // (i.e., we're inside a TVNavigationProvider that isn't disabled)
        bool hasNavigationProvider = false;
        try {
          hasNavigationProvider = context.findAncestorWidgetOfExactType<
                  BlocProvider<TVNavigationBloc>>() !=
              null;
        } catch (_) {
          // Ignore errors when checking for ancestor widgets
        }

        if (hasNavigationProvider) {
          debugPrint(
              'TVFocusable: Failed to register element ${widget.id} - No TVNavigationBloc found');
        }
        return;
      }
    }

    // Check if this element should maintain focus during hot reload
    final shouldRetainFocus = _cachedBloc!.state.focusedElementId == widget.id;

    final element = FocusElement(
      id: widget.id,
      leftId: widget.leftId,
      rightId: widget.rightId,
      upId: widget.upId,
      downId: widget.downId,
    );

    _cachedBloc!.add(RegisterElement(
      element: element,
      // Prioritize retaining focus if this was the focused element
      focusImmediately: shouldRetainFocus || widget.autoFocus,
    ));

    _isRegistered = true;

    // After we've registered, update the render metrics
    _updateElementMetrics();
  }

  /// Update the metrics of this element in the navigation system
  void _updateElementMetrics() {
    if (!mounted || _cachedBloc == null) return;

    // Get the RenderBox if it's available
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) {
      // If the render box is not available or has no size yet, schedule an update for later
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateElementMetrics();
      });
      return;
    }

    // Update the metrics in the navigation system
    _cachedBloc!.add(UpdateElementMetrics(
      id: widget.id,
      key: _elementKey,
      renderBox: renderBox,
    ));
  }

  /// Ensures this widget is visible when it's inside a scrollable container
  void _ensureVisible() {
    final BuildContext? elementContext = _elementKey.currentContext;
    if (elementContext == null) return;

    // Debounce scrolling to prevent excessive animations
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

    // Clear the selection state in the bloc after handling it
    // This allows the element to be selected again
    if (_cachedBloc != null) {
      _cachedBloc!.add(const ClearSelection());
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
    // Check if TVNavigationBloc is available
    // This also handles the case when TVNavigationProvider is disabled
    bool isNavigationAvailable = false;
    try {
      context.read<TVNavigationBloc>();
      isNavigationAvailable = true;
    } catch (_) {
      isNavigationAvailable = false;
    }

    if (!isNavigationAvailable) {
      // If navigation is disabled, just return the child without any focus styling
      return widget.builder != null
          ? widget.builder!(context, false, false, widget.child)
          : widget.child ?? const SizedBox();
    }

    return MultiBlocListener(
      listeners: [
        // Listen for focus changes
        BlocListener<TVNavigationBloc, TVNavigationState>(
          listenWhen: (previous, current) {
            final prevFocused =
                previous.elements[widget.id]?.isFocused ?? false;
            final currFocused = current.elements[widget.id]?.isFocused ?? false;
            return prevFocused != currFocused;
          },
          listener: (context, state) {
            final isFocused = state.elements[widget.id]?.isFocused ?? false;
            if (isFocused) {
              _handleFocus();
            } else {
              _handleBlur();
            }
          },
        ),
        // Listen for selection changes
        BlocListener<TVNavigationBloc, TVNavigationState>(
          listenWhen: (previous, current) {
            final prevSelected =
                previous.elements[widget.id]?.isSelected ?? false;
            final currSelected =
                current.elements[widget.id]?.isSelected ?? false;
            // Listen for when this element becomes selected
            return !prevSelected && currSelected;
          },
          listener: (context, state) {
            _handleSelect();
          },
        ),
      ],
      child: BlocSelector<TVNavigationBloc, TVNavigationState, (bool, bool)>(
        selector: (state) {
          final element = state.elements[widget.id];
          final isFocused = element?.isFocused ?? false;
          final isSelected = element?.isSelected ?? false;
          return (isFocused, isSelected);
        },
        builder: (context, focusState) {
          final (isFocused, isSelected) = focusState;

          // Default focus styling if no builder provided
          Widget result = widget.child ?? const SizedBox();

          // If a general builder is provided, use it first
          if (widget.builder != null) {
            result =
                widget.builder!(context, isFocused, isSelected, widget.child);
          }

          if (widget.focusBuilder != null) {
            result = widget.focusBuilder!(
                context, isFocused, isSelected, widget.child);
          } else if (widget.showDefaultFocusDecoration) {
            // Apply default focus styling only if showDefaultFocusDecoration is true
            result = AnimatedContainer(
              duration: widget.focusAnimationDuration,
              decoration: BoxDecoration(
                border: isFocused
                    ? Border.all(color: const Color(0xFF2196F3), width: 2.0)
                    : null,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: result,
            );
          }
          // else just use the child as is (no decoration)

          // Wrap with Semantics for accessibility
          return KeyedSubtree(
            key: _elementKey,
            child: Semantics(
              label: widget.id,
              selected: isFocused,
              focusable: true,
              child: result,
            ),
          );
        },
      ),
    );
  }

  void updateState() {
    if (_isRegistered && _cachedBloc != null) {
      _updateElementMetrics();
    }
  }
}
