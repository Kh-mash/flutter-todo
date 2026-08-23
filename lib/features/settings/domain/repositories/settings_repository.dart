import 'package:fpdart/fpdart.dart';

import '../entities/theme_preference.dart';
import '../../../../core/error/failures.dart';

abstract interface class SettingsRepository {
  Stream<Either<Failure, ThemePreference>> watch();
  Future<Either<Failure, Unit>> save(ThemePreference preference);
}
