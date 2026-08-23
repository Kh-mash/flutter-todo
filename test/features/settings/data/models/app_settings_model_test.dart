import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/settings/data/models/app_settings_model.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';

void main() {
  group('AppSettingsModel', () {
    test('round-trips every preference', () {
      for (final preference in ThemePreference.values) {
        final restored = AppSettingsModel.fromDomain(preference).toDomain();
        expect(restored, preference);
      }
    });

    test('out-of-range index falls back to system', () {
      final model = AppSettingsModel(themePrefIndex: 99);
      expect(model.toDomain(), ThemePreference.system);
    });

    test('negative index falls back to system', () {
      final model = AppSettingsModel(themePrefIndex: -1);
      expect(model.toDomain(), ThemePreference.system);
    });
  });
}
