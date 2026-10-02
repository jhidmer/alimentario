import 'package:drift/drift.dart';

@TableIndex(name: 'idx_daily_water_entries_date', columns: {#date})
class DailyWaterEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountMl => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
