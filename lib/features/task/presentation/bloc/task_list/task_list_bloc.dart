import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/usecases/create_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/get_tasks_by_list.dart';
import '../../../domain/usecases/toggle_task_completion.dart';
import 'task_list_event.dart';
import 'task_list_state.dart';

@injectable
class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  TaskListBloc({
    required this._getTasksByList,
    required this._toggleTaskCompletion,
    required this._deleteTask,
    required this._createTask,
  }) : super(const TaskListState()) {
    on<TaskListSubscriptionRequested>(_onSubscriptionRequested);
    on<TaskListTaskCompletionToggled>(_onTaskCompletionToggled);
    on<TaskListTaskDeleted>(_onTaskDeleted);
    on<TaskListQuickAddSubmitted>(_onQuickAddSubmitted);
    on<TaskListShowCompletedToggled>(_onShowCompletedToggled);
  }

  final GetTasksByList _getTasksByList;
  final ToggleTaskCompletion _toggleTaskCompletion;
  final DeleteTask _deleteTask;
  final CreateTask _createTask;

  String? _listId;

  Future<void> _onSubscriptionRequested(
    TaskListSubscriptionRequested event,
    Emitter<TaskListState> emit,
  ) async {
    _listId = event.listId;
    emit(state.copyWith(status: TaskListStatus.loading));
    await emit.forEach(
      _getTasksByList(event.listId),
      onData: (result) => result.fold(
        (failure) => state.copyWith(
          status: TaskListStatus.failure,
          errorMessage: failure.message,
        ),
        (tasks) => state.copyWith(
          status: TaskListStatus.success,
          tasks: tasks,
        ),
      ),
    );
  }

  Future<void> _onTaskCompletionToggled(
    TaskListTaskCompletionToggled event,
    Emitter<TaskListState> emit,
  ) async {
    await _toggleTaskCompletion(
      task: event.task,
      isCompleted: event.isCompleted,
    );
  }

  Future<void> _onTaskDeleted(
    TaskListTaskDeleted event,
    Emitter<TaskListState> emit,
  ) async {
    await _deleteTask(event.task.id);
  }

  Future<void> _onQuickAddSubmitted(
    TaskListQuickAddSubmitted event,
    Emitter<TaskListState> emit,
  ) async {
    if (event.title.trim().isEmpty || _listId == null) return;
    await _createTask(Task(
      id: const Uuid().v4(),
      title: event.title.trim(),
      listId: _listId!,
      createdAt: DateTime.now(),
    ));
  }

  void _onShowCompletedToggled(
    TaskListShowCompletedToggled event,
    Emitter<TaskListState> emit,
  ) {
    emit(state.copyWith(showCompleted: !state.showCompleted));
  }
}
