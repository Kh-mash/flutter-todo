import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_todo/features/task/domain/usecases/create_task.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CreateTask usecase;
  late MockTaskRepository mockRepo;

  setUp(() {
    mockRepo = MockTaskRepository();
    usecase = CreateTask(mockRepo);
    registerFallbackValue(Task(id: '', title: '', listId: '', createdAt: DateTime(0)));
  });

  test('returns ValidationFailure for empty title', () async {
    final task = Task(id: '1', title: '  ', listId: 'L', createdAt: DateTime.now());
    final result = await usecase(task);
    expect(result, isA<Left<Failure, Unit>>());
    expect((result as Left).value, isA<ValidationFailure>());
    verifyNever(() => mockRepo.create(any()));
  });

  test('delegates to repository.create for valid task', () async {
    final task = Task(id: '1', title: 'Valid', listId: 'L', createdAt: DateTime.now());
    when(() => mockRepo.create(any())).thenAnswer((_) async => const Right(unit));
    final result = await usecase(task);
    expect(result, isA<Right>());
    verify(() => mockRepo.create(task)).called(1);
  });
}