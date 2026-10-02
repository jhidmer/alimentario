import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/daily_activities_table.dart';

part 'daily_activity_dao.g.dart';

@DriftAccessor(tables: [DailyActivities])
class DailyActivityDao extends DatabaseAccessor<AppDatabase> with _$DailyActivityDaoMixin {
  DailyActivityDao(super.attachedDatabase);

  Future<List<DailyActivity>> forDay(DateTime day) => (select(dailyActivities)
        ..where((activity) => activity.date.equals(DateTime(day.year, day.month, day.day)))
        ..orderBy([(activity) => OrderingTerm(expression: activity.activityType)]))
      .get();

  Future<int> insertActivity(DailyActivitiesCompanion entry) => into(dailyActivities).insert(entry);

  Future<void> deleteActivity(int id) => (delete(dailyActivities)..where((activity) => activity.id.equals(id))).go();
}
