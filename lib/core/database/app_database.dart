import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/category_dao.dart';
import 'daos/food_dao.dart';
import 'daos/meal_dao.dart';
import 'daos/meal_template_dao.dart';
import 'daos/daily_context_dao.dart';
import 'daos/daily_medication_dao.dart';
import 'daos/daily_activity_dao.dart';
import 'daos/daily_water_entry_dao.dart';
import 'daos/daily_mood_dao.dart';
import 'daos/reaction_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/statistics_dao.dart';
import 'daos/symptom_dao.dart';
import 'tables/categories_table.dart';
import 'tables/foods_table.dart';
import 'tables/meal_foods_table.dart';
import 'tables/meals_table.dart';
import 'tables/meal_template_foods_table.dart';
import 'tables/meal_templates_table.dart';
import 'tables/daily_contexts_table.dart';
import 'tables/daily_medications_table.dart';
import 'tables/daily_activities_table.dart';
import 'tables/daily_water_entries_table.dart';
import 'tables/daily_moods_table.dart';
import 'tables/reaction_photos_table.dart';
import 'tables/reaction_symptoms_table.dart';
import 'tables/reactions_table.dart';
import 'tables/settings_table.dart';
import 'tables/symptoms_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Categories,
  Foods,
  Meals,
  MealTemplates,
  MealTemplateFoods,
  DailyContexts,
  DailyMedications,
  DailyActivities,
  DailyWaterEntries,
  DailyMoods,
  MealFoods,
  Symptoms,
  Reactions,
  ReactionSymptoms,
  ReactionPhotos,
  AppSettings,
  SchemaMetadata,
], daos: [
  CategoryDao,
  FoodDao,
  MealDao,
  MealTemplateDao,
  DailyContextDao,
  DailyMedicationDao,
  DailyActivityDao,
  DailyWaterEntryDao,
  DailyMoodDao,
  ReactionDao,
  StatisticsDao,
  SettingsDao,
  SymptomDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open() => AppDatabase(_openConnection());

  Future<String> filePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, 'diario_alimentario.sqlite');
  }

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaults();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) await m.addColumn(categories, categories.isActive);
          if (from < 3) {
            await m.createTable(mealTemplates);
            await m.createTable(mealTemplateFoods);
          }
          if (from < 4) await m.createTable(dailyContexts);
          if (from < 5) await m.createTable(dailyMedications);
          if (from < 6) await m.createTable(dailyActivities);
          if (from < 7) await m.createTable(dailyWaterEntries);
          if (from < 8) await m.createTable(dailyMoods);
          if (from < 9) {
            await m.addColumn(foods, foods.barcode);
            await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS uq_foods_barcode ON foods (barcode)');
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await _ensureDefaultSymptoms();
          await _ensureDefaultFoods();
        },
      );

  Future<void> _seedDefaults() async {
    final now = DateTime.now();
    await batch((batch) {
      batch.insertAll(categories, [
        CategoriesCompanion.insert(name: 'Frutas', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Verduras', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Carnes', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Pescados', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Lácteos', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Huevos', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Cereales', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Tubérculos', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Legumbres', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Dulces', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Bebidas', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Grasas y salsas', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Comida preparada', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Snacks', isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(name: 'Otros', isDefault: const Value(true), createdAt: now),
      ]);
      batch.insert(schemaMetadata, SchemaMetadataCompanion.insert(key: 'database_version', value: const Value('9')));
      batch.insertAll(symptoms, _defaultSymptoms(now));
    });
    await _ensureDefaultFoods();
  }

  Future<void> _ensureDefaultSymptoms() async {
    if ((await select(symptoms).get()).isNotEmpty) return;
    await batch((batch) => batch.insertAll(symptoms, _defaultSymptoms(DateTime.now())));
  }

  Future<void> _ensureDefaultFoods() async {
    final categoriesByName = {
      for (final category in await select(categories).get()) category.name: category,
    };
    final existingNames = {
      for (final food in await select(foods).get()) food.normalizedName,
    };
    final now = DateTime.now();
    final entries = <FoodsCompanion>[];
    for (final item in _defaultFoodCatalog) {
      final category = categoriesByName[item.category];
      final normalizedName = _normalizeSeedName(item.name);
      if (category == null || existingNames.contains(normalizedName)) continue;
      existingNames.add(normalizedName);
      entries.add(FoodsCompanion.insert(
        categoryId: category.id,
        name: item.name,
        normalizedName: normalizedName,
        createdAt: now,
        updatedAt: now,
      ));
    }
    if (entries.isNotEmpty) await batch((batch) => batch.insertAll(foods, entries));
  }

  Future<void> deleteAllUserData() async {
    final photos = await select(reactionPhotos).get();
    await transaction(() async {
      await delete(reactionPhotos).go();
      await delete(reactionSymptoms).go();
      await delete(reactions).go();
      await delete(mealFoods).go();
      await delete(meals).go();
      await delete(mealTemplateFoods).go();
      await delete(mealTemplates).go();
      await delete(dailyContexts).go();
      await delete(dailyMedications).go();
      await delete(dailyActivities).go();
      await delete(dailyWaterEntries).go();
      await delete(dailyMoods).go();
      await delete(foods).go();
      await delete(appSettings).go();
      await delete(schemaMetadata).go();
      await into(schemaMetadata).insert(SchemaMetadataCompanion.insert(key: 'database_version', value: const Value('9')));
    });
    for (final photo in photos) {
      final file = File(photo.filePath);
      if (await file.exists()) await file.delete();
    }
  }

  List<SymptomsCompanion> _defaultSymptoms(DateTime now) => [
        'Manchas rojas',
        'Ronchas',
        'Hinchazón',
        'Picazón',
        'Ardor',
        'Dolor abdominal',
        'Náuseas',
        'Diarrea',
        'Distensión abdominal',
        'Dolor de cabeza',
        'Mareo',
        'Otro',
      ].map((name) => SymptomsCompanion.insert(name: name, isDefault: const Value(true), createdAt: now)).toList();

  String _normalizeSeedName(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[áàäâã]'), 'a')
      .replaceAll(RegExp('[éèëê]'), 'e')
      .replaceAll(RegExp('[íìïî]'), 'i')
      .replaceAll(RegExp('[óòöôõ]'), 'o')
      .replaceAll(RegExp('[úùüû]'), 'u')
      .replaceAll('ñ', 'n');
}

class _SeedFood {
  const _SeedFood(this.name, this.category);
  final String name;
  final String category;
}

const _defaultFoodCatalog = <_SeedFood>[
  _SeedFood('Manzana', 'Frutas'),
  _SeedFood('Plátano', 'Frutas'),
  _SeedFood('Naranja', 'Frutas'),
  _SeedFood('Mandarina', 'Frutas'),
  _SeedFood('Fresa', 'Frutas'),
  _SeedFood('Uva', 'Frutas'),
  _SeedFood('Mango', 'Frutas'),
  _SeedFood('Papaya', 'Frutas'),
  _SeedFood('Piña', 'Frutas'),
  _SeedFood('Sandía', 'Frutas'),
  _SeedFood('Melón', 'Frutas'),
  _SeedFood('Palta', 'Frutas'),
  _SeedFood('Granadilla', 'Frutas'),
  _SeedFood('Maracuyá', 'Frutas'),
  _SeedFood('Chirimoya', 'Frutas'),
  _SeedFood('Lucuma', 'Frutas'),
  _SeedFood('Lechuga', 'Verduras'),
  _SeedFood('Tomate', 'Verduras'),
  _SeedFood('Zanahoria', 'Verduras'),
  _SeedFood('Brócoli', 'Verduras'),
  _SeedFood('Espinaca', 'Verduras'),
  _SeedFood('Cebolla', 'Verduras'),
  _SeedFood('Pepino', 'Verduras'),
  _SeedFood('Zapallo', 'Verduras'),
  _SeedFood('Coliflor', 'Verduras'),
  _SeedFood('Pimiento', 'Verduras'),
  _SeedFood('Ajo', 'Verduras'),
  _SeedFood('Culantro', 'Verduras'),
  _SeedFood('Pollo', 'Carnes'),
  _SeedFood('Carne de res', 'Carnes'),
  _SeedFood('Carne de cerdo', 'Carnes'),
  _SeedFood('Pavo', 'Carnes'),
  _SeedFood('Cordero', 'Carnes'),
  _SeedFood('Carne molida', 'Carnes'),
  _SeedFood('Atún', 'Pescados'),
  _SeedFood('Salmón', 'Pescados'),
  _SeedFood('Merluza', 'Pescados'),
  _SeedFood('Trucha', 'Pescados'),
  _SeedFood('Sardina', 'Pescados'),
  _SeedFood('Anchoveta', 'Pescados'),
  _SeedFood('Leche', 'Lácteos'),
  _SeedFood('Yogur', 'Lácteos'),
  _SeedFood('Queso', 'Lácteos'),
  _SeedFood('Mantequilla', 'Lácteos'),
  _SeedFood('Crema de leche', 'Lácteos'),
  _SeedFood('Huevo', 'Huevos'),
  _SeedFood('Arroz', 'Cereales'),
  _SeedFood('Pan', 'Cereales'),
  _SeedFood('Avena', 'Cereales'),
  _SeedFood('Quinua', 'Cereales'),
  _SeedFood('Fideos', 'Cereales'),
  _SeedFood('Maíz', 'Cereales'),
  _SeedFood('Cebada', 'Cereales'),
  _SeedFood('Papa', 'Tubérculos'),
  _SeedFood('Camote', 'Tubérculos'),
  _SeedFood('Yuca', 'Tubérculos'),
  _SeedFood('Olluco', 'Tubérculos'),
  _SeedFood('Lentejas', 'Legumbres'),
  _SeedFood('Frejoles', 'Legumbres'),
  _SeedFood('Garbanzos', 'Legumbres'),
  _SeedFood('Arvejas', 'Legumbres'),
  _SeedFood('Soya', 'Legumbres'),
  _SeedFood('Chocolate', 'Dulces'),
  _SeedFood('Galletas', 'Dulces'),
  _SeedFood('Torta', 'Dulces'),
  _SeedFood('Helado', 'Dulces'),
  _SeedFood('Miel', 'Dulces'),
  _SeedFood('Café', 'Bebidas'),
  _SeedFood('Té', 'Bebidas'),
  _SeedFood('Infusión de manzanilla', 'Bebidas'),
  _SeedFood('Chicha morada', 'Bebidas'),
  _SeedFood('Emoliente', 'Bebidas'),
  _SeedFood('Jugo de naranja', 'Bebidas'),
  _SeedFood('Aceite vegetal', 'Grasas y salsas'),
  _SeedFood('Aceite de oliva', 'Grasas y salsas'),
  _SeedFood('Mayonesa', 'Grasas y salsas'),
  _SeedFood('Ketchup', 'Grasas y salsas'),
  _SeedFood('Mostaza', 'Grasas y salsas'),
  _SeedFood('Ceviche', 'Comida preparada'),
  _SeedFood('Ají de gallina', 'Comida preparada'),
  _SeedFood('Lomo saltado', 'Comida preparada'),
  _SeedFood('Arroz con pollo', 'Comida preparada'),
  _SeedFood('Causa', 'Comida preparada'),
  _SeedFood('Tallarines', 'Comida preparada'),
  _SeedFood('Pachamanca', 'Comida preparada'),
  _SeedFood('Cancha', 'Snacks'),
  _SeedFood('Chifles', 'Snacks'),
  _SeedFood('Maní', 'Snacks'),
  _SeedFood('Popcorn', 'Snacks'),
  _SeedFood('Papas fritas', 'Snacks'),
  _SeedFood('Otros', 'Otros'),
];

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'diario_alimentario.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
