import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/usecases/create_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/delete_task.dart';
import 'package:flutter_todo/features/task/domain/usecases/get_my_day_tasks.dart';
import 'package:flutter_todo/features/task/domain/usecases/toggle_task_completion.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_bloc.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_event.dart';
import 'package:flutter_todo/features/task/presentation/bloc/my_day/my_day_state.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

class MockGetMyDayTasks extends Mock implements GetMyDayTasks {}
class MockToggleTaskCompletion extends Mock implements ToggleTaskCompletion {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockCreateTask extends Mock implements CreateTask {}

void main() {
  late MyDayBloc bloc;
  late MockGetMyDayTasks mockGetMyDayTasks;
  late MockToggleTaskCompletion mockToggle;
  late MockDeleteTask mockDelete;
  late MockCreateTask mockCreate;

  final now = DateTime(2026, 8, 22);
  final tTask = Task(id: '1', title: 'Test', listId: 'L', createdAt: now);
  final tTasks = <Task>[tTask];

  setUpAll(() {
    registerFallbackValue(tTask);
  });

  setUp(() {
    mockGetMyDayTasks = MockGetMyDayTasks();
    mockToggle = MockToggleTaskCompletion();
    mockDelete = MockDeleteTask();
    mockCreate = MockCreateTask();

    when(() => mockGetMyDayTasks()).thenAnswer(
      (_) => Stream.value(Right(tTasks)),
    );
    when(() => mockToggle(task: any(named: 'task'), isCompleted: any(named: 'isCompleted')))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockDelete(any())).thenAnswer((_) async => const Right(unit));
    when(() => mockCreate(any())).thenAnswer((_) async => const Right(unit));

    bloc = MyDayBloc(
      getMyDayTasks: mockGetMyDayTasks,
      toggleTaskCompletion: mockToggle,
      deleteTask: mockDelete,
      createTask: mockCreate,
    );
  });

  tearDown(() => bloc.close());

  group('MyDayBloc', () {
    test('initial state is MyDayStatus.initial with empty tasks', () {
      expect(bloc.state.status, MyDayStatus.initial);
      expect(bloc.state.tasks, isEmpty);
    });

    blocTest<MyDayBloc, MyDayState>(
      'emits loading then success on subscription',
      build: () => bloc,
      act: (bloc) => bloc.add(const MyDaySubscriptionRequested()),
      expect: () => [
        const MyDayState(status: MyDayStatus.loading),
        MyDayState(status: MyDayStatus.success, tasks: tTasks),
      ],
    );

    blocTest<MyDayBloc, MyDayState>(
      'emits failure when stream errors',
      build: () {
        when(() => mockGetMyDayTasks()).thenAnswer(
          (_) => Stream.value(const Left(CacheFailure('db error'))),
        );
        return MyDayBloc(
          getMyDayTasks: mockGetMyDayTasks,
          toggleTaskCompletion: mockToggle,
          deleteTask: mockDelete,
          createTask: mockCreate,
        );
      },
      act: (bloc) => bloc.add(const MyDaySubscriptionRequested()),
      expect: () => [
        const MyDayState(status: MyDayStatus.loading),
        const MyDayState(
          status: MyDayStatus.failure,
          errorMessage: 'db error',
        ),
      ],
    );

    blocTest<MyDayBloc, MyDayState>(
      'calls toggle on completion event',
      build: () => bloc,
      act: (bloc) => bloc.add(
        MyDayTaskCompletionToggled(tTask, isCompleted: true),
      ),
      verify: (_) => verify(
        () => mockToggle(task: tTask, isCompleted: true),
      ).called(1),
    );

    blocTest<MyDayBloc, MyDayState>(
      'calls delete on delete event',
      build: () => bloc,
      act: (bloc) => bloc.add(MyDayTaskDeleted(tTask)),
      verify: (_) => verify(() => mockDelete('1')).called(1),
    );

    blocTest<MyDayBloc, MyDayState>(
      'calls create on quick add',
      build: () => bloc,
      act: (bloc) => bloc.add(const MyDayQuickAddSubmitted('New Task', listId: 'L')),
      verify: (_) => verify(() => mockCreate(any())).called(1),
    );

    blocTest<MyDayBloc, MyDayState>(
      'ignores empty quick add',
      build: () => bloc,
      act: (bloc) => bloc.add(const MyDayQuickAddSubmitted('  ', listId: 'L')),
      verify: (_) => verifyNever(() => mockCreate(any())),
    );

    blocTest<MyDayBloc, MyDayState>(
      'toggles showCompleted',
      build: () => bloc,
      act: (bloc) => bloc.add(const MyDayShowCompletedToggled()),
      expect: () => [const MyDayState(showCompleted: false)],
    );
  });
}
