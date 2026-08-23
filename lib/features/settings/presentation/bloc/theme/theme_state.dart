import 'package:equatable/equatable.dart';

import '../../../domain/entities/theme_preference.dart';

class ThemeState extends Equatable {
  const ThemeState({this.preference = ThemePreference.system});

  final ThemePreference preference;

  ThemeState copyWith({ThemePreference? preference}) =>
      ThemeState(preference: preference ?? this.preference);

  @override
  List<Object?> get props => [preference];
}
