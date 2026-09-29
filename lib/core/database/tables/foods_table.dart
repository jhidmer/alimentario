import 'package:drift/drift.dart';

import 'categories_table.dart';

@TableIndex(name: 'idx_foods_normalized_name', columns: {#normalizedName}, unique: true)
@TableIndex(name: 'idx_foods_usage_count', columns: {#usageCount})
@TableIndex(name: 'idx_foods_last_used_at', columns: {#lastUsedAt})
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
