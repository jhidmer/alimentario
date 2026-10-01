import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/daily_medications_table.dart';

part 'daily_medication_dao.g.dart';

@DriftAccessor(tables: [DailyMedications])
class DailyMedicationDao extends DatabaseAccessor<AppDatabase> with _$DailyMedicationDaoMixin {
  DailyMedicationDao(super.attachedDatabase);

  Future<List<DailyMedication>> forDay(DateTime day) => (select(dailyMedications)
        ..where((item) => item.date.equals(DateTime(day.year, day.month, day.day)))
        ..orderBy([(item) => OrderingTerm(expression: item.name)]))
      .get();

  Future<int> insertItem(DailyMedicationsCompanion entry) => into(dailyMedications).insert(entry);

  Future<void> deleteItem(int id) => (delete(dailyMedications)..where((item) => item.id.equals(id))).go();
}
