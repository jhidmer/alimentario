import 'package:flutter/material.dart';

import '../../../core/database/database_provider.dart';
import '../data/pattern_repository_impl.dart';
import '../domain/pattern_repository.dart';

class PatternsPage extends StatefulWidget {
  const PatternsPage({super.key});

  @override
  State<PatternsPage> createState() => _PatternsPageState();
}

class _PatternsPageState extends State<PatternsPage> {
  late final PatternRepositoryImpl _repository;
  int _hours = 6;
  late Future<List<PatternResult>> _results;

  @override
  void initState() {
    super.initState();
    _repository = PatternRepositoryImpl(appDatabase);
    _load();
  }

  void _load() => _results = _repository.associations(PatternWindow(hours: _hours));

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [
      Text('Ventana de análisis', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 2, label: Text('2 h')),
          ButtonSegment(value: 4, label: Text('4 h')),
          ButtonSegment(value: 6, label: Text('6 h')),
          ButtonSegment(value: 12, label: Text('12 h')),
          ButtonSegment(value: 24, label: Text('24 h')),
        ],
        selected: {_hours},
        onSelectionChanged: (value) => setState(() {
          _hours = value.first;
          _load();
        }),
      ),
      const SizedBox(height: 16),
      FutureBuilder<List<PatternResult>>(
        future: _results,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Text('No se pudieron calcular los patrones.');
          final results = snapshot.data ?? [];
          if (results.isEmpty) return const Text('Registra comidas y reacciones para detectar asociaciones temporales.');
          return Column(children: results.map((result) => Card(child: ExpansionTile(
                  title: Text(result.foodName),
                  subtitle: Text('${result.withReaction} de ${result.total} consumos · ${result.percentage.toStringAsFixed(0)} %\n${result.confidenceLabel}'),
                  leading: Icon(result.hasMinimumSample ? Icons.insights : Icons.info_outline, color: result.hasMinimumSample ? Theme.of(context).colorScheme.primary : Colors.orange),
                children: [
                  ListTile(title: const Text('Con reacción posterior'), trailing: Text('${result.withReaction}')),
                  ListTile(title: const Text('Sin reacción posterior'), trailing: Text('${result.withoutReaction}')),
                  ...result.symptoms.entries.map((entry) => ListTile(dense: true, title: Text(entry.key), trailing: Text('${entry.value}'))),
                ],
                ))).toList());
        },
      ),
      const SizedBox(height: 20),
      const Text('Los resultados con menos de 5 consumos deben considerarse insuficientes. La asociación temporal representa coincidencias estadísticas y no demuestra causalidad ni constituye un diagnóstico médico.'),
    ]);
  }
}
