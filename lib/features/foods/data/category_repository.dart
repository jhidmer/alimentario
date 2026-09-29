import '../../../core/database/app_database.dart';

class CategorySummary {
  const CategorySummary({required this.id, required this.name});

  final int id;
  final String name;
}

abstract interface class CategoryRepository {
  Future<List<CategorySummary>> findAll();
  Future<void> create(String name);
  Future<void> deactivate(int id);
}

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<CategorySummary>> findAll() async {
    final categories = await _database.categoryDao.findAll();
    return categories.map((category) => CategorySummary(id: category.id, name: category.name)).toList();
  }

  @override
  Future<void> create(String name) async {
    final value = name.trim();
    if (value.isEmpty) throw const FormatException('El nombre es obligatorio.');
    await _database.categoryDao.insertCategory(CategoriesCompanion.insert(name: value, createdAt: DateTime.now()));
  }

  @override
  Future<void> deactivate(int id) => _database.categoryDao.deactivate(id);
}
