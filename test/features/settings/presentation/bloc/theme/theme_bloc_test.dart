import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/save_theme_preference.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_event.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetThemePreference extends Mock implements GetThemePreference {}
class MockSaveThemePreference extends Mock implements SaveThemePreference {}

void main() {
  late MockGetThemePreference mockGetThemePreference;
  late MockSaveThemePreference mockSaveThemePreference;

  setUpAll(() {
    registerFallbackValue(ThemePreference.system);
  });

  setUp(() {
    mockGetThemePreference = MockGetThemePreference();
    mockSaveThemePreference = MockSaveThemePreference();
    when(() => mockGetThemePreference()).thenAnswer(
      (_) => Stream.value(const Right(ThemePreference.system)),
    );
    when(() => mockSaveThemePreference(any())).thenAnswer(
      (_) async => const Right(unit),
    );
  });

  ThemeBloc buildBloc() => ThemeBloc(
        getThemePreference: mockGetThemePreference,
        saveThemePreference: mockSaveThemePreference,
      );

  group('ThemeBloc', () {
    test('initial state is system preference', () {
      expect(buildBloc().state.preference, ThemePreference.system);
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits persisted preference on subscription',
      build: () {
        when(() => mockGetThemePreference()).thenAnswer(
          (_) => Stream.value(const Right(ThemePreference.dark)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ThemeSubscriptionRequested()),
      expect: () => [const ThemeState(preference: ThemePreference.dark)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'keeps current state when watch stream emits a failure',
      build: () {
        when(() => mockGetThemePreference()).thenAnswer(
          (_) => Stream.value(const Left(CacheFailure('db error'))),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ThemeSubscriptionRequested()),
      expect: () => [],
    );

    blocTest<ThemeBloc, ThemeState>(
      'cycles system -> light and saves',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const ThemeCycled()),
      expect: () => [const ThemeState(preference: ThemePreference.light)],
      verify: (_) => verify(
        () => mockSaveThemePreference(ThemePreference.light),
      ).called(1),
    );

    blocTest<ThemeBloc, ThemeState>(
      'cycles light -> dark and saves',
      build: () => buildBloc(),
      seed: () => const ThemeState(preference: ThemePreference.light),
      act: (bloc) => bloc.add(const ThemeCycled()),
      expect: () => [const ThemeState(preference: ThemePreference.dark)],
      verify: (_) => verify(
        () => mockSaveThemePreference(ThemePreference.dark),
      ).called(1),
    );

    blocTest<ThemeBloc, ThemeState>(
      'cycles dark -> system and saves',
      build: () => buildBloc(),
      seed: () => const ThemeState(preference: ThemePreference.dark),
      act: (bloc) => bloc.add(const ThemeCycled()),
      expect: () => [const ThemeState(preference: ThemePreference.system)],
      verify: (_) => verify(
        () => mockSaveThemePreference(ThemePreference.system),
      ).called(1),
    );
  });
}
