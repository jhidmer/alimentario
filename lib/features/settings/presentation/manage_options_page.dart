import 'package:flutter/material.dart';

import '../../../core/database/database_provider.dart';
import '../../foods/data/category_repository.dart';
import '../../reactions/data/symptom_repository.dart';
import '../../reactions/domain/reaction_repository.dart';

class ManageOptionsPage extends StatefulWidget {
  const ManageOptionsPage({super.key});

  @override
  State<ManageOptionsPage> createState() => _ManageOptionsPageState();
}

class _ManageOptionsPageState extends State<ManageOptionsPage> {
  late final CategoryRepository _categories;
  late final SymptomRepository _symptoms;
  late Future<List<CategorySummary>> _categoryItems;
  late Future<List<SymptomSummary>> _symptomItems;

  @override
  void initState() {
    super.initState();
    _categories = CategoryRepositoryImpl(appDatabase);
    _symptoms = SymptomRepository(appDatabase);
    _reload();
  }

  void _reload() {
    _categoryItems = _categories.findAll();
    _symptomItems = _symptoms.findActive();
  }

  Future<void> _addCategory() async {
    final value = await _nameDialog('Nueva categoría');
    if (value == null) return;
    try {
      await _categories.create(value);
      if (mounted) setState(_reload);
    } catch (_) {
      if (mounted) _message('No se pudo crear la categoría.');
    }
  }

  Future<void> _addSymptom() async {
    final value = await _nameDialog('Nuevo síntoma');
    if (value == null) return;
    try {
      await _symptoms.create(value);
      if (mounted) setState(_reload);
    } catch (_) {
      if (mounted) _message('No se pudo crear el síntoma.');
    }
  }

  Future<void> _deactivateCategory(CategorySummary category) async {
    if (category.name == 'Otros') {
      _message('La categoría Otros no se puede desactivar.');
      return;
    }
    await _categories.deactivate(category.id);
    if (mounted) setState(_reload);
  }

  Future<String?> _nameDialog(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Guardar')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Gestionar opciones'), bottom: const TabBar(tabs: [Tab(text: 'Categorías'), Tab(text: 'Síntomas')])),
        body: TabBarView(children: [
          _OptionList<CategorySummary>(future: _categoryItems, name: (item) => item.name, onAdd: _addCategory, onDeactivate: (item) => _deactivateCategory(item)),
          _OptionList<SymptomSummary>(future: _symptomItems, name: (item) => item.name, onAdd: _addSymptom),
        ]),
      ),
    );
  }
}

class _OptionList<T> extends StatelessWidget {
  const _OptionList({required this.future, required this.name, required this.onAdd, this.onDeactivate});
  final Future<List<T>> future;
  final String Function(T item) name;
  final VoidCallback onAdd;
  final Future<void> Function(T item)? onDeactivate;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.all(20), children: [
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Nuevo')),
          const SizedBox(height: 16),
          ...snapshot.data!.map((item) => Card(child: ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(name(item)),
                trailing: onDeactivate == null ? null : IconButton(onPressed: () => onDeactivate!(item), tooltip: 'Desactivar', icon: const Icon(Icons.visibility_off_outlined)),
              ))),
        ]);
      },
    );
  }
}
