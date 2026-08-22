import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../repositories/todo_list_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class RenameList {
  const RenameList(this._repository);
  final TodoListRepository _repository;

  Future<Either<Failure, Unit>> call(String id, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('List name cannot be empty')),
      );
    }
    return _repository.rename(id, trimmed);
  }
}
