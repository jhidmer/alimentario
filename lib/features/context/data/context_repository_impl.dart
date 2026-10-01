import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/context_repository.dart';

class ContextRepositoryImpl implements ContextRepository {
  ContextRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<DailyContextSummary?> forDay(DateTime day) async {
    final value = await _database.dailyContextDao.forDay(day);
    if (value == null) return null;
    return DailyContextSummary(sleepMinutes: value.sleepMinutes, sleepQuality: value.sleepQuality, stress: value.stress, notes: value.notes);
  }

  @override
  Future<void> save(DailyContextDraft draft) => _database.dailyContextDao.save(DailyContextsCompanion.insert(
        date: DateTime(draft.date.year, draft.date.month, draft.date.day),
        sleepMinutes: Value(draft.sleepMinutes),
        sleepQuality: Value(draft.sleepQuality),
        stress: Value(draft.stress),
        notes: Value(draft.notes?.trim().isEmpty == true ? null : draft.notes?.trim()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
}
