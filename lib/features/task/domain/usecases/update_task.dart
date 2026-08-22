import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class UpdateTask {
  const UpdateTask(this._repository);
  final TaskRepository _repository;

  Future<Either<Failure, Unit>> call(Task task) => _repository.update(task);
}