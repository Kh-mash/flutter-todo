import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../repositories/todo_list_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class DeleteList {
  const DeleteList(this._repository);
  final TodoListRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.delete(id);
}
