import 'package:drift/drift.dart';

@TableIndex(name: 'uq_daily_moods_date', columns: {#date}, unique: true)
class DailyMoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get mood => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}
