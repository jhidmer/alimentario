class DailyMedicationSummary {
  const DailyMedicationSummary({required this.id, required this.name, required this.kind, this.dosage, this.unit, this.notes});
  final int id;
  final String name;
  final String kind;
  final double? dosage;
  final String? unit;
  final String? notes;
}

abstract interface class MedicationRepository {
  Future<List<DailyMedicationSummary>> forDay(DateTime day);
  Future<void> add(DateTime day, String name, String kind, double? dosage, String? unit, String? notes);
  Future<void> delete(int id);
}
