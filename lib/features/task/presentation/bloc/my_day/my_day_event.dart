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
  const MyDayQuickAddSubmitted(this.title);
  final String title;
  @override
  List<Object?> get props => [title];
}

class MyDayShowCompletedToggled extends MyDayEvent {
  const MyDayShowCompletedToggled();
}
