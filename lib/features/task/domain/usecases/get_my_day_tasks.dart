import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class GetMyDayTasks {
  const GetMyDayTasks(this._repository);
  final TaskRepository _repository;

  Stream<Either<Failure, List<Task>>> call() => _repository.watchMyDay();
}