import '../../../core/database/app_database.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<String?> get(String key) async => (await _database.settingsDao.find(key))?.value;

  @override
  Future<void> set(String key, String? value) => _database.settingsDao.save(key, value);
}
