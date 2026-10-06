class FoodDraft {
  const FoodDraft({required this.name, required this.categoryId, this.barcode});

  final String name;
  final int categoryId;
  final String? barcode;
}

class FoodSummary {
  const FoodSummary({required this.id, required this.name, required this.categoryId, this.barcode});

  final int id;
  final String name;
  final int categoryId;
  final String? barcode;
}

abstract interface class FoodRepository {
  Future<List<FoodSummary>> search(String query);

  Future<List<FoodSummary>> frequent();

  Future<List<FoodSummary>> recent();

  Future<FoodSummary> create(FoodDraft draft);

  Future<void> deactivate(int foodId);

  Future<FoodSummary?> findByBarcode(String barcode);
}
