import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/core/error/failures.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_todo/features/settings/domain/usecases/save_theme_preference.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late SaveThemePreference usecase;
  late MockSettingsRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(ThemePreference.system);
  });

  setUp(() {
    mockRepo = MockSettingsRepository();
    usecase = SaveThemePreference(mockRepo);
  });

  test('delegates to repository.save', () async {
    when(() => mockRepo.save(ThemePreference.dark))
        .thenAnswer((_) async => const Right(unit));

    final result = await usecase(ThemePreference.dark);

    expect(result.isRight(), isTrue);
    verify(() => mockRepo.save(ThemePreference.dark)).called(1);
  });

  test('passes through repository failure', () async {
    when(() => mockRepo.save(any(that: isA<ThemePreference>())))
        .thenAnswer((_) async => const Left(CacheFailure('db error')));

    final result = await usecase(ThemePreference.light);

    expect(result.isLeft(), isTrue);
    expect((result as Left).value, isA<CacheFailure>());
  });
}
