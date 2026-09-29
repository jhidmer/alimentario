import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/foods_table.dart';

part 'food_dao.g.dart';

@DriftAccessor(tables: [Foods])
class FoodDao extends DatabaseAccessor<AppDatabase> with _$FoodDaoMixin {
  FoodDao(super.attachedDatabase);

  Future<List<Food>> search(String normalizedQuery) => (select(foods)
        ..where((food) => food.isActive.equals(true) & food.normalizedName.like('%$normalizedQuery%'))
        ..orderBy([(food) => OrderingTerm(expression: food.usageCount, mode: OrderingMode.desc)]))
      .get();

  Future<List<Food>> frequent() => (select(foods)
        ..where((food) => food.isActive.equals(true))
        ..orderBy([(food) => OrderingTerm(expression: food.usageCount, mode: OrderingMode.desc)]))
      .get();

  Future<List<Food>> recent() => (select(foods)
        ..where((food) => food.isActive.equals(true))
        ..orderBy([(food) => OrderingTerm(expression: food.lastUsedAt, mode: OrderingMode.desc)]))
      .get();

  Future<Food?> findByNormalizedName(String normalizedName) =>
      (select(foods)..where((food) => food.normalizedName.equals(normalizedName))).getSingleOrNull();

  Future<Food?> findById(int id) => (select(foods)..where((food) => food.id.equals(id))).getSingleOrNull();

  Future<int> insertFood(FoodsCompanion entry) => into(foods).insert(entry);

  Future<void> deactivate(int id) => (update(foods)..where((food) => food.id.equals(id))).write(const FoodsCompanion(isActive: Value(false)));

  Future<void> recordUsage(int id, DateTime usedAt) async {
    final food = await findById(id);
    if (food == null) return;
    await (update(foods)..where((item) => item.id.equals(id))).write(
      FoodsCompanion(usageCount: Value(food.usageCount + 1), lastUsedAt: Value(usedAt), updatedAt: Value(usedAt)),
    );
  }

  Future<void> adjustUsage(int id, int delta, DateTime updatedAt) async {
    final food = await findById(id);
    if (food == null) return;
    await (update(foods)..where((item) => item.id.equals(id))).write(
      FoodsCompanion(usageCount: Value((food.usageCount + delta).clamp(0, 1 << 31).toInt()), updatedAt: Value(updatedAt)),
    );
  }
}
