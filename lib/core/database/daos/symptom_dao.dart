import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/symptoms_table.dart';

part 'symptom_dao.g.dart';

@DriftAccessor(tables: [Symptoms])
class SymptomDao extends DatabaseAccessor<AppDatabase> with _$SymptomDaoMixin {
  SymptomDao(super.attachedDatabase);

  Future<List<Symptom>> findActive() => (select(symptoms)
        ..where((symptom) => symptom.isActive.equals(true))
        ..orderBy([(symptom) => OrderingTerm(expression: symptom.name)]))
      .get();

  Future<Symptom?> findById(int id) => (select(symptoms)..where((symptom) => symptom.id.equals(id))).getSingleOrNull();

  Future<int> insertSymptom(SymptomsCompanion entry) => into(symptoms).insert(entry);

  Future<void> deactivate(int id) => (update(symptoms)..where((symptom) => symptom.id.equals(id))).write(const SymptomsCompanion(isActive: Value(false)));
}
