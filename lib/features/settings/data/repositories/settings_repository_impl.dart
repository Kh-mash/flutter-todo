import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:objectbox/objectbox.dart';

import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/error/failures.dart';
import '../models/app_settings_model.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._box);

  final Box<AppSettingsModel> _box;

  @override
  Stream<Either<Failure, ThemePreference>> watch() async* {
    try {
      await for (final query
          in _box.query().watch(triggerImmediately: true)) {
        yield Right(_current(query));
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }

  ThemePreference _current(Query<AppSettingsModel> query) =>
      query.findFirst()?.toDomain() ?? ThemePreference.system;

  @override
  Future<Either<Failure, Unit>> save(ThemePreference preference) async {
    try {
      final existing = _box.query().build().findFirst();
      final model = AppSettingsModel.fromDomain(preference)
        ..dbId = existing?.dbId ?? 0;
      await _box.putAsync(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
