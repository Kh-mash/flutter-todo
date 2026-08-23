import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/usecases/create_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/delete_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/get_tasks_by_list.dart';
import 'package:flutter_todo/features/task/domain/usecases/toggle_task_completion.dart';
import 'package:flutter_todo/features/task/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:flutter_todo/features/todo_list/presentation/pages/list_detail_page.dart';
import 'package:flutter_todo/features/task/presentation/widgets/quick_add_field.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

class MockGetTasksByList extends Mock implements GetTasksByList {}
class MockToggleTaskCompletion extends Mock implements ToggleTaskCompletion {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockCreateTask extends Mock implements CreateTask {}

void main() {
  late TaskListBloc bloc;
  late MockGetTasksByList mockGet;
  late MockCreateTask mockCreate;

  const tListId = 'list-1';
  final tTask = Task(
    id: '1',
    title: 'Test Task',
    listId: tListId,
    createdAt: DateTime(2026, 8, 23),
  );

  setUpAll(() {
    registerFallbackValue(tTask);
  });

  setUp(() {
    mockGet = MockGetTasksByList();
    mockCreate = MockCreateTask();
    when(() => mockGet(any()))
        .thenAnswer((_) => Stream.value(Right([tTask])));
    when(() => mockCreate(any())).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => bloc.close());

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<TaskListBloc>.value(
        value: bloc,
        child: const ListDetailPage(listId: tListId, listName: 'Groceries'),
      ),
    );
  }

  group('ListDetailPage', () {
    testWidgets('renders list name as title', (tester) async {
      bloc = TaskListBloc(
        getTasksByList: mockGet,
        toggleTaskCompletion: MockToggleTaskCompletion(),
        deleteTask: MockDeleteTask(),
        createTask: mockCreate,
      );
      await tester.pumpWidget(buildSubject());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('shows task after subscription', (tester) async {
      bloc = TaskListBloc(
        getTasksByList: mockGet,
        toggleTaskCompletion: MockToggleTaskCompletion(),
        deleteTask: MockDeleteTask(),
        createTask: mockCreate,
      );
      await tester.pumpWidget(buildSubject());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('has quick add field', (tester) async {
      bloc = TaskListBloc(
        getTasksByList: mockGet,
        toggleTaskCompletion: MockToggleTaskCompletion(),
        deleteTask: MockDeleteTask(),
        createTask: mockCreate,
      );
      await tester.pumpWidget(buildSubject());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(QuickAddField), findsOneWidget);
    });

    testWidgets('quick add submits create with page list id', (tester) async {
      bloc = TaskListBloc(
        getTasksByList: mockGet,
        toggleTaskCompletion: MockToggleTaskCompletion(),
        deleteTask: MockDeleteTask(),
        createTask: mockCreate,
      );
      await tester.pumpWidget(buildSubject());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Buy milk');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final created =
          verify(() => mockCreate(captureAny())).captured.single as Task;
      expect(created.title, 'Buy milk');
      expect(created.listId, tListId);
    });
  });
}
