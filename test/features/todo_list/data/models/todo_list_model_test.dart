import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/todo_list/data/models/todo_list_model.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';

void main() {
  final now = DateTime(2026, 8, 22);
  final tList = TodoList(id: 'uuid-1', name: 'Work', createdAt: now);

  group('TodoListModel', () {
    test('fromDomain preserves all fields', () {
      final model = TodoListModel.fromDomain(tList);
      expect(model.uuid, tList.id);
      expect(model.name, tList.name);
      expect(model.createdAt, tList.createdAt);
      expect(model.dbId, 0);
    });

    test('round-trip preserves all fields', () {
      final model = TodoListModel.fromDomain(tList);
      final restored = model.toDomain();
      expect(restored.id, tList.id);
      expect(restored.name, tList.name);
      expect(restored.createdAt, tList.createdAt);
    });
  });
}
