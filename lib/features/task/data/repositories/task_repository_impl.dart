import 'dart:async';

import 'package:fpdart/fpdart.dart' hide Task, Order;
import 'package:injectable/injectable.dart' hide Order;
import 'package:objectbox/objectbox.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../../core/error/failures.dart';
import '../models/task_model.dart';
import '../../../../objectbox.g.dart' show TaskModel_;

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._box);
  final Box<TaskModel> _box;

  @override
  Stream<Either<Failure, List<Task>>> watchMyDay() => _watch(
        _box.query(TaskModel_.isMyDay.equals(true)).order(TaskModel_.createdAt, flags: Order.descending),
      );

  @override
  Stream<Either<Failure, List<Task>>> watchByList(String listId) => _watch(
        _box.query(TaskModel_.listUuid.equals(listId)).order(TaskModel_.createdAt, flags: Order.descending),
      );

  Stream<Either<Failure, List<Task>>> _watch(QueryBuilder<TaskModel> builder) async* {
    try {
      await for (final query in builder.watch(triggerImmediately: true)) {
        yield Right(query.find().map((m) => m.toDomain()).toList());
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> create(Task task) async {
    try {
      final model = TaskModel.fromDomain(task);
      await _box.putAsync(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> update(Task task) async {
    try {
      final existing = _box.query(TaskModel_.uuid.equals(task.id)).build().findFirst();
      if (existing == null) return const Left(NotFoundFailure('Task not found'));
      final updated = TaskModel.fromDomain(task)..dbId = existing.dbId;
      await _box.putAsync(updated);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      final q = _box.query(TaskModel_.uuid.equals(id)).build();
      final model = q.findFirst();
      q.close();
      if (model == null) return const Left(NotFoundFailure('Task not found'));
      await _box.removeAsync(model.dbId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task?>> getById(String id) async {
    try {
      final q = _box.query(TaskModel_.uuid.equals(id)).build();
      final model = q.findFirst();
      q.close();
      return Right(model?.toDomain());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
