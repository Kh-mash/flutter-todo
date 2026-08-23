import 'package:equatable/equatable.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeSubscriptionRequested extends ThemeEvent {
  const ThemeSubscriptionRequested();
}

class ThemeCycled extends ThemeEvent {
  const ThemeCycled();
}
