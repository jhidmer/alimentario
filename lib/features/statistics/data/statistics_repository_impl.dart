import '../../../core/database/app_database.dart';
import '../domain/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<int> registeredDays(StatisticsPeriod period) async {
    final snapshot = await this.snapshot(period);
    return snapshot.registeredDays;
  }

  @override
  Future<int> mealsCount(StatisticsPeriod period) async => (await _database.mealDao.between(period.from, period.to)).length;

  @override
  Future<int> reactionsCount(StatisticsPeriod period) async => (await _database.reactionDao.between(period.from, period.to)).length;

  @override
  Future<StatisticsSnapshot> snapshot(StatisticsPeriod period) async {
    final meals = await _database.mealDao.between(period.from, period.to);
    final reactions = await _database.reactionDao.between(period.from, period.to);
    final mealDays = <DateTime>{};
    final reactionDays = <DateTime>{};
    final foodCounts = <String, int>{};
    final categoryCounts = <String, int>{};
    final foodIds = <int>{};
    final trendMeals = <DateTime, int>{};
    final trendReactions = <DateTime, int>{};

    for (final meal in meals) {
      mealDays.add(_day(meal.mealDatetime));
      trendMeals.update(_day(meal.mealDatetime), (count) => count + 1, ifAbsent: () => 1);
      final links = await _database.mealDao.foodsForMeal(meal.id);
      for (final link in links) {
        final food = await _database.foodDao.findById(link.foodId);
        if (food == null) continue;
        foodIds.add(food.id);
        foodCounts.update(food.name, (count) => count + 1, ifAbsent: () => 1);
        final category = await _database.categoryDao.findById(food.categoryId);
        if (category != null) categoryCounts.update(category.name, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    final symptomCounts = <String, int>{};
    var intensityTotal = 0;
    var durationTotal = 0;
    var durationCount = 0;
    final hours = <int, int>{};
    final bodyAreas = <String, int>{};
    for (final reaction in reactions) {
      reactionDays.add(_day(reaction.startedAt));
      trendReactions.update(_day(reaction.startedAt), (count) => count + 1, ifAbsent: () => 1);
      intensityTotal += reaction.intensity;
      hours.update(reaction.startedAt.hour, (count) => count + 1, ifAbsent: () => 1);
      if (reaction.bodyArea != null && reaction.bodyArea!.isNotEmpty) bodyAreas.update(reaction.bodyArea!, (count) => count + 1, ifAbsent: () => 1);
      if (reaction.durationMinutes != null) {
        durationTotal += reaction.durationMinutes!;
        durationCount++;
      }
      for (final link in await _database.reactionDao.symptomsForReaction(reaction.id)) {
        final symptom = await _database.symptomDao.findById(link.symptomId);
        if (symptom != null) symptomCounts.update(symptom.name, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    final totalCategoryItems = categoryCounts.values.fold<int>(0, (sum, count) => sum + count);
    return StatisticsSnapshot(
      registeredDays: {...mealDays, ...reactionDays}.length,
      meals: meals.length,
      differentFoods: foodIds.length,
      reactions: reactions.length,
      reactionDays: reactionDays.length,
      foods: _rank(foodCounts),
      categories: categoryCounts.entries.map((entry) => CategoryFrequency(name: entry.key, count: entry.value, percentage: totalCategoryItems == 0 ? 0 : entry.value * 100 / totalCategoryItems)).toList()..sort((a, b) => b.count.compareTo(a.count)),
      symptoms: _rank(symptomCounts),
      averageIntensity: reactions.isEmpty ? 0 : intensityTotal / reactions.length,
      averageDuration: durationCount == 0 ? 0 : durationTotal / durationCount,
      commonHour: _mostCommon(hours),
      commonBodyArea: _mostCommonKey(bodyAreas),
      trends: _buildTrends(period, trendMeals, trendReactions),
    );
  }

  List<FoodFrequency> _rank(Map<String, int> values) {
    final result = values.entries.map((entry) => FoodFrequency(name: entry.key, count: entry.value)).toList();
    result.sort((a, b) => b.count.compareTo(a.count));
    return result;
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
  int? _mostCommon(Map<int, int> values) => values.isEmpty ? null : (values.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
  String? _mostCommonKey(Map<String, int> values) => values.isEmpty ? null : (values.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;

  List<TrendPoint> _buildTrends(StatisticsPeriod period, Map<DateTime, int> meals, Map<DateTime, int> reactions) {
    final from = _day(period.from);
    final to = _day(period.to);
    final points = <TrendPoint>[];
    for (var day = from; !day.isAfter(to); day = day.add(const Duration(days: 1))) {
      points.add(TrendPoint(day: day, meals: meals[day] ?? 0, reactions: reactions[day] ?? 0));
    }
    return points.length > 31 ? points.sublist(points.length - 31) : points;
  }
}
