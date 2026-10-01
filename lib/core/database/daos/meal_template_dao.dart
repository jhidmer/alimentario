import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/meal_template_foods_table.dart';
import '../tables/meal_templates_table.dart';

part 'meal_template_dao.g.dart';

@DriftAccessor(tables: [MealTemplates, MealTemplateFoods])
class MealTemplateDao extends DatabaseAccessor<AppDatabase> with _$MealTemplateDaoMixin {
  MealTemplateDao(super.attachedDatabase);

  Future<List<MealTemplate>> findActive() => (select(mealTemplates)
        ..where((template) => template.isActive.equals(true))
        ..orderBy([(template) => OrderingTerm(expression: template.name)]))
      .get();

  Future<List<MealTemplateFood>> foodsFor(int templateId) =>
      (select(mealTemplateFoods)..where((item) => item.templateId.equals(templateId))).get();

  Future<int> insertTemplate(MealTemplatesCompanion entry) => into(mealTemplates).insert(entry);

  Future<void> insertFood(MealTemplateFoodsCompanion entry) => into(mealTemplateFoods).insert(entry);

  Future<void> deactivate(int id) => (update(mealTemplates)..where((template) => template.id.equals(id))).write(const MealTemplatesCompanion(isActive: Value(false)));
}
