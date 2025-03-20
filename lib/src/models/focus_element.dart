import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Represents a focusable element in the TV navigation system.
///
/// This class holds all the necessary information about a navigable UI element,
/// including its ID, neighboring element IDs, and callbacks for focus and selection events.
class FocusElement extends Equatable {
  /// Unique identifier for this element
  final String id;

  /// ID of the element to focus when navigating left, or null if none
  final String? leftId;

  /// ID of the element to focus when navigating right, or null if none
  final String? rightId;

  /// ID of the element to focus when navigating up, or null if none
  final String? upId;

  /// ID of the element to focus when navigating down, or null if none
  final String? downId;

  /// Whether this element is currently focused
  final bool isFocused;

  /// Whether this element is currently selected
  final bool isSelected;

  /// Time when this element was last focused
  final DateTime? lastFocusedTime;

  /// Indicates if this element is registered and ready for navigation
  final bool isRegistered;

  /// The key used to reference this widget in the Flutter widget tree
  final GlobalKey? elementKey;

  /// The render box of this element when rendered
  final RenderBox? renderBox;

  /// Constructor
  const FocusElement({
    required this.id,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    this.isFocused = false,
    this.isSelected = false,
    this.lastFocusedTime,
    this.isRegistered = false,
    this.elementKey,
    this.renderBox,
  });

  /// Create a copy of this element with modified properties
  FocusElement copyWith({
    String? id,
    String? leftId,
    String? rightId,
    String? upId,
    String? downId,
    bool? isFocused,
    bool? isSelected,
    DateTime? lastFocusedTime,
    bool? isRegistered,
    GlobalKey? elementKey,
    RenderBox? renderBox,
  }) {
    return FocusElement(
      id: id ?? this.id,
      leftId: leftId ?? this.leftId,
      rightId: rightId ?? this.rightId,
      upId: upId ?? this.upId,
      downId: downId ?? this.downId,
      isFocused: isFocused ?? this.isFocused,
      isSelected: isSelected ?? this.isSelected,
      lastFocusedTime: lastFocusedTime ?? this.lastFocusedTime,
      isRegistered: isRegistered ?? this.isRegistered,
      elementKey: elementKey ?? this.elementKey,
      renderBox: renderBox ?? this.renderBox,
    );
  }

  /// Mark this element as focused
  FocusElement focus() {
    return copyWith(
      isFocused: true,
      lastFocusedTime: DateTime.now(),
    );
  }

  /// Mark this element as unfocused
  FocusElement unfocus() {
    return copyWith(isFocused: false);
  }

  /// Mark this element as selected
  FocusElement select() {
    return copyWith(isSelected: true);
  }

  /// Mark this element as not selected
  FocusElement unselect() {
    return copyWith(isSelected: false);
  }

  /// Mark this element as registered
  FocusElement register({GlobalKey? key, RenderBox? box}) {
    return copyWith(
      isRegistered: true,
      elementKey: key ?? elementKey,
      renderBox: box ?? renderBox,
    );
  }

  /// Mark this element as unregistered
  FocusElement unregister() {
    return copyWith(isRegistered: false, elementKey: null, renderBox: null);
  }

  @override
  List<Object?> get props => [
        id,
        leftId,
        rightId,
        upId,
        downId,
        isFocused,
        isSelected,
        lastFocusedTime,
        isRegistered,
        elementKey,
        renderBox,
      ];

  @override
  String toString() => 'FocusElement(id: $id, isFocused: $isFocused)';
}
