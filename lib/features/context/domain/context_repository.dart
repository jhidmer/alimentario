class DailyContextDraft {
  const DailyContextDraft({required this.date, this.sleepMinutes, this.sleepQuality, this.stress, this.notes});
  final DateTime date;
  final int? sleepMinutes;
  final int? sleepQuality;
  final int? stress;
  final String? notes;
}

class DailyContextSummary {
  const DailyContextSummary({this.sleepMinutes, this.sleepQuality, this.stress, this.notes});
  final int? sleepMinutes;
  final int? sleepQuality;
  final int? stress;
  final String? notes;
}

abstract interface class ContextRepository {
  Future<DailyContextSummary?> forDay(DateTime day);
  Future<void> save(DailyContextDraft draft);
}
