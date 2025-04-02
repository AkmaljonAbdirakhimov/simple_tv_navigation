import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/tv_focus_direction.dart';
import 'tv_navigation_bloc.dart';

extension TvNavigationBlocExtension on BuildContext {
  TvNavigationBloc get tvBloc => BlocProvider.of<TvNavigationBloc>(this);

  void moveFocus(TvFocusDirection direction) {
    tvBloc.add(MoveFocus(direction));
  }

  void setFocus(String id) {
    tvBloc.add(SetFocus(id));
  }

  void selectCurrent() {
    tvBloc.add(const Select());
  }

  void setTvNavigationEnabled(bool enabled) {
    tvBloc.add(SetEnabled(enabled));
  }

  void enableFocus() {
    tvBloc.add(SetExcludeFocusEnabled(false));
  }

  void disableFocus() {
    tvBloc.add(SetExcludeFocusEnabled(true));
  }

  TvNavigationState get tvState => tvBloc.state;

  bool isElementFocused(String id) => tvState.isElementFocused(id);

  bool hasElement(String id) => tvState.hasElement(id);

  bool get isTvNavigationEnabled => tvState.enabled;
}
