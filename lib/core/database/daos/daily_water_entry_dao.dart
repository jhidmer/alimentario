import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/daily_water_entries_table.dart';

part 'daily_water_entry_dao.g.dart';

@DriftAccessor(tables: [DailyWaterEntries])
class DailyWaterEntryDao extends DatabaseAccessor<AppDatabase> with _$DailyWaterEntryDaoMixin {
  DailyWaterEntryDao(super.attachedDatabase);

  Future<List<DailyWaterEntry>> forDay(DateTime day) => (select(dailyWaterEntries)
        ..where((entry) => entry.date.equals(DateTime(day.year, day.month, day.day)))
        ..orderBy([(entry) => OrderingTerm(expression: entry.createdAt)]))
      .get();

  Future<List<DailyWaterEntry>> between(DateTime from, DateTime to) => (select(dailyWaterEntries)..where((entry) => entry.date.isBetweenValues(from, to))).get();

  Future<int> insertEntry(DailyWaterEntriesCompanion entry) => into(dailyWaterEntries).insert(entry);

  Future<void> deleteEntry(int id) => (delete(dailyWaterEntries)..where((entry) => entry.id.equals(id))).go();
}
