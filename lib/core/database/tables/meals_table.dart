import 'package:drift/drift.dart';

@TableIndex(name: 'idx_meals_meal_datetime', columns: {#mealDatetime})
@TableIndex(name: 'idx_meals_meal_type', columns: {#mealType})
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get mealDatetime => dateTime()();
  TextColumn get mealType => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
