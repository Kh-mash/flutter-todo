import 'package:equatable/equatable.dart';

class TodoList extends Equatable {
  const TodoList({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  TodoList copyWith({String? name}) => TodoList(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, name, createdAt];
}

class ListSummary extends Equatable {
  const ListSummary({required this.list, required this.openCount});

  final TodoList list;
  final int openCount;

  @override
  List<Object?> get props => [list, openCount];
}