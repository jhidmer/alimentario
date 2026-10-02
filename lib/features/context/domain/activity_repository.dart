class DailyActivitySummary {
  const DailyActivitySummary({required this.id, required this.activityType, required this.durationMinutes, this.intensity, this.notes});
  final int id;
  final String activityType;
  final int durationMinutes;
  final int? intensity;
  final String? notes;
}

abstract interface class ActivityRepository {
  Future<List<DailyActivitySummary>> forDay(DateTime day);
  Future<void> add(DateTime day, String activityType, int durationMinutes, int? intensity, String? notes);
  Future<void> delete(int id);
}
