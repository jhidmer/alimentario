enum MealType { breakfast, lunch, dinner, snack }

class MealFoodDraft {
  const MealFoodDraft({required this.foodId, this.quantity, this.unit});

  final int foodId;
  final double? quantity;
  final String? unit;
}

class MealDraft {
  const MealDraft({required this.mealDatetime, required this.type, required this.foodIds, this.foodItems, this.notes});

  final DateTime mealDatetime;
  final MealType type;
  final List<int> foodIds;
  final List<MealFoodDraft>? foodItems;
  final String? notes;

  List<MealFoodDraft> get effectiveFoodItems => foodItems ?? foodIds.map((id) => MealFoodDraft(foodId: id)).toList();
}

abstract interface class MealRepository {
  Future<int> create(MealDraft draft);

  Future<void> delete(int mealId);

  Future<void> update(int mealId, MealDraft draft);
}
