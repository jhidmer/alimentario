import 'package:flutter/material.dart';

import '../../../core/database/database_provider.dart';
import '../../../shared/widgets/section_card.dart';
import '../../foods/data/food_repository_impl.dart';
import '../../foods/data/category_repository.dart';
import '../../meals/data/meal_repository_impl.dart';
import '../../meals/domain/meal_repository.dart';
import '../../meals/presentation/meal_entry_page.dart';
import '../../meals/presentation/meal_detail_page.dart';
import '../../meals/data/meal_template_repository_impl.dart';
import '../../reactions/data/reaction_repository_impl.dart';
import '../../reactions/domain/reaction_repository.dart';
import '../../reactions/presentation/reaction_entry_page.dart';
import '../../reactions/presentation/reaction_detail_page.dart';
import '../../context/data/context_repository_impl.dart';
import '../../context/domain/context_repository.dart';
import '../../context/presentation/context_entry_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final MealRepositoryImpl _meals;
  late final FoodRepositoryImpl _foods;
  late final CategoryRepository _categories;
  late final ReactionRepositoryImpl _reactions;
  late final ContextRepositoryImpl _context;
  late final MealTemplateRepositoryImpl _templates;
  late Future<List<MealSummary>> _today;
  late Future<List<ReactionSummary>> _todayReactions;

  @override
  void initState() {
    super.initState();
    _meals = MealRepositoryImpl(appDatabase);
    _foods = FoodRepositoryImpl(appDatabase);
    _categories = CategoryRepositoryImpl(appDatabase);
    _reactions = ReactionRepositoryImpl(appDatabase);
    _context = ContextRepositoryImpl(appDatabase);
    _templates = MealTemplateRepositoryImpl(appDatabase);
    _load();
  }

  void _load() {
    _today = _meals.forDay(DateTime.now());
    _todayReactions = _reactions.forDay(DateTime.now());
  }

  Future<void> _openContext() async {
    final date = DateTime.now();
    final current = await _context.forDay(date);
    if (!mounted) return;
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ContextEntryPage(repository: _context, date: date, initial: current)));
    if (saved == true && mounted) setState(_load);
  }

  Future<void> _openReaction() async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ReactionEntryPage(repository: _reactions),
    ));
    if (saved == true && mounted) setState(_load);
  }

  Future<void> _finishReaction(ReactionSummary reaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar reacción'),
        content: const Text('Se registrará la hora actual como finalización.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Finalizar')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _reactions.finish(reaction.id, DateTime.now());
      if (mounted) setState(_load);
    } on FormatException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _openMeal(MealType type) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => MealEntryPage(type: type, foodRepository: _foods, categoryRepository: _categories, mealRepository: _meals, templateRepository: _templates),
    ));
    if (saved == true && mounted) setState(_load);
  }

  Future<void> _editMeal(MealSummary meal) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => MealEntryPage(type: meal.type, initialMeal: meal, foodRepository: _foods, categoryRepository: _categories, mealRepository: _meals, templateRepository: _templates),
    ));
    if (saved == true && mounted) setState(_load);
  }

  Future<void> _deleteMeal(MealSummary meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comida'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) {
      await _meals.delete(meal.id);
      if (mounted) setState(_load);
    }
  }

  Future<void> _openMealDetail(MealSummary meal) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailPage(meal: meal, onEdit: () => _editMeal(meal), onDelete: () => _deleteMeal(meal))));
    if (mounted) setState(_load);
  }

  Future<void> _editReaction(ReactionSummary reaction) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ReactionEntryPage(repository: _reactions, initialReaction: reaction)));
    if (saved == true && mounted) setState(_load);
  }

  Future<void> _deleteReaction(ReactionSummary reaction) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
          title: const Text('Eliminar reacción'),
          content: const Text('Esta acción no se puede deshacer.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))],
        ));
    if (confirmed == true) {
      await _reactions.delete(reaction.id);
      if (mounted) setState(_load);
    }
  }

  Future<void> _openReactionDetail(ReactionSummary reaction) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReactionDetailPage(reaction: reaction, onEdit: () => _editReaction(reaction), onDelete: () => _deleteReaction(reaction))));
    if (mounted) setState(_load);
  }

  Future<void> _chooseMealType() async {
    final type = await showModalBottomSheet<MealType>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: MealType.values.map((type) => ListTile(
              leading: Icon(_mealIcon(type)),
              title: Text(mealTypeLabel(type)),
              onTap: () => Navigator.pop(context, type),
            )).toList()),
      ),
    );
    if (type != null && mounted) _openMeal(type);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${now.day} de ${_months[now.month - 1]}';
    return Scaffold(
      appBar: AppBar(title: const Text('Diario Alimentario')),
      body: FutureBuilder<List<MealSummary>>(
        future: _today,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('No se pudo cargar el día.'));
          final meals = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text('Hoy, $date', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text('Registra lo que consumes y cómo te sientes.', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(child: FilledButton.icon(onPressed: _chooseMealType, icon: const Icon(Icons.restaurant), label: const Text('Comida'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: _openReaction, icon: const Icon(Icons.favorite_border), label: const Text('Reacción'))),
              ]),
              const SizedBox(height: 24),
              ...MealType.values.map((type) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _MealSection(type: type, meals: meals.where((meal) => meal.type == type).toList(), onAdd: () => _openMeal(type), onOpen: _openMealDetail, onEdit: _editMeal, onDelete: _deleteMeal),
                  )),
              FutureBuilder<DailyContextSummary?>(
                future: _context.forDay(DateTime.now()),
                builder: (context, snapshot) {
                  final value = snapshot.data;
                  return Card(child: ListTile(
                    leading: const Icon(Icons.self_improvement),
                    title: const Text('Sueño y estrés'),
                    subtitle: Text(value == null ? 'Agrega contexto para encontrar más patrones.' : 'Sueño: ${value.sleepMinutes ?? '-'} min · Estrés: ${_contextLevel(value.stress)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openContext,
                  ));
                },
              ),
              FutureBuilder<List<ReactionSummary>>(
                future: _todayReactions,
                builder: (context, reactionSnapshot) {
                  if (reactionSnapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                  final reactions = reactionSnapshot.data ?? [];
                  return SectionCard(
                    title: 'Reacciones del día',
                    icon: Icons.monitor_heart_outlined,
                    color: Colors.deepOrange,
                    child: Column(children: [
                      if (reactions.isEmpty)
                        const Align(alignment: Alignment.centerLeft, child: Text('Todavía no hay reacciones registradas.'))
                      else
                        ...reactions.map((reaction) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_timeLabel(reaction.startedAt)),
                              subtitle: Text('${reaction.symptoms.join(' · ')}\n${_intensityLabel(reaction.intensity)}${reaction.status == ReactionStatus.active ? ' · Continúa' : ''}'),
                              onTap: () => _openReactionDetail(reaction),
                              trailing: reaction.status == ReactionStatus.active
                                  ? TextButton(onPressed: () => _finishReaction(reaction), child: const Text('Finalizar'))
                                  : null,
                            )),
                      Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _openReaction, icon: const Icon(Icons.add), label: const Text('Registrar reacción'))),
                    ]),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({required this.type, required this.meals, required this.onAdd, required this.onOpen, required this.onEdit, required this.onDelete});

  final MealType type;
  final List<MealSummary> meals;
  final VoidCallback onAdd;
  final ValueChanged<MealSummary> onEdit;
  final ValueChanged<MealSummary> onDelete;
  final ValueChanged<MealSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: mealTypeLabel(type),
      icon: _mealIcon(type),
      child: Column(children: [
        if (meals.isEmpty)
          const Align(alignment: Alignment.centerLeft, child: Text('Aún no registrado'))
        else
          ...meals.map((meal) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_timeLabel(meal.mealDatetime)),
                subtitle: Text(meal.displayFoodNames.join(' · ')),
                onTap: () => onOpen(meal),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => value == 'edit' ? onEdit(meal) : onDelete(meal),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              )),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Registrar'))),
      ]),
    );
  }
}

IconData _mealIcon(MealType type) {
  switch (type) {
    case MealType.breakfast:
      return Icons.free_breakfast_outlined;
    case MealType.lunch:
      return Icons.lunch_dining_outlined;
    case MealType.dinner:
      return Icons.dinner_dining_outlined;
    case MealType.snack:
      return Icons.cookie_outlined;
  }
}

String _timeLabel(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String _intensityLabel(int value) => switch (value) {
      1 => 'Leve',
      2 => 'Moderada',
      3 => 'Fuerte',
      _ => 'Sin intensidad',
    };

String _contextLevel(int? value) => switch (value) { 1 => 'bajo', 2 => 'medio', 3 => 'alto', _ => '-' };

const _months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
