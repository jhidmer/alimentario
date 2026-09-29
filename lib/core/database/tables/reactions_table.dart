import 'package:drift/drift.dart';

@TableIndex(name: 'idx_reactions_started_at', columns: {#startedAt})
@TableIndex(name: 'idx_reactions_status', columns: {#status})
class Reactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get intensity => integer()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get bodyArea => text().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
