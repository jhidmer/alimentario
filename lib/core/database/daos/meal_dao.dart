import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/meal_foods_table.dart';
import '../tables/meals_table.dart';

part 'meal_dao.g.dart';

@DriftAccessor(tables: [Meals, MealFoods])
class MealDao extends DatabaseAccessor<AppDatabase> with _$MealDaoMixin {
  MealDao(super.attachedDatabase);

  Future<List<Meal>> between(DateTime from, DateTime to) => (select(meals)
        ..where((meal) => meal.mealDatetime.isBetweenValues(from, to))
        ..orderBy([(meal) => OrderingTerm(expression: meal.mealDatetime)]))
      .get();

  Future<int> insertMeal(MealsCompanion entry) => into(meals).insert(entry);

  Future<void> insertMealFood(MealFoodsCompanion entry) => into(mealFoods).insert(entry);

  Future<void> updateMeal(int mealId, MealsCompanion entry) => (update(meals)..where((meal) => meal.id.equals(mealId))).write(entry);

  Future<void> deleteMealFoods(int mealId) => (delete(mealFoods)..where((item) => item.mealId.equals(mealId))).go();

  Future<List<MealFood>> foodsForMeal(int mealId) => (select(mealFoods)..where((item) => item.mealId.equals(mealId))).get();

  Future<void> deleteMeal(int mealId) async {
    await (delete(mealFoods)..where((item) => item.mealId.equals(mealId))).go();
    await (delete(meals)..where((meal) => meal.id.equals(mealId))).go();
  }
}
