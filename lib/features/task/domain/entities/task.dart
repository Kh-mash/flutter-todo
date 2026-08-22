import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.listId,
    required this.createdAt,
    this.isCompleted = false,
    this.isMyDay = false,
    this.isStarred = false,
    this.dueDate,
  });

  final String id;
  final String title;
  final String listId;
  final bool isCompleted;
  final bool isMyDay;
  final bool isStarred;
  final DateTime? dueDate;
  final DateTime createdAt;

  bool get isOverdue =>
      !isCompleted && dueDate != null && dueDate!.isBefore(DateTime.now());

  Task copyWith({
    String? title,
    String? listId,
    bool? isCompleted,
    bool? isMyDay,
    bool? isStarred,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        listId: listId ?? this.listId,
        isCompleted: isCompleted ?? this.isCompleted,
        isMyDay: isMyDay ?? this.isMyDay,
        isStarred: isStarred ?? this.isStarred,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        createdAt: createdAt,
      );

  @override
  List<Object?> get props =>
      [id, title, listId, isCompleted, isMyDay, isStarred, dueDate, createdAt];
}
