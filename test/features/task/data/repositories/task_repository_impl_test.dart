import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/task/data/models/task_model.dart';
import 'package:flutter_todo/features/task/data/repositories/task_repository_impl.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/objectbox.g.dart' show openStore;
import 'package:objectbox/objectbox.dart';

void main() {
  late Store store;
  late Box<TaskModel> box;
  late TaskRepositoryImpl repo;

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('obx_test');
    store = await openStore(directory: dir.path);
    box = store.box<TaskModel>();
    repo = TaskRepositoryImpl(box);
  });

  tearDown(() {
    store.close();
  });

  group('create', () {
    test('creates a task and retrieves it', () async {
      final task = Task(
        id: 'uuid-1',
        title: 'Test',
        listId: 'list-1',
        createdAt: DateTime(2026, 8, 22),
      );
      final result = await repo.create(task);
      expect(result.isRight(), isTrue);

      final fetched = await repo.getById('uuid-1');
      expect(fetched.isRight(), isTrue);
      expect((fetched as Right).value?.title, 'Test');
    });
  });

  group('update', () {
    test('updates existing task', () async {
      final task = Task(
        id: 'uuid-1',
        title: 'Original',
        listId: 'list-1',
        createdAt: DateTime(2026, 8, 22),
      );
      await repo.create(task);

      final updated = await repo.update(task.copyWith(title: 'Updated'));
      expect(updated.isRight(), isTrue);

      final fetched = await repo.getById('uuid-1');
      expect((fetched as Right).value?.title, 'Updated');
    });

    test('returns NotFoundFailure for missing task', () async {
      final result = await repo.update(
        Task(id: 'missing', title: 'X', listId: 'L', createdAt: DateTime.now()),
      );
      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<NotFoundFailure>());
    });
  });

  group('delete', () {
    test('deletes existing task', () async {
      final task = Task(
        id: 'uuid-1',
        title: 'To Delete',
        listId: 'list-1',
        createdAt: DateTime(2026, 8, 22),
      );
      await repo.create(task);
      final result = await repo.delete('uuid-1');
      expect(result.isRight(), isTrue);

      final fetched = await repo.getById('uuid-1');
      expect((fetched as Right).value, isNull);
    });
  });

  group('watchMyDay', () {
    test('emits tasks with isMyDay true', () async {
      final myDay = Task(
        id: 'uuid-1',
        title: 'My Day Task',
        listId: 'list-1',
        isMyDay: true,
        createdAt: DateTime(2026, 8, 22),
      );
      final notMyDay = Task(
        id: 'uuid-2',
        title: 'Not My Day',
        listId: 'list-1',
        isMyDay: false,
        createdAt: DateTime(2026, 8, 22),
      );
      await repo.create(myDay);
      await repo.create(notMyDay);

      final result = await repo.watchMyDay().first;
      expect(result.isRight(), isTrue);
      final tasks = (result as Right).value;
      expect(tasks.length, 1);
      expect(tasks.first.title, 'My Day Task');
    });
  });
}
