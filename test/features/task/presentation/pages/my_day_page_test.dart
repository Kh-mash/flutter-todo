import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/usecases/create_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/delete_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/get_my_day_tasks.dart';
import 'package:flutter_todo/features/task/domain/usecases/toggle_task_completion.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_bloc.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_event.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_state.dart';
import 'package:flutter_todo/features/task/presentation/pages/my_day_page.dart';
import 'package:fpdart/fpdart.dart' show Right;
import 'package:mocktail/mocktail.dart';

class MockGetMyDayTasks extends Mock implements GetMyDayTasks {}
class MockToggleTaskCompletion extends Mock implements ToggleTaskCompletion {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockCreateTask extends Mock implements CreateTask {}

void main() {
  late MyDayBloc bloc;
  late MockGetMyDayTasks mockGet;

  final now = DateTime(2026, 8, 22);
  final tTask = Task(id: '1', title: 'Test Task', listId: 'L', createdAt: now);

  setUpAll(() {
    registerFallbackValue(tTask);
    registerFallbackValue(const MyDayState());
  });

  setUp(() {
    mockGet = MockGetMyDayTasks();
    when(() => mockGet()).thenAnswer((_) => Stream.value(Right([tTask])));

    bloc = MyDayBloc(
      getMyDayTasks: mockGet,
      toggleTaskCompletion: MockToggleTaskCompletion(),
      deleteTask: MockDeleteTask(),
      createTask: MockCreateTask(),
    );
  });

  tearDown(() => bloc.close());

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider.value(
        value: bloc,
        child: const MyDayPage(),
      ),
    );
  }

  testWidgets('renders My Day title', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.text('My Day'), findsOneWidget);
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
