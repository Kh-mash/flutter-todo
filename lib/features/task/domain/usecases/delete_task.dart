import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../repositories/task_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class DeleteTask {
  const DeleteTask(this._repository);
  final TaskRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.delete(id);
}