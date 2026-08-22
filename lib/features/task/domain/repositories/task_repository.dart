import 'package:fpdart/fpdart.dart' hide Task;
import '../entities/task.dart';
import '../../../../core/error/failures.dart';

abstract interface class TaskRepository {
  Stream<Either<Failure, List<Task>>> watchMyDay();
  Stream<Either<Failure, List<Task>>> watchByList(String listId);
  Future<Either<Failure, Unit>> create(Task task);
  Future<Either<Failure, Unit>> update(Task task);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, Task?>> getById(String id);
}