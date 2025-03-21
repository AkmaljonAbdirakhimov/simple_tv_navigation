import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';
import 'debug_overlay.dart';

class DebugFocusable extends StatelessWidget {
  final String id;
  final String? leftId;
  final String? rightId;
  final String? upId;
  final String? downId;
  final Widget Function(BuildContext, bool, bool, Widget?) focusBuilder;
  final Widget child;
  final VoidCallback? onSelect;
  final bool showDebugInfo;
  final bool autoFocus;

  const DebugFocusable({
    super.key,
    required this.id,
    this.leftId,
    this.rightId,
    this.upId,
    this.downId,
    required this.focusBuilder,
    required this.child,
    this.onSelect,
    this.showDebugInfo = true,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TVFocusable(
          id: id,
          leftId: leftId,
          rightId: rightId,
          upId: upId,
          downId: downId,
          focusBuilder: focusBuilder,
          onSelect: onSelect,
          autoFocus: autoFocus,
          child: child,
        ),
        if (showDebugInfo)
          DebugOverlay(
            id: id,
            leftId: leftId,
            rightId: rightId,
            upId: upId,
            downId: downId,
          ),
      ],
    );
  }
}
