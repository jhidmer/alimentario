import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/daily_moods_table.dart';

part 'daily_mood_dao.g.dart';

@DriftAccessor(tables: [DailyMoods])
class DailyMoodDao extends DatabaseAccessor<AppDatabase> with _$DailyMoodDaoMixin {
  DailyMoodDao(super.attachedDatabase);

  Future<DailyMood?> forDay(DateTime day) => (select(dailyMoods)..where((mood) => mood.date.equals(DateTime(day.year, day.month, day.day)))).getSingleOrNull();

  Future<List<DailyMood>> between(DateTime from, DateTime to) => (select(dailyMoods)..where((mood) => mood.date.isBetweenValues(from, to))).get();

  Future<void> save(DailyMoodsCompanion entry) => into(dailyMoods).insertOnConflictUpdate(entry);
}
