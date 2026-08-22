import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class CreateTask {
  const CreateTask(this._repository);
  final TaskRepository _repository;

  Future<Either<Failure, Unit>> call(Task task) async {
    if (task.title.trim().isEmpty) {
      return const Left(ValidationFailure('Task title cannot be empty'));
    }
    return _repository.create(task);
  }
}