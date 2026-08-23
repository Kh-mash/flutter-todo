import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/app/di/injector.dart';
import 'package:flutter_todo/app/view/app.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/save_theme_preference.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/usecases/create_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/delete_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/get_my_day_tasks.dart';
import 'package:flutter_todo/features/task/domain/usecases/toggle_task_completion.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_bloc.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/create_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/delete_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/rename_list.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/watch_lists.dart';
import 'package:flutter_todo/features/todo_list/presentation/bloc/lists_overview/lists_overview_bloc.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

class MockGetThemePreference extends Mock implements GetThemePreference {}
class MockSaveThemePreference extends Mock implements SaveThemePreference {}
class MockGetMyDayTasks extends Mock implements GetMyDayTasks {}
class MockToggleTaskCompletion extends Mock implements ToggleTaskCompletion {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockCreateTask extends Mock implements CreateTask {}
class MockWatchLists extends Mock implements WatchLists {}
class MockCreateList extends Mock implements CreateList {}
class MockRenameList extends Mock implements RenameList {}
class MockDeleteList extends Mock implements DeleteList {}

void main() {
  late MockGetThemePreference mockGetThemePreference;

  setUpAll(() {
    registerFallbackValue(ThemePreference.system);
    registerFallbackValue(
      Task(id: 'x', title: 'x', listId: 'x', createdAt: DateTime(2026)),
    );
  });

  setUp(() {
    mockGetThemePreference = MockGetThemePreference();

    final mockSave = MockSaveThemePreference();
    when(() => mockSave(any())).thenAnswer((_) async => const Right(unit));

    final mockGetMyDayTasks = MockGetMyDayTasks();
    when(() => mockGetMyDayTasks())
        .thenAnswer((_) => Stream.value(const Right(<Task>[])));

    final mockWatchLists = MockWatchLists();
    when(() => mockWatchLists())
        .thenAnswer((_) => Stream.value(const Right(<ListSummary>[])));

    getIt
      ..registerLazySingleton<GetThemePreference>(() => mockGetThemePreference)
      ..registerLazySingleton<SaveThemePreference>(() => mockSave)
      ..registerLazySingleton<ThemeBloc>(
        () => ThemeBloc(
          getThemePreference: mockGetThemePreference,
          saveThemePreference: mockSave,
        ),
      )
      ..registerLazySingleton<GetMyDayTasks>(() => mockGetMyDayTasks)
      ..registerLazySingleton<ToggleTaskCompletion>(
          () => MockToggleTaskCompletion())
      ..registerLazySingleton<DeleteTask>(() => MockDeleteTask())
      ..registerLazySingleton<CreateTask>(() => MockCreateTask())
      ..registerLazySingleton<MyDayBloc>(
        () => MyDayBloc(
          getMyDayTasks: mockGetMyDayTasks,
          toggleTaskCompletion: MockToggleTaskCompletion(),
          deleteTask: MockDeleteTask(),
          createTask: MockCreateTask(),
          defaultList: TodoList(
            id: 'default-list-id',
            name: 'Tasks',
            createdAt: DateTime(2026),
          ),
        ),
      )
      ..registerLazySingleton<WatchLists>(() => mockWatchLists)
      ..registerLazySingleton<CreateList>(() => MockCreateList())
      ..registerLazySingleton<RenameList>(() => MockRenameList())
      ..registerLazySingleton<DeleteList>(() => MockDeleteList())
      ..registerLazySingleton<ListsOverviewBloc>(
        () => ListsOverviewBloc(
          watchLists: mockWatchLists,
          createList: MockCreateList(),
          renameList: MockRenameList(),
          deleteList: MockDeleteList(),
        ),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<ThemeMode> pumpAndReadThemeMode(
    WidgetTester tester,
    ThemePreference persisted,
  ) async {
    when(() => mockGetThemePreference()).thenAnswer(
      (_) => Stream.value(Right(persisted)),
    );
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    return tester
            .widget<MaterialApp>(find.byType(MaterialApp))
            .themeMode ??
        ThemeMode.system;
  }

  group('App theme wiring', () {
    testWidgets('uses dark mode when persisted preference is dark',
        (tester) async {
      final themeMode =
          await pumpAndReadThemeMode(tester, ThemePreference.dark);
      expect(themeMode, ThemeMode.dark);
    });

    testWidgets('uses light mode when persisted preference is light',
        (tester) async {
      final themeMode =
          await pumpAndReadThemeMode(tester, ThemePreference.light);
      expect(themeMode, ThemeMode.light);
    });

    testWidgets('follows system when persisted preference is system',
        (tester) async {
      final themeMode =
          await pumpAndReadThemeMode(tester, ThemePreference.system);
      expect(themeMode, ThemeMode.system);
    });
  });
}
