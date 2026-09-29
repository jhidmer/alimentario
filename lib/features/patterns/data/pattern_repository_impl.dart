import '../../../core/database/app_database.dart';
import '../domain/pattern_repository.dart';

class PatternRepositoryImpl implements PatternRepository {
  PatternRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<PatternResult>> associations(PatternWindow window) async {
    final now = DateTime.now();
    final meals = await _database.mealDao.between(DateTime(1970), now.add(const Duration(seconds: 1)));
    final reactions = await _database.reactionDao.between(DateTime(1970), now.add(const Duration(seconds: 1)));
    final totals = <int, int>{};
    final matches = <int, int>{};
    final symptoms = <int, Map<String, int>>{};
    for (final meal in meals) {
      final links = await _database.mealDao.foodsForMeal(meal.id);
      for (final link in links) {
        totals.update(link.foodId, (value) => value + 1, ifAbsent: () => 1);
        final end = meal.mealDatetime.add(Duration(hours: window.hours));
        final related = reactions.where((reaction) => !reaction.startedAt.isBefore(meal.mealDatetime) && !reaction.startedAt.isAfter(end)).toList();
        if (related.isEmpty) continue;
        matches.update(link.foodId, (value) => value + 1, ifAbsent: () => 1);
        final foodSymptoms = symptoms.putIfAbsent(link.foodId, () => {});
        for (final reaction in related) {
          for (final symptomLink in await _database.reactionDao.symptomsForReaction(reaction.id)) {
            final symptom = await _database.symptomDao.findById(symptomLink.symptomId);
            if (symptom != null) foodSymptoms.update(symptom.name, (value) => value + 1, ifAbsent: () => 1);
          }
        }
      }
    }
    final results = <PatternResult>[];
    for (final entry in totals.entries) {
      final food = await _database.foodDao.findById(entry.key);
      if (food == null) continue;
      final withReaction = matches[entry.key] ?? 0;
      results.add(PatternResult(foodName: food.name, total: entry.value, withReaction: withReaction, withoutReaction: entry.value - withReaction, symptoms: symptoms[entry.key] ?? {}));
    }
    results.sort((a, b) => b.percentage.compareTo(a.percentage));
    return results;
  }
}
