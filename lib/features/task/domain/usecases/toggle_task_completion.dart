import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class ToggleTaskCompletion {
  const ToggleTaskCompletion(this._repository);
  final TaskRepository _repository;

  Future<Either<Failure, Unit>> call({
    required Task task,
    required bool isCompleted,
  }) =>
      _repository.update(task.copyWith(isCompleted: isCompleted));
}