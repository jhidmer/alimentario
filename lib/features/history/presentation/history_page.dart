import 'package:flutter/material.dart';

import '../../../core/database/database_provider.dart';
import '../../foods/data/food_repository_impl.dart';
import '../../foods/data/category_repository.dart';
import '../../meals/data/meal_repository_impl.dart';
import '../../meals/domain/meal_repository.dart';
import '../../meals/presentation/meal_entry_page.dart';
import '../../reactions/data/reaction_repository_impl.dart';
import '../../reactions/domain/reaction_repository.dart';
import '../../reactions/presentation/reaction_entry_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final MealRepositoryImpl _meals;
  late final FoodRepositoryImpl _foods;
  late final CategoryRepository _categories;
  late final ReactionRepositoryImpl _reactions;
  late DateTime _month;
  late DateTime _selectedDay;
  late Future<_MonthData> _monthData;
  late Future<_DayData> _dayData;

  @override
  void initState() {
    super.initState();
    _meals = MealRepositoryImpl(appDatabase);
    _foods = FoodRepositoryImpl(appDatabase);
    _categories = CategoryRepositoryImpl(appDatabase);
    _reactions = ReactionRepositoryImpl(appDatabase);
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _load();
  }

  void _load() {
    _monthData = _loadMonth(_month);
    _dayData = _loadDay(_selectedDay);
  }

  Future<_MonthData> _loadMonth(DateTime month) async {
    final results = await Future.wait([_meals.daysWithMeals(month), _reactions.daysWithReactions(month)]);
    return _MonthData(mealDays: results[0], reactionDays: results[1]);
  }

  Future<_DayData> _loadDay(DateTime day) async {
    final results = await Future.wait([_meals.forDay(day), _reactions.forDay(day)]);
    return _DayData(meals: results[0] as List<MealSummary>, reactions: results[1] as List<ReactionSummary>);
  }

  void _changeMonth(int offset) {
    setState(() {
      _month = DateTime(_month.year, _month.month + offset);
      final day = _selectedDay.day.clamp(1, _daysInMonth(_month)).toInt();
      _selectedDay = DateTime(_month.year, _month.month, day);
      _monthData = _loadMonth(_month);
      _dayData = _loadDay(_selectedDay);
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = DateTime(_month.year, _month.month, day);
      _dayData = _loadDay(_selectedDay);
    });
  }

  Future<void> _deleteMeal(MealSummary meal) async {
    if (!await _confirmDelete('comida')) return;
    await _meals.delete(meal.id);
    if (mounted) {
      setState(() {
        _monthData = _loadMonth(_month);
        _dayData = _loadDay(_selectedDay);
      });
    }
  }

  Future<void> _deleteReaction(ReactionSummary reaction) async {
    if (!await _confirmDelete('reacción')) return;
    await _reactions.delete(reaction.id);
    if (mounted) {
      setState(() {
        _monthData = _loadMonth(_month);
        _dayData = _loadDay(_selectedDay);
      });
    }
  }

  Future<void> _editMeal(MealSummary meal) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => MealEntryPage(type: meal.type, initialMeal: meal, foodRepository: _foods, categoryRepository: _categories, mealRepository: _meals),
    ));
    if (saved == true && mounted) {
      setState(() {
        _monthData = _loadMonth(_month);
        _dayData = _loadDay(_selectedDay);
      });
    }
  }

  Future<void> _editReaction(ReactionSummary reaction) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ReactionEntryPage(repository: _reactions, initialReaction: reaction),
    ));
    if (saved == true && mounted) {
      setState(() {
        _monthData = _loadMonth(_month);
        _dayData = _loadDay(_selectedDay);
      });
    }
  }

  Future<bool> _confirmDelete(String label) async => await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Eliminar $label'),
          content: Text('Esta acción no se puede deshacer.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
          ],
        ),
      ) ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _MonthHeader(month: _month, onPrevious: () => _changeMonth(-1), onNext: () => _changeMonth(1)),
          const SizedBox(height: 12),
          FutureBuilder<_MonthData>(
            future: _monthData,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(height: 210, child: Center(child: CircularProgressIndicator()));
              return _Calendar(month: _month, selectedDay: _selectedDay, data: snapshot.data!, onSelect: _selectDay);
            },
          ),
          const SizedBox(height: 20),
          Text(_dayTitle(_selectedDay), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          FutureBuilder<_DayData>(
            future: _dayData,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return _Timeline(data: snapshot.data!, onDeleteMeal: _deleteMeal, onEditMeal: _editMeal, onEditReaction: _editReaction, onDeleteReaction: _deleteReaction);
            },
          ),
        ],
      ),
    );
  }
}

class _MonthData {
  const _MonthData({required this.mealDays, required this.reactionDays});
  final Set<DateTime> mealDays;
  final Set<DateTime> reactionDays;
}

class _DayData {
  const _DayData({required this.meals, required this.reactions});
  final List<MealSummary> meals;
  final List<ReactionSummary> reactions;
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.onPrevious, required this.onNext});
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(onPressed: onPrevious, tooltip: 'Mes anterior', icon: const Icon(Icons.chevron_left)),
      Expanded(child: Center(child: Text('${_monthNames[month.month - 1]} ${month.year}', style: Theme.of(context).textTheme.titleLarge))),
      IconButton(onPressed: onNext, tooltip: 'Mes siguiente', icon: const Icon(Icons.chevron_right)),
    ]);
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.month, required this.selectedDay, required this.data, required this.onSelect});
  final DateTime month;
  final DateTime selectedDay;
  final _MonthData data;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final offset = firstDay.weekday - 1;
    final totalDays = _daysInMonth(month);
    return Column(children: [
      Row(children: _weekdays.map((day) => Expanded(child: Center(child: Text(day, style: Theme.of(context).textTheme.labelSmall)))).toList()),
      const SizedBox(height: 8),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: offset + totalDays,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 44),
        itemBuilder: (context, index) {
          if (index < offset) return const SizedBox.shrink();
          final day = index - offset + 1;
          final date = DateTime(month.year, month.month, day);
          final selected = _sameDay(date, selectedDay);
          final hasMeal = data.mealDays.contains(date);
          final hasReaction = data.reactionDays.contains(date);
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(day),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primaryContainer : null, borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$day', style: TextStyle(fontWeight: selected ? FontWeight.bold : null)),
                const SizedBox(height: 3),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (hasMeal) const _Dot(color: Colors.green),
                  if (hasReaction) const _Dot(color: Colors.deepOrange),
                ]),
              ]),
            ),
          );
        },
      ),
      const SizedBox(height: 8),
      const Row(children: [
        _Dot(color: Colors.green), SizedBox(width: 4), Text('comida'), SizedBox(width: 16),
        _Dot(color: Colors.deepOrange), SizedBox(width: 4), Text('reacción'),
      ]),
    ]);
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.data, required this.onDeleteMeal, required this.onEditMeal, required this.onEditReaction, required this.onDeleteReaction});
  final _DayData data;
  final ValueChanged<MealSummary> onDeleteMeal;
  final ValueChanged<MealSummary> onEditMeal;
  final ValueChanged<ReactionSummary> onEditReaction;
  final ValueChanged<ReactionSummary> onDeleteReaction;

  @override
  Widget build(BuildContext context) {
    final entries = <_TimelineEntry>[
      ...data.meals.map((meal) => _TimelineEntry(time: meal.mealDatetime, icon: Icons.restaurant, title: _mealTypeLabel(meal.type), detail: meal.foodNames.join(' · '), onEdit: () => onEditMeal(meal), onDelete: () => onDeleteMeal(meal))),
      ...data.reactions.map((reaction) => _TimelineEntry(time: reaction.startedAt, icon: Icons.monitor_heart, title: 'Reacción', detail: '${reaction.symptoms.join(' · ')} · ${_intensityLabel(reaction.intensity)}', onEdit: () => onEditReaction(reaction), onDelete: () => onDeleteReaction(reaction))),
    ]..sort((a, b) => a.time.compareTo(b.time));
    if (entries.isEmpty) return const Text('No hay registros para este día.');
    return Column(children: entries.map((entry) => Card(child: ListTile(
          leading: Icon(entry.icon), title: Text(entry.title), subtitle: Text(entry.detail), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(_timeLabel(entry.time)), PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') entry.onEdit?.call(); if (value == 'delete') entry.onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))])]),
        ))).toList());
  }
}

class _TimelineEntry {
  const _TimelineEntry({required this.time, required this.icon, required this.title, required this.detail, this.onEdit, required this.onDelete});
  final DateTime time;
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
}

String _dayTitle(DateTime date) => '${date.day} de ${_monthNames[date.month - 1]} de ${date.year}';
String _mealTypeLabel(MealType type) => switch (type) { MealType.breakfast => 'Desayuno', MealType.lunch => 'Almuerzo', MealType.dinner => 'Cena', MealType.snack => 'Entre comidas' };
String _timeLabel(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String _intensityLabel(int value) => switch (value) { 1 => 'Leve', 2 => 'Moderada', 3 => 'Fuerte', _ => 'Sin intensidad' };
bool _sameDay(DateTime first, DateTime second) => first.year == second.year && first.month == second.month && first.day == second.day;
int _daysInMonth(DateTime month) => DateTime(month.year, month.month + 1, 0).day;

const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _monthNames = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
