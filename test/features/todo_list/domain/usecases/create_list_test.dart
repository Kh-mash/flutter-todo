import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';
import 'package:flutter_todo/features/todo_list/domain/repositories/todo_list_repository.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/create_list.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoListRepository extends Mock implements TodoListRepository {}

void main() {
  late CreateList usecase;
  late MockTodoListRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(TodoList(id: '', name: '', createdAt: DateTime(0)));
  });

  setUp(() {
    mockRepo = MockTodoListRepository();
    usecase = CreateList(mockRepo);
  });

  test('returns ValidationFailure for empty name', () async {
    final result = await usecase('   ');
    expect(result, isA<Left<Failure, Unit>>());
    expect((result as Left).value, isA<ValidationFailure>());
    verifyNever(() => mockRepo.create(any()));
  });

  test('delegates to repository.create with trimmed name', () async {
    when(() => mockRepo.create(any()))
        .thenAnswer((_) async => const Right(unit));
    final result = await usecase('  Work  ');
    expect(result, isA<Right>());
    verify(() => mockRepo.create(any())).called(1);
  });
}
