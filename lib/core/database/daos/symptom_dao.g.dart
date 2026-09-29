// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_dao.dart';

// ignore_for_file: type=lint
mixin _$SymptomDaoMixin on DatabaseAccessor<AppDatabase> {
  $SymptomsTable get symptoms => attachedDatabase.symptoms;
  SymptomDaoManager get managers => SymptomDaoManager(this);
}

class SymptomDaoManager {
  final _$SymptomDaoMixin _db;
  SymptomDaoManager(this._db);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db.attachedDatabase, _db.symptoms);
}
