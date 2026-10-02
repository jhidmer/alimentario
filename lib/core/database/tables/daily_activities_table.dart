import 'package:drift/drift.dart';

@TableIndex(name: 'idx_daily_activities_date', columns: {#date})
class DailyActivities extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get activityType => text()();
  IntColumn get durationMinutes => integer()();
  IntColumn get intensity => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
