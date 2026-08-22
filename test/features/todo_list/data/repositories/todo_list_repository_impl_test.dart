import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/task/data/models/task_model.dart';
import 'package:flutter_todo/features/todo_list/data/models/todo_list_model.dart';
import 'package:flutter_todo/features/todo_list/data/repositories/todo_list_repository_impl.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';
import 'package:flutter_todo/objectbox.g.dart' show openStore;
import 'package:objectbox/objectbox.dart';

void main() {
  late Store store;
  late Box<TodoListModel> listBox;
  late Box<TaskModel> taskBox;
  late TodoListRepositoryImpl repo;

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('obx_list_test');
    store = await openStore(directory: dir.path);
    listBox = store.box<TodoListModel>();
    taskBox = store.box<TaskModel>();
    repo = TodoListRepositoryImpl(listBox, taskBox);
  });

  tearDown(() {
    store.close();
  });

  group('ensureDefaultList', () {
    test('creates default list on first call', () async {
      final result = await repo.ensureDefaultList();
      expect(result.isRight(), isTrue);
      final list = (result as Right).value;
      expect(list.name, 'Tasks');
    });

    test('returns existing default list on second call', () async {
      await repo.ensureDefaultList();
      await repo.ensureDefaultList();
      expect(listBox.count(), 1);
    });
  });

  group('create', () {
    test('creates a list', () async {
      final list = TodoList(id: 'uuid-1', name: 'Work', createdAt: DateTime.now());
      final result = await repo.create(list);
      expect(result.isRight(), isTrue);
      expect(listBox.count(), 1);
    });
  });

  group('rename', () {
    test('renames existing list', () async {
      final list = TodoList(id: 'uuid-1', name: 'Work', createdAt: DateTime.now());
      await repo.create(list);
      final result = await repo.rename('uuid-1', 'Personal');
      expect(result.isRight(), isTrue);
    });

    test('returns NotFoundFailure for missing list', () async {
      final result = await repo.rename('missing', 'X');
      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<NotFoundFailure>());
    });
  });

  group('delete', () {
    test('deletes list and cascades tasks', () async {
      final list = TodoList(id: 'uuid-1', name: 'Work', createdAt: DateTime.now());
      await repo.create(list);

      final task = TaskModel(
        uuid: 'task-1',
        title: 'Task',
        listUuid: 'uuid-1',
        createdAt: DateTime.now(),
      );
      taskBox.put(task);

      final result = await repo.delete('uuid-1');
      expect(result.isRight(), isTrue);
      expect(listBox.count(), 0);
      expect(taskBox.count(), 0);
    });

    test('returns NotFoundFailure for missing list', () async {
      final result = await repo.delete('missing');
      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<NotFoundFailure>());
    });
  });

  group('watchAllWithCounts', () {
    test('emits summaries with open task counts', () async {
      final list = TodoList(id: 'uuid-1', name: 'Work', createdAt: DateTime.now());
      await repo.create(list);

      final t1 = TaskModel(
        uuid: 'task-1',
        title: 'Task 1',
        listUuid: 'uuid-1',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      final t2 = TaskModel(
        uuid: 'task-2',
        title: 'Task 2',
        listUuid: 'uuid-1',
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      taskBox.put(t1);
      taskBox.put(t2);

      final result = await repo.watchAllWithCounts().first;
      expect(result.isRight(), isTrue);
      final summaries = (result as Right).value;
      expect(summaries.length, 1);
      expect(summaries.first.openCount, 1);
    });
  });
}
