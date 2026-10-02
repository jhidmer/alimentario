import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/mood_repository.dart';

class MoodRepositoryImpl implements MoodRepository {
  MoodRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<MoodSummary?> forDay(DateTime day) async {
    final value = await _database.dailyMoodDao.forDay(day);
    return value == null ? null : MoodSummary(mood: value.mood, notes: value.notes);
  }

  @override
  Future<void> save(DateTime day, int mood, String? notes) {
    if (mood < 1 || mood > 5) throw const FormatException('El estado de ánimo no es válido.');
    return _database.dailyMoodDao.save(DailyMoodsCompanion.insert(date: DateTime(day.year, day.month, day.day), mood: mood, notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()), updatedAt: DateTime.now()));
  }
}
