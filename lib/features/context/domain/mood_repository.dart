class MoodSummary {
  const MoodSummary({required this.mood, this.notes});
  final int mood;
  final String? notes;
}

abstract interface class MoodRepository {
  Future<MoodSummary?> forDay(DateTime day);
  Future<void> save(DateTime day, int mood, String? notes);
}
