import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../entities/todo_list.dart';
import '../repositories/todo_list_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class CreateList {
  const CreateList(this._repository);
  final TodoListRepository _repository;
  static const _uuid = Uuid();

  Future<Either<Failure, Unit>> call(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('List name cannot be empty')),
      );
    }
    return _repository.create(TodoList(
      id: _uuid.v4(),
      name: trimmed,
      createdAt: DateTime.now(),
    ));
  }
}
