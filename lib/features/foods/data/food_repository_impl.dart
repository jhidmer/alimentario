import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository {
  FoodRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<FoodSummary>> search(String query) async {
    final foods = await _database.foodDao.search(normalizeFoodName(query));
    return foods.map(_toSummary).toList();
  }

  @override
  Future<List<FoodSummary>> frequent() async {
    final foods = await _database.foodDao.frequent();
    return foods.map(_toSummary).toList();
  }

  @override
  Future<List<FoodSummary>> recent() async {
    final foods = await _database.foodDao.recent();
    return foods.where((food) => food.lastUsedAt != null).map(_toSummary).toList();
  }

  @override
  Future<FoodSummary> create(FoodDraft draft) async {
    final name = draft.name.trim();
    final normalizedName = normalizeFoodName(name);
    if (name.isEmpty) {
      throw const FormatException('El nombre del alimento es obligatorio.');
    }
    if (normalizedName.isEmpty) {
      throw const FormatException('El nombre del alimento no es válido.');
    }
    if (await _database.foodDao.findByNormalizedName(normalizedName) != null) {
      throw const FormatException('Ya existe un alimento con ese nombre.');
    }
    final barcode = draft.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty && await _database.foodDao.findByBarcode(barcode) != null) {
      throw const FormatException('Ya existe un alimento con ese código.');
    }

    final now = DateTime.now();
    final id = await _database.foodDao.insertFood(
      FoodsCompanion.insert(
        categoryId: draft.categoryId,
        name: name,
        normalizedName: normalizedName,
        barcode: Value(barcode?.isEmpty == true ? null : barcode),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final food = await _database.foodDao.findById(id);
    if (food == null) {
      throw StateError('No se pudo recuperar el alimento creado.');
    }
    return _toSummary(food);
  }

  @override
  Future<void> deactivate(int foodId) => _database.foodDao.deactivate(foodId);

  FoodSummary _toSummary(Food food) => FoodSummary(id: food.id, name: food.name, categoryId: food.categoryId, barcode: food.barcode);

  @override
  Future<FoodSummary?> findByBarcode(String barcode) async {
    final food = await _database.foodDao.findByBarcode(barcode);
    return food == null ? null : _toSummary(food);
  }
}

String normalizeFoodName(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[áàäâã]'), 'a')
      .replaceAll(RegExp('[éèëê]'), 'e')
      .replaceAll(RegExp('[íìïî]'), 'i')
      .replaceAll(RegExp('[óòöôõ]'), 'o')
      .replaceAll(RegExp('[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'\s+'), ' ');
}
