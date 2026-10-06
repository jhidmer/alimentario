import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alimentos/features/foods/domain/food_repository.dart';
import 'package:alimentos/features/foods/data/category_repository.dart';
import 'package:alimentos/features/meals/domain/meal_repository.dart';
import 'package:alimentos/features/meals/presentation/meal_entry_page.dart';
import 'package:alimentos/features/meals/data/meal_template_repository_impl.dart';

void main() {
  testWidgets('registra una comida con un alimento seleccionado', (tester) async {
    final meals = _FakeMealRepository();
    await tester.pumpWidget(MaterialApp(home: MealEntryPage(type: MealType.breakfast, foodRepository: _FakeFoodRepository(), categoryRepository: _FakeCategoryRepository(), mealRepository: meals, templateRepository: _FakeTemplateRepository())));
    await tester.pump();
    await tester.tap(find.text('Pan'));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();
    await tester.tap(find.text('Guardar comida'));
    await tester.pump();

    expect(meals.created, isTrue);
  });
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategorySummary>> findAll() async => const [CategorySummary(id: 1, name: 'Cereales')];

  @override
  Future<void> create(String name) async {}

  @override
  Future<void> deactivate(int id) async {}
}

class _FakeFoodRepository implements FoodRepository {
  @override
  Future<FoodSummary?> findByBarcode(String barcode) async => null;

  @override
  Future<FoodSummary> create(FoodDraft draft) async => const FoodSummary(id: 2, name: 'Nuevo', categoryId: 1);

  @override
  Future<void> deactivate(int foodId) async {}

  @override
  Future<List<FoodSummary>> frequent() async => const [FoodSummary(id: 1, name: 'Pan', categoryId: 1)];

  @override
  Future<List<FoodSummary>> recent() async => frequent();

  @override
  Future<List<FoodSummary>> search(String query) async => frequent();
}

class _FakeMealRepository implements MealRepository {
  bool created = false;

  @override
  Future<int> create(MealDraft draft) async {
    created = true;
    return 1;
  }

  @override
  Future<void> delete(int mealId) async {}

  @override
  Future<void> update(int mealId, MealDraft draft) async {}
}

class _FakeTemplateRepository implements MealTemplateRepository {
  @override
  Future<List<MealTemplateSummary>> findActive() async => const [];

  @override
  Future<void> create(String name, MealType type, List<int> foodIds) async {}

  @override
  Future<void> deactivate(int id) async {}
}
