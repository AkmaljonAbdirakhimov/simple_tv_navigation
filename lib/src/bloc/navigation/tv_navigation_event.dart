part of 'tv_navigation_bloc.dart';

abstract class TvNavigationEvent extends Equatable {
  const TvNavigationEvent();

  @override
  List<Object?> get props => [];
}

class RegisterElement extends TvNavigationEvent {
  final TvFocusElement element;

  const RegisterElement(this.element);

  @override
  List<Object?> get props => [element.id];
}

class UnregisterElement extends TvNavigationEvent {
  final String id;

  const UnregisterElement(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateElement extends TvNavigationEvent {
  final TvFocusElement element;

  const UpdateElement(this.element);

  @override
  List<Object?> get props => [element.id];
}

class SetFocus extends TvNavigationEvent {
  final String id;

  const SetFocus(this.id);

  @override
  List<Object?> get props => [id];
}

class MoveFocus extends TvNavigationEvent {
  final TvFocusDirection direction;

  const MoveFocus(this.direction);

  @override
  List<Object?> get props => [direction];
}

class Select extends TvNavigationEvent {
  const Select();
}

class SetEnabled extends TvNavigationEvent {
  final bool enabled;

  const SetEnabled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SetExcludeFocusEnabled extends TvNavigationEvent {
  final bool enabled;

  const SetExcludeFocusEnabled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
