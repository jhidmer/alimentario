import 'package:drift/drift.dart';

@TableIndex(name: 'uq_daily_contexts_date', columns: {#date}, unique: true)
class DailyContexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get sleepMinutes => integer().nullable()();
  IntColumn get sleepQuality => integer().nullable()();
  IntColumn get stress => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
