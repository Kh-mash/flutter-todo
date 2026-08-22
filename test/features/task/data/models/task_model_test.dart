import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/task/data/models/task_model.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';

void main() {
  final now = DateTime(2026, 8, 22);
  final tTask = Task(
    id: 'uuid-1',
    title: 'Test Task',
    listId: 'list-uuid',
    isCompleted: false,
    isMyDay: true,
    isStarred: false,
    dueDate: DateTime(2026, 9, 1),
    createdAt: now,
  );

  group('TaskModel', () {
    test('fromDomain preserves all fields', () {
      final model = TaskModel.fromDomain(tTask);
      expect(model.uuid, tTask.id);
      expect(model.title, tTask.title);
      expect(model.listUuid, tTask.listId);
      expect(model.isCompleted, tTask.isCompleted);
      expect(model.isMyDay, tTask.isMyDay);
      expect(model.isStarred, tTask.isStarred);
      expect(model.dueDate, tTask.dueDate);
      expect(model.createdAt, tTask.createdAt);
      expect(model.dbId, 0); // new model starts with dbId 0
    });

    test('toDomain restores all fields', () {
      final model = TaskModel.fromDomain(tTask);
      final domain = model.toDomain();
      expect(domain, tTask);
    });

    test('round-trip preserves all fields', () {
      final model = TaskModel.fromDomain(tTask);
      final restored = model.toDomain();
      expect(restored.id, tTask.id);
      expect(restored.title, tTask.title);
      expect(restored.listId, tTask.listId);
      expect(restored.isCompleted, tTask.isCompleted);
      expect(restored.isMyDay, tTask.isMyDay);
      expect(restored.isStarred, tTask.isStarred);
      expect(restored.dueDate, tTask.dueDate);
      expect(restored.createdAt, tTask.createdAt);
    });

    test('round-trip with null dueDate', () {
      final noDate = tTask.copyWith(clearDueDate: true);
      final model = TaskModel.fromDomain(noDate);
      expect(model.dueDate, isNull);
      final restored = model.toDomain();
      expect(restored.dueDate, isNull);
    });
  });
}
