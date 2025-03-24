import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'focus_direction.dart';

/// Represents a navigable element in the TV navigation system.
///
/// Each element has a unique [id] and optional references to
/// neighboring elements in all four directions.
class TVFocusElement extends Equatable {
  /// Unique identifier for this element
  final String id;

  /// ID of the element to the left, if any
  final String? leftId;

  /// ID of the element to the right, if any
  final String? rightId;

  /// ID of the element above, if any
  final String? upId;

  /// ID of the element below, if any
  final String? downId;

  /// Callback triggered when this element is selected
  final VoidCallback? onSelect;

  /// Callback triggered when this element receives focus
  final VoidCallback? onFocus;

  /// Callback triggered when this element loses focus
  /// The direction parameter indicates which direction the focus moved
  final void Function(FocusDirection? direction)? onBlur;

  /// Creates a new TV focus element.
  const TVFocusElement({
    required this.id,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    this.onSelect,
    this.onFocus,
    this.onBlur,
  });

  /// Creates a copy of this element with the specified fields replaced with new values.
  TVFocusElement copyWith({
    String? id,
    String? leftId,
    String? rightId,
    String? upId,
    String? downId,
    VoidCallback? onSelect,
    VoidCallback? onFocus,
    void Function(FocusDirection? direction)? onBlur,
    bool? clearLeftId,
    bool? clearRightId,
    bool? clearUpId,
    bool? clearDownId,
    bool? clearOnSelect,
    bool? clearOnFocus,
    bool? clearOnBlur,
  }) {
    return TVFocusElement(
      id: id ?? this.id,
      leftId: clearLeftId == true ? null : (leftId ?? this.leftId),
      rightId: clearRightId == true ? null : (rightId ?? this.rightId),
      upId: clearUpId == true ? null : (upId ?? this.upId),
      downId: clearDownId == true ? null : (downId ?? this.downId),
      onSelect: clearOnSelect == true ? null : (onSelect ?? this.onSelect),
      onFocus: clearOnFocus == true ? null : (onFocus ?? this.onFocus),
      onBlur: clearOnBlur == true ? null : (onBlur ?? this.onBlur),
    );
  }

  @override
  List<Object?> get props => [id, leftId, rightId, upId, downId];

  @override
  bool get stringify => true;
}
