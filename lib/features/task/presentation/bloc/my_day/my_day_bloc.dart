import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/usecases/create_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/get_my_day_tasks.dart';
import '../../../domain/usecases/toggle_task_completion.dart';
import '../../../../todo_list/domain/entities/todo_list.dart';
import 'my_day_event.dart';
import 'my_day_state.dart';

@injectable
class MyDayBloc extends Bloc<MyDayEvent, MyDayState> {
  MyDayBloc({
    required this._getMyDayTasks,
    required this._toggleTaskCompletion,
    required this._deleteTask,
    required this._createTask,
    @Named('defaultTodoList') required this._defaultList,
  }) : super(const MyDayState()) {
    on<MyDaySubscriptionRequested>(_onSubscriptionRequested);
    on<MyDayTaskCompletionToggled>(_onTaskCompletionToggled);
    on<MyDayTaskDeleted>(_onTaskDeleted);
    on<MyDayQuickAddSubmitted>(_onQuickAddSubmitted);
    on<MyDayShowCompletedToggled>(_onShowCompletedToggled);
  }

  final GetMyDayTasks _getMyDayTasks;
  final ToggleTaskCompletion _toggleTaskCompletion;
  final DeleteTask _deleteTask;
  final CreateTask _createTask;
  final TodoList _defaultList;

  Future<void> _onSubscriptionRequested(
    MyDaySubscriptionRequested event,
    Emitter<MyDayState> emit,
  ) async {
    emit(state.copyWith(status: MyDayStatus.loading));
    await emit.forEach(
      _getMyDayTasks(),
      onData: (result) => result.fold(
        (failure) => state.copyWith(
          status: MyDayStatus.failure,
          errorMessage: failure.message,
        ),
        (tasks) => state.copyWith(
          status: MyDayStatus.success,
          tasks: tasks,
        ),
      ),
    );
  }

  Future<void> _onTaskCompletionToggled(
    MyDayTaskCompletionToggled event,
    Emitter<MyDayState> emit,
  ) async {
    await _toggleTaskCompletion(
      task: event.task,
      isCompleted: event.isCompleted,
    );
  }

  Future<void> _onTaskDeleted(
    MyDayTaskDeleted event,
    Emitter<MyDayState> emit,
  ) async {
    await _deleteTask(event.task.id);
  }

  Future<void> _onQuickAddSubmitted(
    MyDayQuickAddSubmitted event,
    Emitter<MyDayState> emit,
  ) async {
    if (event.title.trim().isEmpty) return;
    await _createTask(Task(
      id: const Uuid().v4(),
      title: event.title.trim(),
      listId: _defaultList.id,
      isMyDay: true,
      createdAt: DateTime.now(),
    ));
  }

  void _onShowCompletedToggled(
    MyDayShowCompletedToggled event,
    Emitter<MyDayState> emit,
  ) {
    emit(state.copyWith(showCompleted: !state.showCompleted));
  }
}
