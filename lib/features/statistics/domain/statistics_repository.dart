class StatisticsPeriod {
  const StatisticsPeriod({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
}

class FoodFrequency {
  const FoodFrequency({required this.name, required this.count});
  final String name;
  final int count;
}

class CategoryFrequency {
  const CategoryFrequency({required this.name, required this.count, required this.percentage});
  final String name;
  final int count;
  final double percentage;
}

class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.registeredDays,
    required this.meals,
    required this.differentFoods,
    required this.reactions,
    required this.reactionDays,
    required this.foods,
    required this.categories,
    required this.symptoms,
    required this.averageIntensity,
    required this.averageDuration,
    required this.commonHour,
    required this.commonBodyArea,
  });

  final int registeredDays;
  final int meals;
  final int differentFoods;
  final int reactions;
  final int reactionDays;
  final List<FoodFrequency> foods;
  final List<CategoryFrequency> categories;
  final List<FoodFrequency> symptoms;
  final double averageIntensity;
  final double averageDuration;
  final int? commonHour;
  final String? commonBodyArea;
}

abstract interface class StatisticsRepository {
  Future<int> registeredDays(StatisticsPeriod period);

  Future<int> mealsCount(StatisticsPeriod period);

  Future<int> reactionsCount(StatisticsPeriod period);

  Future<StatisticsSnapshot> snapshot(StatisticsPeriod period);
}
