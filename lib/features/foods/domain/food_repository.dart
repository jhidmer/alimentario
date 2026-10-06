class FoodDraft {
  const FoodDraft({required this.name, required this.categoryId, this.barcode});

  final String name;
  final int categoryId;
  final String? barcode;
}

class FoodSummary {
  const FoodSummary({
    required this.id,
    required this.name,
    required this.categoryId,
    this.barcode,
    this.usageCount = 0,
    this.lastUsedAt,
    this.createdAt,
  });

  final int id;
  final String name;
  final int categoryId;
  final String? barcode;
  final int usageCount;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;
}

abstract interface class FoodRepository {
  Future<List<FoodSummary>> search(String query);

  Future<List<FoodSummary>> frequent();

  Future<List<FoodSummary>> recent();

  Future<FoodSummary> create(FoodDraft draft);

  Future<void> deactivate(int foodId);

  Future<FoodSummary?> findByBarcode(String barcode);

  Future<FoodSummary?> findById(int foodId);

  Future<void> updateBarcode(int foodId, String? barcode);
}
