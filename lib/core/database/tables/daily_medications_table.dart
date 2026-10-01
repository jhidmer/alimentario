import 'package:drift/drift.dart';

@TableIndex(name: 'idx_daily_medications_date', columns: {#date})
class DailyMedications extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get name => text()();
  RealColumn get dosage => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get kind => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
