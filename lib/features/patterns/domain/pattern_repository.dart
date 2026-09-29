class PatternWindow {
  const PatternWindow({required this.hours});
  final int hours;
}

class PatternResult {
  const PatternResult({required this.foodName, required this.total, required this.withReaction, required this.withoutReaction, required this.symptoms});

  final String foodName;
  final int total;
  final int withReaction;
  final int withoutReaction;
  final Map<String, int> symptoms;

  double get percentage => total == 0 ? 0 : withReaction * 100 / total;
}

abstract interface class PatternRepository {
  Future<List<PatternResult>> associations(PatternWindow window);
}
