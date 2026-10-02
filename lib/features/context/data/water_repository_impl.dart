import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/water_repository.dart';

class WaterRepositoryImpl implements WaterRepository {
  WaterRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<WaterEntrySummary>> forDay(DateTime day) async {
    final entries = await _database.dailyWaterEntryDao.forDay(day);
    return entries.map((entry) => WaterEntrySummary(id: entry.id, amountMl: entry.amountMl, notes: entry.notes)).toList();
  }

  @override
  Future<void> add(DateTime day, int amountMl, String? notes) async {
    if (amountMl <= 0) throw const FormatException('La cantidad debe ser mayor que cero.');
    await _database.dailyWaterEntryDao.insertEntry(DailyWaterEntriesCompanion.insert(date: DateTime(day.year, day.month, day.day), amountMl: amountMl, notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()), createdAt: DateTime.now()));
  }

  @override
  Future<void> delete(int id) => _database.dailyWaterEntryDao.deleteEntry(id);
}
