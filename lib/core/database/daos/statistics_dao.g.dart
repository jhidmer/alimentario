// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_dao.dart';

// ignore_for_file: type=lint
mixin _$StatisticsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MealsTable get meals => attachedDatabase.meals;
  $ReactionsTable get reactions => attachedDatabase.reactions;
  StatisticsDaoManager get managers => StatisticsDaoManager(this);
}

class StatisticsDaoManager {
  final _$StatisticsDaoMixin _db;
  StatisticsDaoManager(this._db);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db.attachedDatabase, _db.meals);
  $$ReactionsTableTableManager get reactions =>
      $$ReactionsTableTableManager(_db.attachedDatabase, _db.reactions);
}
