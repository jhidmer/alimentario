class WaterEntrySummary {
  const WaterEntrySummary({required this.id, required this.amountMl, this.notes});
  final int id;
  final int amountMl;
  final String? notes;
}

abstract interface class WaterRepository {
  Future<List<WaterEntrySummary>> forDay(DateTime day);
  Future<void> add(DateTime day, int amountMl, String? notes);
  Future<void> delete(int id);
}
