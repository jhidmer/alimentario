import 'package:drift/drift.dart';

import 'foods_table.dart';
import 'meal_templates_table.dart';

@TableIndex(name: 'uq_meal_template_foods_template_food', columns: {#templateId, #foodId}, unique: true)
class MealTemplateFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().references(MealTemplates, #id)();
  IntColumn get foodId => integer().references(Foods, #id)();
}
