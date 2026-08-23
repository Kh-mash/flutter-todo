import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/usecases/save_theme_preference.dart';
import 'package:flutter_todo/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_todo/features/settings/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/usecases/create_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/delete_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/get_my_day_tasks.dart';
import 'package:flutter_todo/features/task/domain/usecases/toggle_task_completion.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_bloc.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_event.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_state.dart';
import 'package:flutter_todo/features/task/presentation/pages/my_day_page.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';
import 'package:fpdart/fpdart.dart' show Right, unit;
import 'package:mocktail/mocktail.dart';

class MockGetMyDayTasks extends Mock implements GetMyDayTasks {}
class MockToggleTaskCompletion extends Mock implements ToggleTaskCompletion {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockCreateTask extends Mock implements CreateTask {}
class MockGetThemePreference extends Mock implements GetThemePreference {}
class MockSaveThemePreference extends Mock implements SaveThemePreference {}

void main() {
  late MyDayBloc bloc;
  late ThemeBloc themeBloc;
  late MockGetMyDayTasks mockGet;

  final now = DateTime(2026, 8, 22);
  final tTask = Task(id: '1', title: 'Test Task', listId: 'L', createdAt: now);
  final defaultList = TodoList(
    id: 'default-list-id',
    name: 'Tasks',
    createdAt: now,
  );

  setUpAll(() {
    registerFallbackValue(tTask);
    registerFallbackValue(const MyDayState());
    registerFallbackValue(ThemePreference.system);
  });

  setUp(() {
    mockGet = MockGetMyDayTasks();
    when(() => mockGet()).thenAnswer((_) => Stream.value(Right([tTask])));

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

    bloc = MyDayBloc(
      getMyDayTasks: mockGet,
      toggleTaskCompletion: MockToggleTaskCompletion(),
      deleteTask: MockDeleteTask(),
      createTask: MockCreateTask(),
      defaultList: defaultList,
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
          BlocProvider<MyDayBloc>.value(value: bloc),
        ],
        child: const MyDayPage(),
      ),
    );
  }

  testWidgets('renders My Day title', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.text('My Day'), findsOneWidget);
  });

  testWidgets('shows theme toggle button in app bar', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.byType(ThemeToggleButton), findsOneWidget);
  });

  testWidgets('renders task title after subscription', (tester) async {
    await tester.pumpWidget(buildSubject());
    bloc.add(const MyDaySubscriptionRequested());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Test Task'), findsOneWidget);
  });
}
