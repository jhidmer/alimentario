import 'package:flutter/material.dart';

import '../data/meal_repository_impl.dart';
import '../domain/meal_repository.dart';

class MealDetailPage extends StatelessWidget {
  const MealDetailPage({required this.meal, required this.onEdit, required this.onDelete, super.key});

  final MealSummary meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_mealTypeLabel(meal.type)), actions: [IconButton(onPressed: onEdit, tooltip: 'Editar', icon: const Icon(Icons.edit_outlined)), IconButton(onPressed: onDelete, tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28), children: [
        _InfoCard(icon: Icons.schedule, title: 'Fecha y hora', value: '${_date(meal.mealDatetime)} · ${_time(meal.mealDatetime)}'),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alimentos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...meal.displayFoodNames.map((food) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.restaurant), title: Text(food))),
        ]))),
        if (meal.notes != null && meal.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(icon: Icons.notes, title: 'Observaciones', value: meal.notes!),
        ],
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(title), subtitle: Text(value)));
}

String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String _time(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String _mealTypeLabel(MealType type) => switch (type) { MealType.breakfast => 'Desayuno', MealType.lunch => 'Almuerzo', MealType.dinner => 'Cena', MealType.snack => 'Entre comidas' };
