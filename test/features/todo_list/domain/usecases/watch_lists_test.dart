import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';
import 'package:flutter_todo/features/todo_list/domain/repositories/todo_list_repository.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/watch_lists.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoListRepository extends Mock implements TodoListRepository {}

void main() {
  late WatchLists usecase;
  late MockTodoListRepository mockRepo;

  setUp(() {
    mockRepo = MockTodoListRepository();
    usecase = WatchLists(mockRepo);
  });

  test('delegates to repository.watchAllWithCounts()', () {
    final summaries = [
      ListSummary(
        list: TodoList(id: '1', name: 'Work', createdAt: DateTime.now()),
        openCount: 3,
      ),
    ];
    when(() => mockRepo.watchAllWithCounts())
        .thenAnswer((_) => Stream.value(Right(summaries)));

    final result = usecase();
    expect(result, emitsInOrder([Right(summaries)]));
    verify(() => mockRepo.watchAllWithCounts()).called(1);
  });
}
