import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/save_theme_preference.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_todo/features/settings/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/create_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/delete_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/rename_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/watch_lists.dart';
import 'package:flutter_todo/features/todo_list/presentation/bloc/lists_overview/lists_overview_bloc.dart';
import 'package:flutter_todo/features/todo_list/presentation/pages/lists_overview_page.dart';
import 'package:fpdart/fpdart.dart' show Right, unit;
import 'package:mocktail/mocktail.dart';

class MockGetThemePreference extends Mock implements GetThemePreference {}
class MockSaveThemePreference extends Mock implements SaveThemePreference {}
class MockWatchLists extends Mock implements WatchLists {}
class MockCreateList extends Mock implements CreateList {}
class MockRenameList extends Mock implements RenameList {}
class MockDeleteList extends Mock implements DeleteList {}

void main() {
  late ThemeBloc themeBloc;
  late ListsOverviewBloc bloc;

  setUpAll(() {
    registerFallbackValue(ThemePreference.system);
  });

  setUp(() {
    final mockGetThemePreference = MockGetThemePreference();
    when(() => mockGetThemePreference()).thenAnswer(
      (_) => Stream.value(const Right(ThemePreference.system)),
    );
    final mockSaveThemePreference = MockSaveThemePreference();
    when(() => mockSaveThemePreference(any()))
        .thenAnswer((_) async => const Right(unit));
    themeBloc = ThemeBloc(
      getThemePreference: mockGetThemePreference,
      saveThemePreference: mockSaveThemePreference,
    );

    final mockWatchLists = MockWatchLists();
    when(() => mockWatchLists())
        .thenAnswer((_) => Stream.value(const Right(<ListSummary>[])));
    bloc = ListsOverviewBloc(
      watchLists: mockWatchLists,
      createList: MockCreateList(),
      renameList: MockRenameList(),
      deleteList: MockDeleteList(),
    );
  });

  tearDown(() {
    bloc.close();
    themeBloc.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>.value(value: themeBloc),
          BlocProvider<ListsOverviewBloc>.value(value: bloc),
        ],
        child: const ListsOverviewPage(),
      ),
    );
  }

  testWidgets('renders Lists title', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.text('Lists'), findsOneWidget);
  });

  testWidgets('shows theme toggle button in app bar', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.byType(ThemeToggleButton), findsOneWidget);
  });
}
