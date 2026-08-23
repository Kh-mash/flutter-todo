import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/usecases/create_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/delete_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/get_tasks_by_list.dart';
import 'package:flutter_todo/features/task/domain/usecases/toggle_task_completion.dart';
import 'package:flutter_todo/features/task/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:flutter_todo/features/task/presentation/bloc/task_list/task_list_event.dart';
import 'package:flutter_todo/features/task/presentation/bloc/task_list/task_list_state.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

class MockGetTasksByList extends Mock implements GetTasksByList {}
class MockToggleTaskCompletion extends Mock implements ToggleTaskCompletion {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockCreateTask extends Mock implements CreateTask {}

void main() {
  late MockGetTasksByList mockGetTasksByList;
  late MockToggleTaskCompletion mockToggle;
  late MockDeleteTask mockDelete;
  late MockCreateTask mockCreate;

  const tListId = 'list-1';
  final now = DateTime(2026, 8, 23);
  final tTask = Task(id: '1', title: 'Test', listId: tListId, createdAt: now);
  final tTasks = <Task>[tTask];

  setUpAll(() {
    registerFallbackValue(tTask);
    registerFallbackValue(
      Task(id: 'x', title: 'x', listId: 'x', createdAt: now),
    );
  });

  setUp(() {
    mockGetTasksByList = MockGetTasksByList();
    mockToggle = MockToggleTaskCompletion();
    mockDelete = MockDeleteTask();
    mockCreate = MockCreateTask();

    when(() => mockGetTasksByList(any()))
        .thenAnswer((_) => Stream.value(Right(tTasks)));
    when(() => mockToggle(task: any(named: 'task'), isCompleted: any(named: 'isCompleted')))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockDelete(any())).thenAnswer((_) async => const Right(unit));
    when(() => mockCreate(any())).thenAnswer((_) async => const Right(unit));
  });

  TaskListBloc buildBloc() => TaskListBloc(
        getTasksByList: mockGetTasksByList,
        toggleTaskCompletion: mockToggle,
        deleteTask: mockDelete,
        createTask: mockCreate,
      );

  group('TaskListBloc', () {
    test('initial state is TaskListStatus.initial with empty tasks', () {
      expect(buildBloc().state.status, TaskListStatus.initial);
      expect(buildBloc().state.tasks, isEmpty);
    });

    blocTest<TaskListBloc, TaskListState>(
      'emits loading then success on subscription',
      build: () => buildBloc(),
      act: (bloc) =>
          bloc.add(const TaskListSubscriptionRequested(tListId)),
      expect: () => [
        const TaskListState(status: TaskListStatus.loading),
        TaskListState(status: TaskListStatus.success, tasks: tTasks),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'emits failure when stream emits a failure',
      build: () {
        when(() => mockGetTasksByList(any())).thenAnswer(
          (_) => Stream.value(const Left(CacheFailure('db error'))),
        );
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const TaskListSubscriptionRequested(tListId)),
      expect: () => [
        const TaskListState(status: TaskListStatus.loading),
        const TaskListState(
          status: TaskListStatus.failure,
          errorMessage: 'db error',
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'creates task in the subscribed list and not My Day on quick add',
      build: () => buildBloc(),
      act: (bloc) {
        bloc.add(const TaskListSubscriptionRequested(tListId));
        bloc.add(const TaskListQuickAddSubmitted('New Task'));
      },
      verify: (_) {
        final created =
            verify(() => mockCreate(captureAny())).captured.single as Task;
        expect(created.title, 'New Task');
        expect(created.listId, tListId);
        expect(created.isMyDay, isFalse);
      },
    );

    blocTest<TaskListBloc, TaskListState>(
      'ignores empty quick add',
      build: () => buildBloc(),
      act: (bloc) =>
          bloc.add(const TaskListQuickAddSubmitted('   ')),
      verify: (_) => verifyNever(() => mockCreate(any())),
    );

    blocTest<TaskListBloc, TaskListState>(
      'calls toggle on completion event',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(
        TaskListTaskCompletionToggled(tTask, isCompleted: true),
      ),
      verify: (_) => verify(
        () => mockToggle(task: tTask, isCompleted: true),
      ).called(1),
    );

    blocTest<TaskListBloc, TaskListState>(
      'calls delete on delete event',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(TaskListTaskDeleted(tTask)),
      verify: (_) => verify(() => mockDelete('1')).called(1),
    );

    blocTest<TaskListBloc, TaskListState>(
      'toggles showCompleted',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const TaskListShowCompletedToggled()),
      expect: () => [const TaskListState(showCompleted: false)],
    );
  });
}
