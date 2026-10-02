// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_water_entry_dao.dart';

// ignore_for_file: type=lint
mixin _$DailyWaterEntryDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyWaterEntriesTable get dailyWaterEntries =>
      attachedDatabase.dailyWaterEntries;
  DailyWaterEntryDaoManager get managers => DailyWaterEntryDaoManager(this);
}

class DailyWaterEntryDaoManager {
  final _$DailyWaterEntryDaoMixin _db;
  DailyWaterEntryDaoManager(this._db);
  $$DailyWaterEntriesTableTableManager get dailyWaterEntries =>
      $$DailyWaterEntriesTableTableManager(
        _db.attachedDatabase,
        _db.dailyWaterEntries,
      );
}
