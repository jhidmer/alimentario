import 'package:flutter/material.dart';

import '../../../core/database/database_provider.dart';
import '../data/statistics_repository_impl.dart';
import '../domain/statistics_repository.dart';
import '../../patterns/presentation/patterns_page.dart';

enum _StatisticsRange { seven, thirty, ninety, all, custom }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late final StatisticsRepositoryImpl _repository;
  late Future<StatisticsSnapshot> _snapshot;
  _StatisticsRange _range = _StatisticsRange.thirty;
  DateTime? _customFrom;
  DateTime? _customTo;

  @override
  void initState() {
    super.initState();
    _repository = StatisticsRepositoryImpl(appDatabase);
    _load();
  }

  void _load() {
    _snapshot = _repository.snapshot(_period);
  }

  StatisticsPeriod get _period {
    final now = DateTime.now();
    final from = switch (_range) {
      _StatisticsRange.seven => now.subtract(const Duration(days: 7)),
      _StatisticsRange.thirty => now.subtract(const Duration(days: 30)),
      _StatisticsRange.ninety => now.subtract(const Duration(days: 90)),
      _StatisticsRange.all => DateTime(1970),
      _StatisticsRange.custom => _customFrom ?? now.subtract(const Duration(days: 30)),
    };
    return StatisticsPeriod(from: from, to: _range == _StatisticsRange.custom && _customTo != null ? _customTo!.add(const Duration(days: 1)) : now.add(const Duration(seconds: 1)));
  }

  void _changeRange(_StatisticsRange? value) {
    if (value == null) return;
    if (value == _StatisticsRange.custom) {
      _pickCustomPeriod();
      return;
    }
    setState(() {
      _range = value;
      _load();
    });
  }

  Future<void> _pickCustomPeriod() async {
    final from = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now(), initialDate: _customFrom ?? DateTime.now().subtract(const Duration(days: 30)));
    if (from == null || !mounted) return;
    final to = await showDatePicker(context: context, firstDate: from, lastDate: DateTime.now(), initialDate: _customTo ?? DateTime.now());
    if (to == null || !mounted) return;
    setState(() {
      _customFrom = from;
      _customTo = to;
      _range = _StatisticsRange.custom;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          bottom: const TabBar(tabs: [Tab(text: 'Resumen'), Tab(text: 'Alimentos'), Tab(text: 'Reacciones'), Tab(text: 'Patrones')]),
        ),
        body: FutureBuilder<StatisticsSnapshot>(
          future: _snapshot,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return const Center(child: Text('No se pudieron calcular las estadísticas.'));
            final data = snapshot.data!;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: DropdownButtonFormField<_StatisticsRange>(
                  initialValue: _range,
                  decoration: const InputDecoration(labelText: 'Periodo'),
                  items: const [
                    DropdownMenuItem(value: _StatisticsRange.seven, child: Text('Últimos 7 días')),
                    DropdownMenuItem(value: _StatisticsRange.thirty, child: Text('Últimos 30 días')),
                    DropdownMenuItem(value: _StatisticsRange.ninety, child: Text('Últimos 90 días')),
                    DropdownMenuItem(value: _StatisticsRange.all, child: Text('Todo')),
                    DropdownMenuItem(value: _StatisticsRange.custom, child: Text('Personalizado')),
                  ],
                  onChanged: _changeRange,
                ),
              ),
              Expanded(child: TabBarView(children: [
                _SummaryTab(data: data),
                _FoodsTab(data: data),
                _ReactionsTab(data: data),
                const PatternsPage(),
              ])),
            ]);
          },
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.data});
  final StatisticsSnapshot data;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [
      _StatTile(label: 'Días registrados', value: '${data.registeredDays}', icon: Icons.event_available),
      _StatTile(label: 'Comidas registradas', value: '${data.meals}', icon: Icons.restaurant),
      _StatTile(label: 'Alimentos diferentes', value: '${data.differentFoods}', icon: Icons.local_dining),
      _StatTile(label: 'Reacciones', value: '${data.reactions}', icon: Icons.monitor_heart),
      _StatTile(label: 'Días con reacción', value: '${data.reactionDays}', icon: Icons.warning_amber),
    ]);
  }
}

class _FoodsTab extends StatelessWidget {
  const _FoodsTab({required this.data});
  final StatisticsSnapshot data;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [
      Text('Más consumidos', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (data.foods.isEmpty) const Text('No hay comidas en el periodo seleccionado.') else ...data.foods.take(10).map((item) => _RankTile(name: item.name, value: item.count)),
      const SizedBox(height: 24),
      Text('Por categoría', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (data.categories.isEmpty) const Text('No hay categorías para mostrar.') else ...data.categories.map((item) => _RankTile(name: item.name, value: '${item.percentage.toStringAsFixed(0)} %')),
    ]);
  }
}

class _ReactionsTab extends StatelessWidget {
  const _ReactionsTab({required this.data});
  final StatisticsSnapshot data;

  @override
  Widget build(BuildContext context) {
    final hour = data.commonHour == null ? 'Sin datos' : '${data.commonHour!.toString().padLeft(2, '0')}:00';
    final duration = data.averageDuration == 0 ? 'Sin datos' : '${data.averageDuration.toStringAsFixed(0)} min';
    final intensity = data.averageIntensity == 0 ? 'Sin datos' : data.averageIntensity.toStringAsFixed(1);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [
      _StatTile(label: 'Total', value: '${data.reactions}', icon: Icons.monitor_heart),
      _StatTile(label: 'Síntoma más frecuente', value: data.symptoms.isEmpty ? 'Sin datos' : data.symptoms.first.name, icon: Icons.healing),
      _StatTile(label: 'Hora habitual', value: hour, icon: Icons.schedule),
      _StatTile(label: 'Duración promedio', value: duration, icon: Icons.timer_outlined),
      _StatTile(label: 'Intensidad promedio', value: intensity, icon: Icons.speed),
      _StatTile(label: 'Zona más registrada', value: data.commonBodyArea ?? 'Sin datos', icon: Icons.accessibility_new),
      const SizedBox(height: 20),
      Text('Síntomas', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ...data.symptoms.take(10).map((item) => _RankTile(name: item.name, value: item.count)),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: Flexible(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleMedium)),
    ));
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.name, required this.value});
  final String name;
  final Object value;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(name), trailing: Text('$value', style: Theme.of(context).textTheme.titleMedium)));
  }
}
