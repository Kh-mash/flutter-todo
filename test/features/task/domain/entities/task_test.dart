import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';

void main() {
  final now = DateTime(2026, 8, 22);
  final tTask = Task(
    id: '1',
    title: 'Test',
    listId: 'list1',
    createdAt: now,
  );

  group('Task', () {
    test('copyWith preserves untouched fields', () {
      final updated = tTask.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.id, tTask.id);
      expect(updated.listId, tTask.listId);
      expect(updated.isCompleted, tTask.isCompleted);
    });

    test('clearDueDate nulls dueDate', () {
      final withDate = tTask.copyWith(dueDate: DateTime(2026, 9, 1));
      final cleared = withDate.copyWith(clearDueDate: true);
      expect(cleared.dueDate, isNull);
    });

    test('isOverdue returns true for overdue incomplete task', () {
      final overdue = tTask.copyWith(
        dueDate: DateTime(2026, 1, 1),
        isCompleted: false,
      );
      expect(overdue.isOverdue, isTrue);
    });

    test('isOverdue returns false for completed task', () {
      final completed = tTask.copyWith(
        dueDate: DateTime(2026, 1, 1),
        isCompleted: true,
      );
      expect(completed.isOverdue, isFalse);
    });

    test('equality by all props', () {
      expect(tTask, equals(tTask.copyWith()));
      expect(tTask, isNot(equals(tTask.copyWith(title: 'X'))));
    });
  });
}
