import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/todo_list.dart';
import '../repositories/todo_list_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class WatchLists {
  const WatchLists(this._repository);
  final TodoListRepository _repository;

  Stream<Either<Failure, List<ListSummary>>> call() =>
      _repository.watchAllWithCounts();
}
