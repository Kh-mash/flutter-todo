import 'package:objectbox/objectbox.dart';
import '../../domain/entities/task.dart';

@Entity()
class TaskModel {
  TaskModel({
    this.dbId = 0,
    required this.uuid,
    required this.title,
    required this.listUuid,
    this.isCompleted = false,
    this.isMyDay = false,
    this.isStarred = false,
    this.dueDate,
    required this.createdAt,
  });

  @Id()
  int dbId;

  @Unique()
  @Index()
  String uuid;

  String title;

  bool isCompleted;

  bool isMyDay;

  bool isStarred;

  @Index()
  String listUuid;

  DateTime? dueDate;

  DateTime createdAt;

  Task toDomain() => Task(
        id: uuid,
        title: title,
        listId: listUuid,
        isCompleted: isCompleted,
        isMyDay: isMyDay,
        isStarred: isStarred,
        dueDate: dueDate,
        createdAt: createdAt,
      );

  static TaskModel fromDomain(Task t) => TaskModel(
        uuid: t.id,
        title: t.title,
        listUuid: t.listId,
        isCompleted: t.isCompleted,
        isMyDay: t.isMyDay,
        isStarred: t.isStarred,
        dueDate: t.dueDate,
        createdAt: t.createdAt,
      );
}
