import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/task/domain/entities/task.dart';
import 'package:flutter_todo/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_todo/features/task/domain/usecases/toggle_task_completion.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late ToggleTaskCompletion usecase;
  late MockTaskRepository mockRepo;
  final now = DateTime(2026, 8, 22);

  setUp(() {
    mockRepo = MockTaskRepository();
    usecase = ToggleTaskCompletion(mockRepo);
    registerFallbackValue(Task(id: '', title: '', listId: '', createdAt: DateTime(0)));
  });

  test('calls update with flipped completion flag', () async {
    final task = Task(id: '1', title: 'T', listId: 'L', createdAt: now);
    when(() => mockRepo.update(any())).thenAnswer((_) async => const Right(unit));

    final result = await usecase(task: task, isCompleted: true);

    expect(result, isA<Right>());
    final captured = verify(() => mockRepo.update(captureAny())).captured.single as Task;
    expect(captured.isCompleted, isTrue);
  });
}