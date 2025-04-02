import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'tv_focus_direction.dart';

class TvFocusElement extends Equatable {
  final String id;
  final String? leftId;
  final String? rightId;
  final String? upId;
  final String? downId;
  final String? Function()? dynamicLeftId;
  final String? Function()? dynamicRightId;
  final String? Function()? dynamicUpId;
  final String? Function()? dynamicDownId;
  final bool autofocus;
  final bool showDefaultFocusDecoration;
  final VoidCallback? onFocus;
  final VoidCallback? onSelect;
  final void Function(TvFocusDirection direction)? onBlur;
  final void Function(TvFocusDirection direction)? onNavigationRequest;

  const TvFocusElement({
    required this.id,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    this.dynamicLeftId,
    this.dynamicRightId,
    this.dynamicUpId,
    this.dynamicDownId,
    this.autofocus = false,
    this.showDefaultFocusDecoration = false,
    this.onFocus,
    this.onSelect,
    this.onBlur,
    this.onNavigationRequest,
  });

  TvFocusElement copyWith({
    String? id,
    String? leftId,
    String? rightId,
    String? downId,
    String? upId,
    String? Function()? dynamicLeftId,
    String? Function()? dynamicRightId,
    String? Function()? dynamicUpId,
    String? Function()? dynamicDownId,
    bool? autofocus,
    bool? showDefaultFocusDecoration,
    VoidCallback? onFocus,
    VoidCallback? onSelect,
    void Function(TvFocusDirection direction)? onBlur,
    void Function(TvFocusDirection direction)? onNavigationRequest,
  }) {
    return TvFocusElement(
      id: id ?? this.id,
      leftId: leftId ?? this.leftId,
      rightId: rightId ?? this.rightId,
      upId: upId ?? this.upId,
      downId: downId ?? this.downId,
      dynamicLeftId: dynamicLeftId ?? this.dynamicLeftId,
      dynamicRightId: dynamicRightId ?? this.dynamicRightId,
      dynamicUpId: dynamicUpId ?? this.dynamicUpId,
      dynamicDownId: dynamicDownId ?? this.dynamicDownId,
      autofocus: autofocus ?? this.autofocus,
      showDefaultFocusDecoration:
          showDefaultFocusDecoration ?? this.showDefaultFocusDecoration,
      onFocus: onFocus ?? this.onFocus,
      onSelect: onSelect ?? this.onSelect,
      onBlur: onBlur ?? this.onBlur,
      onNavigationRequest: onNavigationRequest ?? this.onNavigationRequest,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      leftId,
      rightId,
      upId,
      downId,
      dynamicLeftId,
      dynamicRightId,
      dynamicUpId,
      dynamicDownId,
      autofocus,
      showDefaultFocusDecoration,
      onFocus,
      onSelect,
      onBlur,
      onNavigationRequest,
    ];
  }
}
