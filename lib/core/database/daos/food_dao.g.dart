// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_dao.dart';

// ignore_for_file: type=lint
mixin _$FoodDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $FoodsTable get foods => attachedDatabase.foods;
  FoodDaoManager get managers => FoodDaoManager(this);
}

class FoodDaoManager {
  final _$FoodDaoMixin _db;
  FoodDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db.attachedDatabase, _db.foods);
}
