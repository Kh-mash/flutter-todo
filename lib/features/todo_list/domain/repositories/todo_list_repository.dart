import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/todo_list.dart';

abstract interface class TodoListRepository {
  Stream<Either<Failure, List<ListSummary>>> watchAllWithCounts();
  Future<Either<Failure, Unit>> create(TodoList list);
  Future<Either<Failure, Unit>> rename(String id, String name);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, TodoList>> ensureDefaultList();
}
