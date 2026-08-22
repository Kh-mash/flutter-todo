import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/todo_list/domain/repositories/todo_list_repository.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/delete_list.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoListRepository extends Mock implements TodoListRepository {}

void main() {
  late DeleteList usecase;
  late MockTodoListRepository mockRepo;

  setUp(() {
    mockRepo = MockTodoListRepository();
    usecase = DeleteList(mockRepo);
  });

  test('delegates to repository.delete', () async {
    when(() => mockRepo.delete('1'))
        .thenAnswer((_) async => const Right(unit));
    final result = await usecase('1');
    expect(result, isA<Right>());
    verify(() => mockRepo.delete('1')).called(1);
  });
}
