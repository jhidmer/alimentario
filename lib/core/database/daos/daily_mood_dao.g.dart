// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_mood_dao.dart';

// ignore_for_file: type=lint
mixin _$DailyMoodDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyMoodsTable get dailyMoods => attachedDatabase.dailyMoods;
  DailyMoodDaoManager get managers => DailyMoodDaoManager(this);
}

class DailyMoodDaoManager {
  final _$DailyMoodDaoMixin _db;
  DailyMoodDaoManager(this._db);
  $$DailyMoodsTableTableManager get dailyMoods =>
      $$DailyMoodsTableTableManager(_db.attachedDatabase, _db.dailyMoods);
}
