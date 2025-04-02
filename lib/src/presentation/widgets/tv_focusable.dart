import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../simple_tv_navigation.dart';

class TVFocusable extends StatefulWidget {
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
  final Widget? child;
  final Widget Function(
    BuildContext context,
    bool isFocused,
    Widget? child,
  )? builder;
  final VoidCallback? onFocus;
  final VoidCallback? onSelect;
  final void Function(TvFocusDirection direction)? onBlur;
  final void Function(TvFocusDirection direction)? onNavigationRequest;

  const TVFocusable({
    super.key,
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
    this.child,
    this.builder,
    this.onFocus,
    this.onSelect,
    this.onBlur,
    this.onNavigationRequest,
  });

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable> {
  late final TvNavigationBloc tvBloc;
  final focusKey = GlobalKey();

  VoidCallback? get _onSelect {
    return widget.onSelect != null
        ? () {
            if (mounted) {
              widget.onSelect!();
            }
          }
        : null;
  }

  @override
  void initState() {
    super.initState();
    tvBloc = context.tvBloc;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerElement();
    });
  }

  @override
  void didUpdateWidget(TVFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id ||
        oldWidget.leftId != widget.leftId ||
        oldWidget.rightId != widget.rightId ||
        oldWidget.upId != widget.upId ||
        oldWidget.downId != widget.downId ||
        oldWidget.dynamicLeftId != widget.dynamicLeftId ||
        oldWidget.dynamicRightId != widget.dynamicRightId ||
        oldWidget.dynamicUpId != widget.dynamicUpId ||
        oldWidget.dynamicDownId != widget.dynamicDownId ||
        oldWidget.autofocus != widget.autofocus ||
        oldWidget.onFocus != widget.onFocus ||
        oldWidget.onSelect != widget.onSelect ||
        oldWidget.onBlur != widget.onBlur ||
        oldWidget.onNavigationRequest != widget.onNavigationRequest) {
      final tvFocusElement = TvFocusElement(
        id: widget.id,
        leftId: widget.leftId,
        rightId: widget.rightId,
        upId: widget.upId,
        downId: widget.downId,
        dynamicLeftId: widget.dynamicLeftId,
        dynamicRightId: widget.dynamicRightId,
        dynamicUpId: widget.dynamicUpId,
        dynamicDownId: widget.dynamicDownId,
        autofocus: widget.autofocus,
        onFocus: widget.onFocus,
        onSelect: _onSelect,
        onBlur: widget.onBlur,
        onNavigationRequest: widget.onNavigationRequest,
      );

      tvBloc.add(UpdateElement(tvFocusElement));

      if (context.isElementFocused(widget.id)) {
        scrollToWidget();
      }
    }
  }

  void registerElement() {
    final tvFocusElement = TvFocusElement(
      id: widget.id,
      leftId: widget.leftId,
      rightId: widget.rightId,
      upId: widget.upId,
      downId: widget.downId,
      dynamicLeftId: widget.dynamicLeftId,
      dynamicRightId: widget.dynamicRightId,
      dynamicUpId: widget.dynamicUpId,
      dynamicDownId: widget.dynamicDownId,
      autofocus: widget.autofocus,
      onFocus: widget.onFocus,
      onSelect: _onSelect,
      onBlur: widget.onBlur,
      onNavigationRequest: widget.onNavigationRequest,
    );

    tvBloc.add(RegisterElement(tvFocusElement));
  }

  void unregisterElement() {
    tvBloc.add(UnregisterElement(widget.id));
  }

  void scrollToWidget() {
    final RenderObject? renderObject =
        focusKey.currentContext?.findRenderObject();

    if (renderObject != null) {
      Scrollable.ensureVisible(
        focusKey.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    unregisterElement();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TvNavigationBloc, TvNavigationState>(
      listenWhen: (previous, current) =>
          !previous.isElementFocused(widget.id) &&
          current.isElementFocused(widget.id) &&
          current.enabled,
      listener: (context, state) {
        scrollToWidget();
      },
      child: BlocSelector<TvNavigationBloc, TvNavigationState, bool>(
        selector: (state) => state.enabled && state.isElementFocused(widget.id),
        builder: (context, isFocused) {
          final childWidget = widget.child ??
              widget.builder?.call(context, isFocused, widget.child) ??
              const SizedBox();

          return _FocusDecoration(
            isFocused: isFocused && widget.showDefaultFocusDecoration,
            child: KeyedSubtree(
              key: focusKey,
              child: childWidget,
            ),
          );
        },
      ),
    );
  }
}

class _FocusDecoration extends StatelessWidget {
  final Widget child;
  final bool isFocused;
  const _FocusDecoration({
    required this.child,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isFocused
          ? BoxDecoration(border: Border.all(color: Colors.blue))
          : null,
      child: child,
    );
  }
}
