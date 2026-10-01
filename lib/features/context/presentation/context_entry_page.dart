import 'package:flutter/material.dart';

import '../domain/context_repository.dart';

class ContextEntryPage extends StatefulWidget {
  const ContextEntryPage({required this.repository, required this.date, this.initial, super.key});
  final ContextRepository repository;
  final DateTime date;
  final DailyContextSummary? initial;

  @override
  State<ContextEntryPage> createState() => _ContextEntryPageState();
}

class _ContextEntryPageState extends State<ContextEntryPage> {
  late final TextEditingController _sleepController;
  final _notesController = TextEditingController();
  int? _sleepQuality;
  int? _stress;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _sleepController = TextEditingController(text: initial?.sleepMinutes?.toString() ?? '');
    _sleepQuality = initial?.sleepQuality;
    _stress = initial?.stress;
    _notesController.text = initial?.notes ?? '';
  }

  @override
  void dispose() {
    _sleepController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.repository.save(DailyContextDraft(date: widget.date, sleepMinutes: int.tryParse(_sleepController.text), sleepQuality: _sleepQuality, stress: _stress, notes: _notesController.text));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Contexto del día')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Sueño', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: _sleepController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutos dormidos', hintText: 'Ej. 420')),
          const SizedBox(height: 18),
          Text('Calidad del sueño', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<int>(segments: const [ButtonSegment(value: 1, label: Text('Baja')), ButtonSegment(value: 2, label: Text('Media')), ButtonSegment(value: 3, label: Text('Buena'))], selected: _sleepQuality == null ? {} : {_sleepQuality!}, onSelectionChanged: (value) => setState(() => _sleepQuality = value.first)),
          const SizedBox(height: 18),
          Text('Estrés', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<int>(segments: const [ButtonSegment(value: 1, label: Text('Bajo')), ButtonSegment(value: 2, label: Text('Medio')), ButtonSegment(value: 3, label: Text('Alto'))], selected: _stress == null ? {} : {_stress!}, onSelectionChanged: (value) => setState(() => _stress = value.first)),
          const SizedBox(height: 18),
          TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Notas (opcional)')),
          const SizedBox(height: 28),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Guardar contexto')),
        ]),
      );
}
