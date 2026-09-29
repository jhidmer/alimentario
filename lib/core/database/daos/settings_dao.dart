import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings, SchemaMetadata])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  Future<AppSetting?> find(String settingKey) => (select(appSettings)..where((setting) => setting.key.equals(settingKey))).getSingleOrNull();

  Future<void> save(String settingKey, String? settingValue) => into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: settingKey, value: Value(settingValue), updatedAt: Value(DateTime.now())),
      );
}
