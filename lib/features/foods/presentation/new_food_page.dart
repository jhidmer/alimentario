import 'package:flutter/material.dart';

import '../data/category_repository.dart';
import '../domain/food_repository.dart';

class NewFoodPage extends StatefulWidget {
  const NewFoodPage({required this.foodRepository, required this.categoryRepository, super.key});

  final FoodRepository foodRepository;
  final CategoryRepository categoryRepository;

  @override
  State<NewFoodPage> createState() => _NewFoodPageState();
}

class _NewFoodPageState extends State<NewFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Future<List<CategorySummary>> _categories;
  int? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _categories = widget.categoryRepository.findAll();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _saving = true);
    try {
      await widget.foodRepository.create(FoodDraft(name: _nameController.text, categoryId: _categoryId!));
      if (mounted) Navigator.of(context).pop(true);
    } on FormatException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('No se pudo guardar el alimento.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo alimento')),
      body: FutureBuilder<List<CategorySummary>>(
        future: _categories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final categories = snapshot.data!;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej. Chocolate'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Escribe un nombre.' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categories.map((category) => DropdownMenuItem(value: category.id, child: Text(category.name))).toList(),
                  onChanged: (value) => setState(() => _categoryId = value),
                  validator: (value) => value == null ? 'Selecciona una categoría.' : null,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
