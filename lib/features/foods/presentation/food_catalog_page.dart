import 'package:flutter/material.dart';

import '../../../core/database/database_provider.dart';
import '../data/category_repository.dart';
import '../data/food_repository_impl.dart';
import '../domain/food_repository.dart';
import 'new_food_page.dart';

class FoodCatalogPage extends StatefulWidget {
  const FoodCatalogPage({super.key});

  @override
  State<FoodCatalogPage> createState() => _FoodCatalogPageState();
}

class _FoodCatalogPageState extends State<FoodCatalogPage> {
  late final FoodRepositoryImpl _foods;
  late final CategoryRepository _categories;
  final _searchController = TextEditingController();
  Future<_CatalogData>? _catalog;

  @override
  void initState() {
    super.initState();
    _foods = FoodRepositoryImpl(appDatabase);
    _categories = CategoryRepositoryImpl(appDatabase);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    final query = _searchController.text;
    setState(() {
      _catalog = _loadData(query);
    });
  }

  Future<_CatalogData> _loadData(String query) async {
    final categories = await _categories.findAll();
    if (query.trim().isNotEmpty) {
      return _CatalogData(categories: categories, results: await _foods.search(query));
    }
    final frequent = await _foods.frequent();
    final recent = await _foods.recent();
    return _CatalogData(categories: categories, frequent: frequent, recent: recent);
  }

  Future<void> _createFood() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewFoodPage(foodRepository: _foods, categoryRepository: _categories),
      ),
    );
    if (created == true && mounted) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alimentos y categorías')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFood,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo alimento'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _load();
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<_CatalogData>(
              future: _catalog,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(onRetry: _load);
                }
                final data = snapshot.data!;
                return _CatalogContent(data: data, query: _searchController.text);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogData {
  const _CatalogData({required this.categories, this.results = const [], this.frequent = const [], this.recent = const []});

  final List<CategorySummary> categories;
  final List<FoodSummary> results;
  final List<FoodSummary> frequent;
  final List<FoodSummary> recent;
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({required this.data, required this.query});

  final _CatalogData data;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isNotEmpty) {
      return _FoodList(title: 'Resultados', foods: data.results);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        _FoodList(title: 'Frecuentes', foods: data.frequent.take(8).toList()),
        const SizedBox(height: 20),
        _FoodList(title: 'Recientes', foods: data.recent.take(8).toList()),
        const SizedBox(height: 20),
        Text('Categorías', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: data.categories.map((category) => Chip(label: Text(category.name))).toList(),
        ),
      ],
    );
  }
}

class _FoodList extends StatelessWidget {
  const _FoodList({required this.title, required this.foods});

  final String title;
  final List<FoodSummary> foods;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (foods.isEmpty)
        const Text('Aún no hay alimentos registrados.')
      else
        ...foods.map((food) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.restaurant)),
                title: Text(food.name),
                trailing: const Icon(Icons.chevron_right),
              ),
            )),
    ]);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('No se pudo cargar el catálogo.'),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
      ]),
    );
  }
}
