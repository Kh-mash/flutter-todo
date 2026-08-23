import 'package:objectbox/objectbox.dart';

import '../../domain/entities/theme_preference.dart';

@Entity()
class AppSettingsModel {
  AppSettingsModel({this.dbId = 0, this.themePrefIndex = 0});

  @Id()
  int dbId;

  int themePrefIndex;

  ThemePreference toDomain() {
    final index = themePrefIndex;
    if (index < 0 || index >= ThemePreference.values.length) {
      return ThemePreference.system;
    }
    return ThemePreference.values[index];
  }

  static AppSettingsModel fromDomain(ThemePreference preference) =>
      AppSettingsModel(themePrefIndex: preference.index);
}
