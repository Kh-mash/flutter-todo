import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_todo/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:fpdart/fpdart.dart' hide Failure;
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late GetThemePreference usecase;
  late MockSettingsRepository mockRepo;

  setUp(() {
    mockRepo = MockSettingsRepository();
    usecase = GetThemePreference(mockRepo);
  });

  test('delegates to repository.watch()', () {
    when(() => mockRepo.watch())
        .thenAnswer((_) => Stream.value(Right(ThemePreference.dark)));

    final result = usecase();

    expect(result, emits(Right(ThemePreference.dark)));
    verify(() => mockRepo.watch()).called(1);
  });
}
