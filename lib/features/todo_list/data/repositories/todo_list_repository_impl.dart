import 'dart:async';

import 'package:fpdart/fpdart.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/todo_list.dart';
import '../../domain/repositories/todo_list_repository.dart';
import '../../../../core/error/failures.dart';
import '../models/todo_list_model.dart';
import '../../../task/data/models/task_model.dart';
import '../../../../objectbox.g.dart' show TodoListModel_, TaskModel_;

@LazySingleton(as: TodoListRepository)
class TodoListRepositoryImpl implements TodoListRepository {
  TodoListRepositoryImpl(this._listBox, this._taskBox);
  final Box<TodoListModel> _listBox;
  final Box<TaskModel> _taskBox;
  static const _uuid = Uuid();

  @override
  Stream<Either<Failure, List<ListSummary>>> watchAllWithCounts() async* {
    try {
      await for (final _ in _listBox.query().order(TodoListModel_.name).watch(triggerImmediately: true)) {
        final tq = _taskBox.query(TaskModel_.isCompleted.equals(false)).build();
        try {
          final counts = <String, int>{};
          for (final t in tq.find()) {
            counts[t.listUuid] = (counts[t.listUuid] ?? 0) + 1;
          }
          final lq = _listBox.query().order(TodoListModel_.name).build();
          try {
            yield Right(lq.find().map((l) => ListSummary(
                  list: l.toDomain(),
                  openCount: counts[l.uuid] ?? 0,
                )).toList());
          } finally {
            lq.close();
          }
        } finally {
          tq.close();
        }
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> create(TodoList list) async {
    try {
      await _listBox.putAsync(TodoListModel.fromDomain(list));
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> rename(String id, String name) async {
    try {
      final q = _listBox.query(TodoListModel_.uuid.equals(id)).build();
      final model = q.findFirst();
      q.close();
      if (model == null) return const Left(NotFoundFailure('List not found'));
      model.name = name;
      await _listBox.putAsync(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      final lq = _listBox.query(TodoListModel_.uuid.equals(id)).build();
      final list = lq.findFirst();
      lq.close();
      if (list == null) return const Left(NotFoundFailure('List not found'));

      final tq = _taskBox.query(TaskModel_.listUuid.equals(id)).build();
      final taskIds = tq.find().map((t) => t.dbId).toList();
      tq.close();
      if (taskIds.isNotEmpty) {
        await _taskBox.removeManyAsync(taskIds);
      }

      await _listBox.removeAsync(list.dbId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TodoList>> ensureDefaultList() async {
    try {
      const name = 'Tasks';
      final q = _listBox.query(TodoListModel_.name.equals(name)).build();
      final existing = q.findFirst();
      q.close();

      if (existing != null) return Right(existing.toDomain());

      final list = TodoList(
        id: _uuid.v4(),
        name: name,
        createdAt: DateTime.now(),
      );
      await _listBox.putAsync(TodoListModel.fromDomain(list));
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
