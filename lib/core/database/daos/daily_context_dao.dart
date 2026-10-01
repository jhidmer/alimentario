import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/daily_contexts_table.dart';

part 'daily_context_dao.g.dart';

@DriftAccessor(tables: [DailyContexts])
class DailyContextDao extends DatabaseAccessor<AppDatabase> with _$DailyContextDaoMixin {
  DailyContextDao(super.attachedDatabase);

  Future<DailyContext?> forDay(DateTime day) => (select(dailyContexts)..where((context) => context.date.equals(DateTime(day.year, day.month, day.day)))).getSingleOrNull();

  Future<void> save(DailyContextsCompanion entry) => into(dailyContexts).insertOnConflictUpdate(entry);
}
