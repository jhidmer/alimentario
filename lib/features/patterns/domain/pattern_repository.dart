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

  String get confidenceLabel {
    if (total < 5) return 'Datos insuficientes';
    if (total < 10) return 'Confianza baja';
    if (total < 20) return 'Confianza moderada';
    return 'Muestra más estable';
  }

  bool get hasMinimumSample => total >= 5;
}

abstract interface class PatternRepository {
  Future<List<PatternResult>> associations(PatternWindow window);
}
