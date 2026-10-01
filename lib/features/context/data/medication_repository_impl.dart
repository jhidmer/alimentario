import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<DailyMedicationSummary>> forDay(DateTime day) async {
    final items = await _database.dailyMedicationDao.forDay(day);
    return items.map((item) => DailyMedicationSummary(id: item.id, name: item.name, kind: item.kind, dosage: item.dosage, unit: item.unit, notes: item.notes)).toList();
  }

  @override
  Future<void> add(DateTime day, String name, String kind, double? dosage, String? unit, String? notes) async {
    final value = name.trim();
    if (value.isEmpty) throw const FormatException('El nombre es obligatorio.');
    await _database.dailyMedicationDao.insertItem(DailyMedicationsCompanion.insert(
      date: DateTime(day.year, day.month, day.day),
      name: value,
      kind: kind,
      dosage: Value(dosage),
      unit: Value(unit?.trim().isEmpty == true ? null : unit?.trim()),
      notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> delete(int id) => _database.dailyMedicationDao.deleteItem(id);
}
