import 'package:flutter/material.dart';

import '../../foods/domain/food_repository.dart';
import '../../foods/data/category_repository.dart';
import '../data/meal_repository_impl.dart';
import '../data/meal_template_repository_impl.dart';
import '../domain/meal_repository.dart';

class MealEntryPage extends StatefulWidget {
  const MealEntryPage({required this.type, required this.foodRepository, required this.categoryRepository, required this.mealRepository, required this.templateRepository, this.initialMeal, super.key});

  final MealType type;
  final FoodRepository foodRepository;
  final CategoryRepository categoryRepository;
  final MealRepository mealRepository;
  final MealTemplateRepository templateRepository;
  final MealSummary? initialMeal;

  @override
  State<MealEntryPage> createState() => _MealEntryPageState();
}

class _MealEntryPageState extends State<MealEntryPage> {
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  late Future<List<FoodSummary>> _foods;
  final _selectedIds = <int>{};
  DateTime _mealDateTime = DateTime.now();
  bool _saving = false;
  late Future<List<MealTemplateSummary>> _templates;

  @override
  void initState() {
    super.initState();
    _foods = widget.foodRepository.frequent();
    _templates = widget.templateRepository.findActive();
    final meal = widget.initialMeal;
    if (meal != null) {
      _selectedIds.addAll(meal.foodIds);
      _mealDateTime = meal.mealDatetime;
      _notesController.text = meal.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() {
      _foods = value.trim().isEmpty ? widget.foodRepository.frequent() : widget.foodRepository.search(value);
    });
  }

  Future<void> _chooseTemplate() async {
    final templates = await _templates;
    if (!mounted) return;
    final template = await showModalBottomSheet<MealTemplateSummary>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(child: templates.isEmpty
          ? const Padding(padding: EdgeInsets.all(24), child: Text('Aún no hay comidas habituales.'))
          : Column(mainAxisSize: MainAxisSize.min, children: templates.map((item) => ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: Text(item.name),
                subtitle: Text(item.foodNames.join(' · ')),
                onTap: () => Navigator.pop(context, item),
              )).toList())),
    );
    if (template != null && mounted) setState(() => _selectedIds.addAll(template.foodIds));
  }

  Future<void> _saveAsTemplate() async {
    if (_selectedIds.isEmpty) return;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar comida habitual'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Guardar')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !mounted) return;
    await widget.templateRepository.create(name, widget.type, _selectedIds.toList());
    if (!mounted) return;
    setState(() => _templates = widget.templateRepository.findActive());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comida habitual guardada.')));
  }

  Future<void> _quickAddFood() async {
    final food = await showModalBottomSheet<FoodSummary>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _QuickAddFoodSheet(foodRepository: widget.foodRepository, categoryRepository: widget.categoryRepository),
    );
    if (food == null || !mounted) return;
    setState(() {
      _selectedIds.add(food.id);
      _foods = widget.foodRepository.search(_searchController.text);
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: _mealDateTime,
    );
    if (date == null || !mounted) return;
    setState(() => _mealDateTime = DateTime(date.year, date.month, date.day, _mealDateTime.hour, _mealDateTime.minute));
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_mealDateTime));
    if (time == null || !mounted) return;
    setState(() => _mealDateTime = DateTime(_mealDateTime.year, _mealDateTime.month, _mealDateTime.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (_selectedIds.isEmpty) {
      _showMessage('Selecciona al menos un alimento.');
      return;
    }
    setState(() => _saving = true);
    try {
      final draft = MealDraft(
        mealDatetime: _mealDateTime,
        type: widget.type,
        foodIds: _selectedIds.toList(),
        notes: _notesController.text,
      );
      if (widget.initialMeal == null) {
        await widget.mealRepository.create(draft);
      } else {
        await widget.mealRepository.update(widget.initialMeal!.id, draft);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) _showMessage('No se pudo guardar la comida.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.initialMeal == null ? 'Registrar' : 'Editar'} ${mealTypeLabel(widget.type).toLowerCase()}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today), label: Text(_dateLabel(_mealDateTime)))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: _pickTime, icon: const Icon(Icons.schedule), label: Text(_timeLabel(_mealDateTime)))),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar alimento...'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _chooseTemplate, icon: const Icon(Icons.bookmark_outline), label: const Text('Usar comida habitual')),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(onPressed: _quickAddFood, icon: const Icon(Icons.add), label: const Text('Agregar alimento nuevo')),
          ),
          const SizedBox(height: 20),
          Text('Selecciona los alimentos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<FoodSummary>>(
            future: _foods,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
              if (snapshot.hasError) return const Text('No se pudieron cargar los alimentos.');
              final foods = snapshot.data ?? [];
              if (foods.isEmpty) return const Text('Crea un alimento desde Configuración para comenzar.');
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: foods.map((food) => FilterChip(
                      label: Text(food.name),
                      selected: _selectedIds.contains(food.id),
                      onSelected: (selected) => setState(() => selected ? _selectedIds.add(food.id) : _selectedIds.remove(food.id)),
                    )).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Observaciones (opcional)'),
          ),
          const SizedBox(height: 12),
          if (_selectedIds.isNotEmpty) Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: _saveAsTemplate, icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Guardar como habitual'))),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            label: Text(widget.initialMeal == null ? 'Guardar comida' : 'Guardar cambios'),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _timeLabel(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _QuickAddFoodSheet extends StatefulWidget {
  const _QuickAddFoodSheet({required this.foodRepository, required this.categoryRepository});

  final FoodRepository foodRepository;
  final CategoryRepository categoryRepository;

  @override
  State<_QuickAddFoodSheet> createState() => _QuickAddFoodSheetState();
}

class _QuickAddFoodSheetState extends State<_QuickAddFoodSheet> {
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
    if (_nameController.text.trim().isEmpty || _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indica nombre y categoría.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final food = await widget.foodRepository.create(FoodDraft(name: _nameController.text, categoryId: _categoryId!));
      if (mounted) Navigator.pop(context, food);
    } on FormatException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo crear el alimento.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: FutureBuilder<List<CategorySummary>>(
          future: _categories,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Nuevo alimento', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: _nameController, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej. Avena')),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: snapshot.data!.map((category) => DropdownMenuItem(value: category.id, child: Text(category.name))).toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.add), label: const Text('Crear y seleccionar'))),
            ]);
          },
        ),
      ),
    );
  }
}

String mealTypeLabel(MealType type) {
  switch (type) {
    case MealType.breakfast:
      return 'Desayuno';
    case MealType.lunch:
      return 'Almuerzo';
    case MealType.dinner:
      return 'Cena';
    case MealType.snack:
      return 'Entre comidas';
  }
}
