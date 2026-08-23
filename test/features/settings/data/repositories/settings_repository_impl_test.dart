import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/features/settings/data/models/app_settings_model.dart';
import 'package:flutter_todo/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_todo/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_todo/objectbox.g.dart' show openStore;
import 'package:objectbox/objectbox.dart';

void main() {
  late Store store;
  late Box<AppSettingsModel> box;
  late SettingsRepositoryImpl repo;

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('obx_settings_test');
    store = await openStore(directory: dir.path);
    box = store.box<AppSettingsModel>();
    repo = SettingsRepositoryImpl(box);
  });

  tearDown(() {
    store.close();
  });

  group('watch', () {
    test('emits system when no settings stored yet', () async {
      final result = await repo.watch().first;
      final preference =
          result.fold((failure) => throw failure.message, (p) => p);
      expect(preference, ThemePreference.system);
    });

    test('re-emits after save', () async {
      await repo.save(ThemePreference.dark);
      final result = await repo.watch().first;
      final preference =
          result.fold((failure) => throw failure.message, (p) => p);
      expect(preference, ThemePreference.dark);
    });
  });

  group('save', () {
    test('keeps a single settings row across saves', () async {
      await repo.save(ThemePreference.light);
      await repo.save(ThemePreference.dark);
      expect(box.count(), 1);

      final stored = box.query().build().findFirst();
      expect(stored!.themePrefIndex, ThemePreference.dark.index);
    });
  });
}
