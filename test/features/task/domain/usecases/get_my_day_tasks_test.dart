import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_todo/features/task/domain/usecases/get_my_day_tasks.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late GetMyDayTasks usecase;
  late MockTaskRepository mockRepo;

  setUp(() {
    mockRepo = MockTaskRepository();
    usecase = GetMyDayTasks(mockRepo);
  });

  final tTasks = [Task(id: '1', title: 'T', listId: 'L', createdAt: DateTime.now())];

  test('delegates to repository.watchMyDay()', () {
    when(() => mockRepo.watchMyDay()).thenAnswer((_) => Stream.value(Right(tTasks)));

    final result = usecase();

    expect(result, emitsInOrder([Right(tTasks)]));
    verify(() => mockRepo.watchMyDay()).called(1);
  });
}