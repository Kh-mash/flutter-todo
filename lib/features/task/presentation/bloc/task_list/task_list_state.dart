import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

enum TaskListStatus { initial, loading, success, failure }

class TaskListState extends Equatable {
  const TaskListState({
    this.status = TaskListStatus.initial,
    this.tasks = const [],
    this.showCompleted = true,
    this.errorMessage,
  });

  final TaskListStatus status;
  final List<Task> tasks;
  final bool showCompleted;
  final String? errorMessage;

  List<Task> get pendingTasks =>
      tasks.where((t) => !t.isCompleted).toList();

  List<Task> get completedTasks =>
      tasks.where((t) => t.isCompleted).toList();

  TaskListState copyWith({
    TaskListStatus? status,
    List<Task>? tasks,
    bool? showCompleted,
    String? errorMessage,
  }) =>
      TaskListState(
        status: status ?? this.status,
        tasks: tasks ?? this.tasks,
        showCompleted: showCompleted ?? this.showCompleted,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, tasks, showCompleted, errorMessage];
}
