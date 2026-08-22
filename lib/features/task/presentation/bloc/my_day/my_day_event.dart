import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

sealed class MyDayEvent extends Equatable {
  const MyDayEvent();
  @override
  List<Object?> get props => [];
}

class MyDaySubscriptionRequested extends MyDayEvent {
  const MyDaySubscriptionRequested();
}

class MyDayTaskCompletionToggled extends MyDayEvent {
  const MyDayTaskCompletionToggled(this.task, {required this.isCompleted});
  final Task task;
  final bool isCompleted;
  @override
  List<Object?> get props => [task, isCompleted];
}

class MyDayTaskDeleted extends MyDayEvent {
  const MyDayTaskDeleted(this.task);
  final Task task;
  @override
  List<Object?> get props => [task];
}

class MyDayQuickAddSubmitted extends MyDayEvent {
  const MyDayQuickAddSubmitted(this.title, {required this.listId});
  final String title;
  final String listId;
  @override
  List<Object?> get props => [title, listId];
}

class MyDayShowCompletedToggled extends MyDayEvent {
  const MyDayShowCompletedToggled();
}
