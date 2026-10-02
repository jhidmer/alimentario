import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<DailyActivitySummary>> forDay(DateTime day) async {
    final items = await _database.dailyActivityDao.forDay(day);
    return items.map((item) => DailyActivitySummary(id: item.id, activityType: item.activityType, durationMinutes: item.durationMinutes, intensity: item.intensity, notes: item.notes)).toList();
  }

  @override
  Future<void> add(DateTime day, String activityType, int durationMinutes, int? intensity, String? notes) async {
    if (durationMinutes <= 0) throw const FormatException('La duración debe ser mayor que cero.');
    await _database.dailyActivityDao.insertActivity(DailyActivitiesCompanion.insert(
      date: DateTime(day.year, day.month, day.day),
      activityType: activityType,
      durationMinutes: durationMinutes,
      intensity: Value(intensity),
      notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> delete(int id) => _database.dailyActivityDao.deleteActivity(id);
}
