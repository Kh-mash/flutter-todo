import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';

void main() {
  final now = DateTime(2026, 8, 22);
  final tList = TodoList(id: '1', name: 'Work', createdAt: now);

  group('TodoList', () {
    test('copyWith updates name', () {
      final updated = tList.copyWith(name: 'Personal');
      expect(updated.name, 'Personal');
      expect(updated.id, tList.id);
    });

    test('equality', () {
      expect(tList, equals(TodoList(id: '1', name: 'Work', createdAt: now)));
      expect(tList, isNot(equals(tList.copyWith(name: 'X'))));
    });
  });

  group('ListSummary', () {
    test('equality', () {
      expect(
        ListSummary(list: tList, openCount: 3),
        ListSummary(list: tList, openCount: 3),
      );
    });

    test('different openCount not equal', () {
      expect(
        ListSummary(list: tList, openCount: 3),
        isNot(equals(ListSummary(list: tList, openCount: 5))),
      );
    });
  });
}