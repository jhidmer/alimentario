import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.attachedDatabase);

  Future<List<Category>> findAll() => (select(categories)
        ..where((category) => category.isActive.equals(true))
        ..orderBy([(category) => OrderingTerm(expression: category.name)]))
      .get();

  Future<Category?> findById(int id) => (select(categories)..where((category) => category.id.equals(id))).getSingleOrNull();

  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);

  Future<void> deactivate(int id) => (update(categories)..where((category) => category.id.equals(id))).write(const CategoriesCompanion(isActive: Value(false)));
}
