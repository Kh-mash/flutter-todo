import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/theme_preference.dart';
import '../../../domain/usecases/get_theme_preference.dart';
import '../../../domain/usecases/save_theme_preference.dart';
import 'theme_event.dart';
import 'theme_state.dart';

@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({
    required this._getThemePreference,
    required this._saveThemePreference,
  }) : super(const ThemeState()) {
    on<ThemeSubscriptionRequested>(_onSubscriptionRequested);
    on<ThemeCycled>(_onCycled);
  }

  final GetThemePreference _getThemePreference;
  final SaveThemePreference _saveThemePreference;

  Future<void> _onSubscriptionRequested(
    ThemeSubscriptionRequested event,
    Emitter<ThemeState> emit,
  ) async {
    await for (final result in _getThemePreference()) {
      result.fold(
        (_) {},
        (preference) {
          if (preference != state.preference) {
            emit(state.copyWith(preference: preference));
          }
        },
      );
    }
  }

  Future<void> _onCycled(
    ThemeCycled event,
    Emitter<ThemeState> emit,
  ) async {
    final next = switch (state.preference) {
      ThemePreference.system => ThemePreference.light,
      ThemePreference.light => ThemePreference.dark,
      ThemePreference.dark => ThemePreference.system,
    };
    emit(state.copyWith(preference: next));
    await _saveThemePreference(next);
  }
}
