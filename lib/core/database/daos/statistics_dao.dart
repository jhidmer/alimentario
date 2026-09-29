import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/meals_table.dart';
import '../tables/reactions_table.dart';

part 'statistics_dao.g.dart';

@DriftAccessor(tables: [Meals, Reactions])
class StatisticsDao extends DatabaseAccessor<AppDatabase> with _$StatisticsDaoMixin {
  StatisticsDao(super.attachedDatabase);

  Future<int> mealsCount(DateTime from, DateTime to) async {
    final expression = meals.id.count();
    final query = selectOnly(meals)
      ..addColumns([expression])
      ..where(meals.mealDatetime.isBetweenValues(from, to));
    return (await query.getSingle()).read(expression) ?? 0;
  }

  Future<int> reactionsCount(DateTime from, DateTime to) async {
    final expression = reactions.id.count();
    final query = selectOnly(reactions)
      ..addColumns([expression])
      ..where(reactions.startedAt.isBetweenValues(from, to));
    return (await query.getSingle()).read(expression) ?? 0;
  }
}
