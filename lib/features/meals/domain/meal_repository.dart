enum MealType { breakfast, lunch, dinner, snack }

class MealDraft {
  const MealDraft({required this.mealDatetime, required this.type, required this.foodIds, this.notes});

  final DateTime mealDatetime;
  final MealType type;
  final List<int> foodIds;
  final String? notes;
}

abstract interface class MealRepository {
  Future<int> create(MealDraft draft);

  Future<void> delete(int mealId);

  Future<void> update(int mealId, MealDraft draft);
}
