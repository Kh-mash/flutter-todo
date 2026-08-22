import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/todo_list/domain/repositories/todo_list_repository.dart';
import 'package:flutter_todo/features/todo_list/domain/usecases/rename_list.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoListRepository extends Mock implements TodoListRepository {}

void main() {
  late RenameList usecase;
  late MockTodoListRepository mockRepo;

  setUp(() {
    mockRepo = MockTodoListRepository();
    usecase = RenameList(mockRepo);
  });

  test('returns ValidationFailure for empty name', () async {
    final result = await usecase('1', '   ');
    expect(result, isA<Left<Failure, Unit>>());
    expect((result as Left).value, isA<ValidationFailure>());
    verifyNever(() => mockRepo.rename(any(), any()));
  });

  test('delegates to repository.rename with trimmed name', () async {
    when(() => mockRepo.rename(any(), any()))
        .thenAnswer((_) async => const Right(unit));
    final result = await usecase('1', '  Personal  ');
    expect(result, isA<Right>());
    verify(() => mockRepo.rename('1', 'Personal')).called(1);
  });
}
