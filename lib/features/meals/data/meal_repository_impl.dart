import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/meal_repository.dart';

class MealSummary {
  const MealSummary({required this.id, required this.mealDatetime, required this.type, required this.foodNames, required this.foodIds, required this.foodQuantities, required this.foodUnits, this.notes});

  final int id;
  final DateTime mealDatetime;
  final MealType type;
  final List<String> foodNames;
  final List<int> foodIds;
  final Map<int, double?> foodQuantities;
  final Map<int, String?> foodUnits;
  final String? notes;

  List<String> get displayFoodNames => [
        for (var index = 0; index < foodNames.length; index++)
          foodNames[index] + (foodQuantities[foodIds[index]] == null ? '' : ' (${foodQuantities[foodIds[index]]} ${foodUnits[foodIds[index]] ?? ''})'),
      ];
}

class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(this._database);

  final AppDatabase _database;

  Future<List<MealSummary>> forDay(DateTime day) async {
    final from = DateTime(day.year, day.month, day.day);
    final to = from.add(const Duration(days: 1));
    final meals = await _database.mealDao.between(from, to);
    final summaries = <MealSummary>[];
    for (final meal in meals) {
      final links = await _database.mealDao.foodsForMeal(meal.id);
      final names = <String>[];
      final foodIds = <int>[];
      final quantities = <int, double?>{};
      final units = <int, String?>{};
      for (final link in links) {
        foodIds.add(link.foodId);
        quantities[link.foodId] = link.quantity;
        units[link.foodId] = link.unit;
        final food = await _database.foodDao.findById(link.foodId);
        if (food != null) names.add(food.name);
      }
      summaries.add(MealSummary(
        id: meal.id,
        mealDatetime: meal.mealDatetime,
        type: _parseMealType(meal.mealType),
        foodNames: names,
        foodIds: foodIds,
        foodQuantities: quantities,
        foodUnits: units,
        notes: meal.notes,
      ));
    }
    return summaries;
  }

  Future<Set<DateTime>> daysWithMeals(DateTime month) async {
    final from = DateTime(month.year, month.month);
    final meals = await _database.mealDao.between(from, DateTime(month.year, month.month + 1));
    return meals.map((meal) => DateTime(meal.mealDatetime.year, meal.mealDatetime.month, meal.mealDatetime.day)).toSet();
  }

  @override
  Future<int> create(MealDraft draft) async {
    if (draft.foodIds.isEmpty) {
      throw const FormatException('Selecciona al menos un alimento.');
    }
    final now = DateTime.now();
    late int mealId;
    await _database.transaction(() async {
      mealId = await _database.mealDao.insertMeal(MealsCompanion.insert(
        mealDatetime: draft.mealDatetime,
        mealType: draft.type.name,
        notes: Value(draft.notes?.trim().isEmpty == true ? null : draft.notes?.trim()),
        createdAt: now,
        updatedAt: now,
      ));
      for (final item in draft.effectiveFoodItems) {
        await _database.mealDao.insertMealFood(MealFoodsCompanion.insert(mealId: mealId, foodId: item.foodId, quantity: Value(item.quantity), unit: Value(item.unit)));
        await _database.foodDao.recordUsage(item.foodId, draft.mealDatetime);
      }
    });
    return mealId;
  }

  @override
  Future<void> delete(int mealId) => _database.transaction(() => _database.mealDao.deleteMeal(mealId));

  @override
  Future<void> update(int mealId, MealDraft draft) async {
    if (draft.foodIds.isEmpty) throw const FormatException('Selecciona al menos un alimento.');
    final existing = await _database.mealDao.foodsForMeal(mealId);
    final oldIds = existing.map((item) => item.foodId).toSet();
      final newItems = draft.effectiveFoodItems;
      final newIds = newItems.map((item) => item.foodId).toSet();
    final now = DateTime.now();
    await _database.transaction(() async {
      await _database.mealDao.updateMeal(mealId, MealsCompanion(
        mealDatetime: Value(draft.mealDatetime),
        mealType: Value(draft.type.name),
        notes: Value(draft.notes?.trim().isEmpty == true ? null : draft.notes?.trim()),
        updatedAt: Value(now),
      ));
      await _database.mealDao.deleteMealFoods(mealId);
      for (final item in newItems) {
        await _database.mealDao.insertMealFood(MealFoodsCompanion.insert(mealId: mealId, foodId: item.foodId, quantity: Value(item.quantity), unit: Value(item.unit)));
      }
      for (final foodId in oldIds.difference(newIds)) {
        await _database.foodDao.adjustUsage(foodId, -1, now);
      }
      for (final foodId in newIds.difference(oldIds)) {
        await _database.foodDao.recordUsage(foodId, draft.mealDatetime);
      }
    });
  }

  MealType _parseMealType(String value) => MealType.values.firstWhere((type) => type.name == value, orElse: () => MealType.snack);
}
