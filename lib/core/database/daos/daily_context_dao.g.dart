// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_context_dao.dart';

// ignore_for_file: type=lint
mixin _$DailyContextDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyContextsTable get dailyContexts => attachedDatabase.dailyContexts;
  DailyContextDaoManager get managers => DailyContextDaoManager(this);
}

class DailyContextDaoManager {
  final _$DailyContextDaoMixin _db;
  DailyContextDaoManager(this._db);
  $$DailyContextsTableTableManager get dailyContexts =>
      $$DailyContextsTableTableManager(_db.attachedDatabase, _db.dailyContexts);
}
