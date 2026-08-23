import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

sealed class TaskListEvent extends Equatable {
  const TaskListEvent();
  @override
  List<Object?> get props => [];
}

class TaskListSubscriptionRequested extends TaskListEvent {
  const TaskListSubscriptionRequested(this.listId);
  final String listId;
  @override
  List<Object?> get props => [listId];
}

class TaskListTaskCompletionToggled extends TaskListEvent {
  const TaskListTaskCompletionToggled(this.task, {required this.isCompleted});
  final Task task;
  final bool isCompleted;
  @override
  List<Object?> get props => [task, isCompleted];
}

class TaskListTaskDeleted extends TaskListEvent {
  const TaskListTaskDeleted(this.task);
  final Task task;
  @override
  List<Object?> get props => [task];
}

class TaskListQuickAddSubmitted extends TaskListEvent {
  const TaskListQuickAddSubmitted(this.title);
  final String title;
  @override
  List<Object?> get props => [title];
}

class TaskListShowCompletedToggled extends TaskListEvent {
  const TaskListShowCompletedToggled();
}
