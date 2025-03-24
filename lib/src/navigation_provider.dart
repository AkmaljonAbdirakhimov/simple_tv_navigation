import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/focus_direction.dart';
import 'models/tv_focus_element.dart';

/// Navigation state for TV applications.
///
/// Manages focus elements, current focus, focus history, and provides
/// methods for navigating between elements.
class TVNavigationState extends ChangeNotifier {
  /// Map of all registered focusable elements by ID
  final Map<String, TVFocusElement> _elements = {};

  /// ID of the currently focused element
  String? _currentFocusId;

  /// ID of the last element that was focused
  String? _lastFocusedId;

  /// The last direction in which focus was moved
  FocusDirection? _lastDirection;

  /// History of previously focused element IDs
  final List<String> _focusHistory = [];

  /// ID that should be restored when possible
  String? _idToRestore;

  /// Whether the navigation system is enabled
  bool _enabled;

  /// Creates a new navigation state.
  ///
  /// If [initialFocusId] is provided and exists in the registered elements,
  /// it will receive initial focus.
  ///
  /// Set [enabled] to false to disable the navigation system.
  TVNavigationState({
    String? initialFocusId,
    bool enabled = true,
  }) : _enabled = enabled {
    if (initialFocusId != null) {
      _idToRestore = initialFocusId;
      _lastFocusedId = initialFocusId;
    }
  }

  /// The ID of the currently focused element, if any.
  String? get currentFocusId => _currentFocusId;

  /// The ID of the last element that was focused, if any.
  /// This persists even when no element is currently focused.
  String? get lastFocusedId => _lastFocusedId;

  /// The last direction in which focus was moved.
  FocusDirection? get lastDirection => _lastDirection;

  /// Whether the navigation system is enabled.
  bool get enabled => _enabled;

  /// Sets whether the navigation system is enabled.
  set enabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      notifyListeners();
    }
  }

  /// Registers a focusable element in the navigation system.
  ///
  /// If this is the ID that needs to be restored, it will be focused.
  /// If this is the first element and no element is currently focused,
  /// it will receive initial focus.
  void registerElement(TVFocusElement element) {
    _elements[element.id] = element;

    // If this is the element we need to restore focus to, do it
    if (_idToRestore == element.id) {
      // Defer focus to avoid build-phase state changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setFocus(element.id);
        _idToRestore = null;
      });
    }

    // If no element is focused and this is the first element, focus it
    if (_currentFocusId == null && _elements.length == 1) {
      // Defer focus to avoid build-phase state changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setFocus(element.id);
      });
    }
  }

  /// Updates an existing focusable element.
  void updateElement(TVFocusElement element) {
    if (_elements.containsKey(element.id)) {
      _elements[element.id] = element;
      // Use microtask to avoid triggering during build phase
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  /// Unregisters a focusable element from the navigation system.
  void unregisterElement(String id) {
    _elements.remove(id);

    // If the unregistered element was focused, clear focus
    if (_currentFocusId == id) {
      _currentFocusId = null;
    }

    // Remove from history
    _focusHistory.removeWhere((historyId) => historyId == id);

    notifyListeners();
  }

  /// Sets focus to the specified element ID.
  ///
  /// Returns true if focus was successfully set, false otherwise.
  bool setFocus(String id) {
    if (!_enabled) return false;

    if (!_elements.containsKey(id)) {
      return false;
    }

    final String? previousFocusId = _currentFocusId;

    // Add to history only if we're changing focus
    if (previousFocusId != null && previousFocusId != id) {
      _focusHistory.add(previousFocusId);

      // Keep history to a reasonable size
      if (_focusHistory.length > 20) {
        _focusHistory.removeAt(0);
      }

      // Call onBlur for the element losing focus, if it exists
      if (_elements.containsKey(previousFocusId)) {
        _elements[previousFocusId]?.onBlur?.call(_lastDirection);
      }
    }

    _currentFocusId = id;
    _lastFocusedId = id; // Update the last focused ID

    // Trigger onFocus callback
    _elements[id]?.onFocus?.call();

    notifyListeners();
    return true;
  }

  /// Moves focus in the specified direction.
  ///
  /// Returns true if focus was successfully moved, false otherwise.
  bool moveFocus(FocusDirection direction) {
    if (!_enabled || _currentFocusId == null) return false;

    final currentElement = _elements[_currentFocusId];
    if (currentElement == null) return false;

    String? targetId;

    // Store the direction before attempting to move
    _lastDirection = direction;

    // Determine target ID based on direction
    switch (direction) {
      case FocusDirection.left:
        targetId = currentElement.leftId;
        break;
      case FocusDirection.right:
        targetId = currentElement.rightId;
        break;
      case FocusDirection.up:
        targetId = currentElement.upId;
        break;
      case FocusDirection.down:
        targetId = currentElement.downId;
        break;
    }

    // If no explicit target, try to find best element in that direction
    if (targetId == null) {
      // In a real implementation, you'd have spatial awareness logic here
      // For simplicity, we'll just return false
      return false;
    }

    return setFocus(targetId);
  }

  /// Selects the currently focused element.
  ///
  /// Returns true if an element was selected, false otherwise.
  bool selectFocused() {
    if (!_enabled || _currentFocusId == null) return false;

    final element = _elements[_currentFocusId];
    if (element == null) return false;

    element.onSelect?.call();
    return true;
  }

  /// Navigates back to the previously focused element.
  ///
  /// Returns true if successfully navigated back, false otherwise.
  bool navigateBack() {
    if (!_enabled || _focusHistory.isEmpty) return false;

    final previousId = _focusHistory.removeLast();

    // Skip IDs that no longer exist
    if (!_elements.containsKey(previousId)) {
      return navigateBack();
    }

    final String? currentFocusedId = _currentFocusId;
    if (currentFocusedId != null && _elements.containsKey(currentFocusedId)) {
      // Back navigation doesn't have a clear direction, pass null
      _lastDirection = null;
      _elements[currentFocusedId]?.onBlur?.call(null);
    }

    _currentFocusId = previousId;
    _lastFocusedId = previousId; // Update the last focused ID

    notifyListeners();

    // Trigger onFocus callback
    _elements[previousId]?.onFocus?.call();

    return true;
  }

  /// Checks if an element with the specified ID exists.
  bool hasElement(String id) {
    return _elements.containsKey(id);
  }

  /// Sets an ID to restore focus to when it becomes available.
  void setRestoreId(String id) {
    _idToRestore = id;
  }
}

/// Provider widget for TV navigation.
///
/// Provides the navigation state to the widget tree.
class TVNavigationProvider extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// The ID of the element to receive initial focus.
  final String? initialFocusId;

  /// Whether the navigation system is enabled.
  final bool enabled;

  /// Creates a new TV navigation provider.
  const TVNavigationProvider({
    super.key,
    required this.child,
    this.initialFocusId,
    this.enabled = true,
  });

  @override
  State<TVNavigationProvider> createState() => _TVNavigationProviderState();
}

class _TVNavigationProviderState extends State<TVNavigationProvider> {
  late TVNavigationState _navigationState;

  @override
  void initState() {
    super.initState();
    _navigationState = TVNavigationState(
      initialFocusId: widget.initialFocusId,
      enabled: widget.enabled,
    );

    // Add low-level keyboard handler
    ServicesBinding.instance.keyboard.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    // Remove keyboard handler when disposing
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  void didUpdateWidget(TVNavigationProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      // Schedule the update to happen after the current build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigationState.enabled = widget.enabled;
      });
    }

    // If initialFocusId changed and is not null, update the restore ID
    if (widget.initialFocusId != oldWidget.initialFocusId &&
        widget.initialFocusId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigationState.setRestoreId(widget.initialFocusId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TVNavigationState>.value(
      value: _navigationState,
      child: ExcludeFocus(
        excluding: _navigationState.enabled,
        child: widget.child,
      ),
    );
  }

  // Modified to return bool as required by ServicesBinding.keyboard.addHandler
  bool _handleKeyEvent(KeyEvent event) {
    if (!_navigationState.enabled) return false;

    // Only handle KeyDownEvent
    if (event is! KeyDownEvent) return false;

    bool handled = true;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _navigationState.moveFocus(FocusDirection.left);
        break;
      case LogicalKeyboardKey.arrowRight:
        _navigationState.moveFocus(FocusDirection.right);
        break;
      case LogicalKeyboardKey.arrowUp:
        _navigationState.moveFocus(FocusDirection.up);
        break;
      case LogicalKeyboardKey.arrowDown:
        _navigationState.moveFocus(FocusDirection.down);
        break;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.gameButtonA: // For game controllers
        _navigationState.selectFocused();
        break;
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.browserBack:
      case LogicalKeyboardKey.gameButtonB: // For game controllers
        _navigationState.navigateBack();
        break;
      default:
        handled = false;
    }

    // Return true if we handled the key event to prevent it from being passed to other handlers
    return handled;
  }
}
