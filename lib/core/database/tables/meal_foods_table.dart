import 'package:drift/drift.dart';

import 'foods_table.dart';
import 'meals_table.dart';

@TableIndex(name: 'idx_meal_foods_meal_id', columns: {#mealId})
@TableIndex(name: 'idx_meal_foods_food_id', columns: {#foodId})
@TableIndex(name: 'uq_meal_foods_meal_food', columns: {#mealId, #foodId}, unique: true)
class MealFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealId => integer().references(Meals, #id)();
  IntColumn get foodId => integer().references(Foods, #id)();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get notes => text().nullable()();
}
