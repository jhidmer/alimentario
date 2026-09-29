import '../../../core/database/app_database.dart';
import '../domain/reaction_repository.dart';

class SymptomRepository {
  SymptomRepository(this._database);

  final AppDatabase _database;

  Future<List<SymptomSummary>> findActive() async {
    final values = await _database.symptomDao.findActive();
    return values.map((value) => SymptomSummary(id: value.id, name: value.name)).toList();
  }

  Future<void> create(String name) async {
    final value = name.trim();
    if (value.isEmpty) throw const FormatException('El nombre es obligatorio.');
    await _database.symptomDao.insertSymptom(SymptomsCompanion.insert(name: value, createdAt: DateTime.now()));
  }

  Future<void> deactivate(int id) => _database.symptomDao.deactivate(id);
}
