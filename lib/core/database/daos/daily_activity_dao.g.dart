// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_activity_dao.dart';

// ignore_for_file: type=lint
mixin _$DailyActivityDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyActivitiesTable get dailyActivities => attachedDatabase.dailyActivities;
  DailyActivityDaoManager get managers => DailyActivityDaoManager(this);
}

class DailyActivityDaoManager {
  final _$DailyActivityDaoMixin _db;
  DailyActivityDaoManager(this._db);
  $$DailyActivitiesTableTableManager get dailyActivities =>
      $$DailyActivitiesTableTableManager(
        _db.attachedDatabase,
        _db.dailyActivities,
      );
}
