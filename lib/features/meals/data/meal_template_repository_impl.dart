import '../../../core/database/app_database.dart';
import '../domain/meal_repository.dart';

class MealTemplateSummary {
  const MealTemplateSummary({required this.id, required this.name, required this.type, required this.foodIds, required this.foodNames});

  final int id;
  final String name;
  final MealType type;
  final List<int> foodIds;
  final List<String> foodNames;
}

abstract interface class MealTemplateRepository {
  Future<List<MealTemplateSummary>> findActive();
  Future<void> create(String name, MealType type, List<int> foodIds);
  Future<void> deactivate(int id);
}

class MealTemplateRepositoryImpl implements MealTemplateRepository {
  MealTemplateRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<MealTemplateSummary>> findActive() async {
    final templates = await _database.mealTemplateDao.findActive();
    final result = <MealTemplateSummary>[];
    for (final template in templates) {
      final links = await _database.mealTemplateDao.foodsFor(template.id);
      final ids = links.map((link) => link.foodId).toList();
      final names = <String>[];
      for (final id in ids) {
        final food = await _database.foodDao.findById(id);
        if (food != null) names.add(food.name);
      }
      result.add(MealTemplateSummary(id: template.id, name: template.name, type: _type(template.mealType), foodIds: ids, foodNames: names));
    }
    return result;
  }

  @override
  Future<void> create(String name, MealType type, List<int> foodIds) async {
    final value = name.trim();
    if (value.isEmpty || foodIds.isEmpty) throw const FormatException('Indica un nombre y al menos un alimento.');
    final now = DateTime.now();
    await _database.transaction(() async {
      final id = await _database.mealTemplateDao.insertTemplate(MealTemplatesCompanion.insert(name: value, mealType: type.name, createdAt: now, updatedAt: now));
      for (final foodId in foodIds.toSet()) {
        await _database.mealTemplateDao.insertFood(MealTemplateFoodsCompanion.insert(templateId: id, foodId: foodId));
      }
    });
  }

  @override
  Future<void> deactivate(int id) => _database.mealTemplateDao.deactivate(id);

  MealType _type(String value) => MealType.values.firstWhere((type) => type.name == value, orElse: () => MealType.snack);
}
