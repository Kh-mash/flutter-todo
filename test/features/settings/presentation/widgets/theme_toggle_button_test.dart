import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/save_theme_preference.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_event.dart';
import 'package:flutter_todo/features/settings/presentation/widgets/theme_toggle_button.dart';
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

  Widget wrap(ThemeBloc bloc) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              BlocProvider<ThemeBloc>.value(
                value: bloc,
                child: const ThemeToggleButton(),
              ),
            ],
          ),
        ),
      );

  group('ThemeToggleButton', () {
    testWidgets('shows brightness_auto when preference is system',
        (tester) async {
      final bloc = ThemeBloc(
        getThemePreference: mockGetThemePreference,
        saveThemePreference: mockSaveThemePreference,
      );
      bloc.add(const ThemeSubscriptionRequested());
      await tester.pumpWidget(wrap(bloc));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Icon>(find.byType(Icon)).icon,
        Icons.brightness_auto,
      );
    });

    testWidgets('shows light_mode when preference is light', (tester) async {
      when(() => mockGetThemePreference()).thenAnswer(
        (_) => Stream.value(const Right(ThemePreference.light)),
      );
      final bloc = ThemeBloc(
        getThemePreference: mockGetThemePreference,
        saveThemePreference: mockSaveThemePreference,
      );
      bloc.add(const ThemeSubscriptionRequested());
      await tester.pumpWidget(wrap(bloc));
      await tester.pumpAndSettle();

      expect(tester.widget<Icon>(find.byType(Icon)).icon, Icons.light_mode);
    });

    testWidgets('shows dark_mode when preference is dark', (tester) async {
      when(() => mockGetThemePreference()).thenAnswer(
        (_) => Stream.value(const Right(ThemePreference.dark)),
      );
      final bloc = ThemeBloc(
        getThemePreference: mockGetThemePreference,
        saveThemePreference: mockSaveThemePreference,
      );
      bloc.add(const ThemeSubscriptionRequested());
      await tester.pumpWidget(wrap(bloc));
      await tester.pumpAndSettle();

      expect(tester.widget<Icon>(find.byType(Icon)).icon, Icons.dark_mode);
    });

    testWidgets('tapping cycles to next preference and persists it',
        (tester) async {
      when(() => mockGetThemePreference()).thenAnswer(
        (_) => Stream.value(const Right(ThemePreference.system)),
      );
      final bloc = ThemeBloc(
        getThemePreference: mockGetThemePreference,
        saveThemePreference: mockSaveThemePreference,
      );
      bloc.add(const ThemeSubscriptionRequested());
      await tester.pumpWidget(wrap(bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      verify(() =>
          mockSaveThemePreference(ThemePreference.light)).called(1);
      expect(tester.widget<Icon>(find.byType(Icon)).icon, Icons.light_mode);
    });
  });
}
