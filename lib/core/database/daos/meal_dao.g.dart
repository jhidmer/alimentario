// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_dao.dart';

// ignore_for_file: type=lint
mixin _$MealDaoMixin on DatabaseAccessor<AppDatabase> {
  $MealsTable get meals => attachedDatabase.meals;
  $CategoriesTable get categories => attachedDatabase.categories;
  $FoodsTable get foods => attachedDatabase.foods;
  $MealFoodsTable get mealFoods => attachedDatabase.mealFoods;
  MealDaoManager get managers => MealDaoManager(this);
}

class MealDaoManager {
  final _$MealDaoMixin _db;
  MealDaoManager(this._db);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db.attachedDatabase, _db.meals);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db.attachedDatabase, _db.foods);
  $$MealFoodsTableTableManager get mealFoods =>
      $$MealFoodsTableTableManager(_db.attachedDatabase, _db.mealFoods);
}
