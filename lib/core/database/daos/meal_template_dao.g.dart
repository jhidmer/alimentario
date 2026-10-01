// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_template_dao.dart';

// ignore_for_file: type=lint
mixin _$MealTemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $MealTemplatesTable get mealTemplates => attachedDatabase.mealTemplates;
  $CategoriesTable get categories => attachedDatabase.categories;
  $FoodsTable get foods => attachedDatabase.foods;
  $MealTemplateFoodsTable get mealTemplateFoods =>
      attachedDatabase.mealTemplateFoods;
  MealTemplateDaoManager get managers => MealTemplateDaoManager(this);
}

class MealTemplateDaoManager {
  final _$MealTemplateDaoMixin _db;
  MealTemplateDaoManager(this._db);
  $$MealTemplatesTableTableManager get mealTemplates =>
      $$MealTemplatesTableTableManager(_db.attachedDatabase, _db.mealTemplates);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db.attachedDatabase, _db.foods);
  $$MealTemplateFoodsTableTableManager get mealTemplateFoods =>
      $$MealTemplateFoodsTableTableManager(
        _db.attachedDatabase,
        _db.mealTemplateFoods,
      );
}
