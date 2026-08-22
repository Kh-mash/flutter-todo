import 'package:objectbox/objectbox.dart';
import '../../domain/entities/todo_list.dart';

@Entity()
class TodoListModel {
  TodoListModel({
    this.dbId = 0,
    required this.uuid,
    required this.name,
    required this.createdAt,
  });

  @Id()
  int dbId;

  @Unique()
  String uuid;

  String name;

  DateTime createdAt;

  TodoList toDomain() => TodoList(
        id: uuid,
        name: name,
        createdAt: createdAt,
      );

  static TodoListModel fromDomain(TodoList t) => TodoListModel(
        uuid: t.id,
        name: t.name,
        createdAt: t.createdAt,
      );
}
