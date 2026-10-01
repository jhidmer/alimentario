// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_medication_dao.dart';

// ignore_for_file: type=lint
mixin _$DailyMedicationDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyMedicationsTable get dailyMedications =>
      attachedDatabase.dailyMedications;
  DailyMedicationDaoManager get managers => DailyMedicationDaoManager(this);
}

class DailyMedicationDaoManager {
  final _$DailyMedicationDaoMixin _db;
  DailyMedicationDaoManager(this._db);
  $$DailyMedicationsTableTableManager get dailyMedications =>
      $$DailyMedicationsTableTableManager(
        _db.attachedDatabase,
        _db.dailyMedications,
      );
}
