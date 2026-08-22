import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

enum MyDayStatus { initial, loading, success, failure }

class MyDayState extends Equatable {
  const MyDayState({
    this.status = MyDayStatus.initial,
    this.tasks = const [],
    this.showCompleted = true,
    this.errorMessage,
  });

  final MyDayStatus status;
  final List<Task> tasks;
  final bool showCompleted;
  final String? errorMessage;

  List<Task> get pendingTasks =>
      tasks.where((t) => !t.isCompleted).toList();

  List<Task> get completedTasks =>
      tasks.where((t) => t.isCompleted).toList();

  MyDayState copyWith({
    MyDayStatus? status,
    List<Task>? tasks,
    bool? showCompleted,
    String? errorMessage,
  }) =>
      MyDayState(
        status: status ?? this.status,
        tasks: tasks ?? this.tasks,
        showCompleted: showCompleted ?? this.showCompleted,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, tasks, showCompleted, errorMessage];
}
