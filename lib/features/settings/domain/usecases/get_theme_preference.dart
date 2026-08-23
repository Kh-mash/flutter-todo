import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/theme_preference.dart';
import '../repositories/settings_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class GetThemePreference {
  const GetThemePreference(this._repository);

  final SettingsRepository _repository;

  Stream<Either<Failure, ThemePreference>> call() => _repository.watch();
}
