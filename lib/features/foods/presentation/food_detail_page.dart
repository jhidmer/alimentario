import 'package:flutter/material.dart';

import '../data/category_repository.dart';
import '../domain/food_repository.dart';
import 'barcode_scanner_page.dart';

class FoodDetailPage extends StatefulWidget {
  const FoodDetailPage({
    required this.foodRepository,
    required this.categoryRepository,
    required this.foodId,
    super.key,
  });

  final FoodRepository foodRepository;
  final CategoryRepository categoryRepository;
  final int foodId;

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late Future<_FoodDetail> _detail;

  @override
  void initState() {
    super.initState();
    _detail = _load();
  }

  Future<_FoodDetail> _load() async {
    final food = await widget.foodRepository.findById(widget.foodId);
    if (food == null) throw StateError('Alimento no encontrado');
    final categories = await widget.categoryRepository.findAll();
    return _FoodDetail(food: food, categories: categories);
  }

  String? _categoryName(List<CategorySummary> categories, int categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editBarcode({String? scanned}) async {
    final snapshot = await _detail;
    if (!mounted) return;
    final controller = TextEditingController(text: scanned ?? snapshot.food.barcode ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Código de barras'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ej. 7750000000012'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          if (snapshot.food.barcode != null)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(''),
              child: const Text('Quitar código'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (value == null) return;
    try {
      await widget.foodRepository.updateBarcode(widget.foodId, value.trim());
      if (!mounted) return;
      setState(() => _detail = _load());
      _showMessage(value.trim().isEmpty ? 'Código eliminado.' : 'Código guardado.');
    } on FormatException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _scanBarcode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (code == null || !mounted) return;
    final owner = await widget.foodRepository.findByBarcode(code);
    if (!mounted) return;
    if (owner != null && owner.id != widget.foodId) {
      _showMessage('Ese código ya está en ${owner.name}.');
      return;
    }
    await _editBarcode(scanned: code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del alimento')),
      body: FutureBuilder<_FoodDetail>(
        future: _detail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('No se pudo cargar el alimento.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => setState(() => _detail = _load()),
                  child: const Text('Reintentar'),
                ),
              ]),
            );
          }
          final detail = snapshot.data!;
          final food = detail.food;
          final category = _categoryName(detail.categories, food.categoryId);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Card(
                child: Column(children: [
                  ListTile(leading: const CircleAvatar(child: Icon(Icons.restaurant)), title: Text(food.name)),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.category),
                    title: const Text('Categoría'),
                    trailing: Text(category ?? 'Sin categoría'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.qr_code),
                    title: const Text('Código de barras'),
                    subtitle: Text(food.barcode ?? 'Sin código asignado'),
                    trailing: IconButton(
                      onPressed: _editBarcode,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar código',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.repeat),
                    title: const Text('Veces registrado'),
                    trailing: Text('${food.usageCount}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.schedule),
                    title: const Text('Último uso'),
                    trailing: Text(
                      food.lastUsedAt == null
                          ? 'Nunca'
                          : '${food.lastUsedAt!.day.toString().padLeft(2, '0')}/${food.lastUsedAt!.month.toString().padLeft(2, '0')}/${food.lastUsedAt!.year}',
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear código'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FoodDetail {
  const _FoodDetail({required this.food, required this.categories});

  final FoodSummary food;
  final List<CategorySummary> categories;
}
