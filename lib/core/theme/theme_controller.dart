import 'package:flutter/material.dart';

import '../database/app_database.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._database);

  final AppDatabase _database;
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final value = await _database.settingsDao.find('theme');
    _mode = value?.value == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _database.settingsDao.save('theme', mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
