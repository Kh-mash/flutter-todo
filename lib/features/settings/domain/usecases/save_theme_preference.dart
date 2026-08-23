import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/theme_preference.dart';
import '../repositories/settings_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class SaveThemePreference {
  const SaveThemePreference(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, Unit>> call(ThemePreference preference) =>
      _repository.save(preference);
}
