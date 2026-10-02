import 'package:flutter/material.dart';

import '../domain/context_repository.dart';
import '../domain/medication_repository.dart';
import '../domain/activity_repository.dart';
import '../domain/water_repository.dart';
import '../domain/mood_repository.dart';

class ContextEntryPage extends StatefulWidget {
  const ContextEntryPage({required this.repository, required this.medicationRepository, required this.activityRepository, required this.waterRepository, required this.moodRepository, required this.date, this.initial, super.key});
  final ContextRepository repository;
  final MedicationRepository medicationRepository;
  final ActivityRepository activityRepository;
  final WaterRepository waterRepository;
  final MoodRepository moodRepository;
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
  late Future<List<DailyMedicationSummary>> _medications;
  late Future<List<DailyActivitySummary>> _activities;
  late Future<List<WaterEntrySummary>> _waterEntries;
  late Future<MoodSummary?> _mood;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _sleepController = TextEditingController(text: initial?.sleepMinutes?.toString() ?? '');
    _sleepQuality = initial?.sleepQuality;
    _stress = initial?.stress;
    _notesController.text = initial?.notes ?? '';
    _medications = widget.medicationRepository.forDay(widget.date);
    _activities = widget.activityRepository.forDay(widget.date);
    _waterEntries = widget.waterRepository.forDay(widget.date);
    _mood = widget.moodRepository.forDay(widget.date);
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

  Future<void> _addMedication() async {
    final name = TextEditingController();
    final dosage = TextEditingController();
    final unit = TextEditingController();
    var kind = 'medication';
    final saved = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar tratamiento'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(initialValue: kind, decoration: const InputDecoration(labelText: 'Tipo'), items: const [DropdownMenuItem(value: 'medication', child: Text('Medicamento')), DropdownMenuItem(value: 'supplement', child: Text('Suplemento'))], onChanged: (value) => setDialogState(() => kind = value ?? kind)),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: TextField(controller: dosage, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dosis'))), const SizedBox(width: 8), Expanded(child: TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unidad')))]),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () async { await widget.medicationRepository.add(widget.date, name.text, kind, double.tryParse(dosage.text), unit.text, null); if (context.mounted) Navigator.pop(context, true); }, child: const Text('Guardar'))],
        )));
    name.dispose();
    dosage.dispose();
    unit.dispose();
    if (saved == true && mounted) setState(() => _medications = widget.medicationRepository.forDay(widget.date));
  }

  Future<void> _deleteMedication(DailyMedicationSummary item) async {
    await widget.medicationRepository.delete(item.id);
    if (mounted) setState(() => _medications = widget.medicationRepository.forDay(widget.date));
  }

  Future<void> _addActivity() async {
    final duration = TextEditingController();
    final notes = TextEditingController();
    var type = 'Caminar';
    int? intensity;
    final saved = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar actividad física'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'Actividad'), items: const ['Caminar', 'Correr', 'Bicicleta', 'Gimnasio', 'Deporte', 'Estiramiento', 'Otra'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setDialogState(() => type = value ?? type)),
            const SizedBox(height: 8),
            TextField(controller: duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duración (minutos)')),
            const SizedBox(height: 8),
            SegmentedButton<int>(segments: const [ButtonSegment(value: 1, label: Text('Baja')), ButtonSegment(value: 2, label: Text('Media')), ButtonSegment(value: 3, label: Text('Alta'))], selected: intensity == null ? {} : {intensity!}, onSelectionChanged: (value) => setDialogState(() => intensity = value.first)),
            const SizedBox(height: 8),
            TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notas (opcional)')),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () async { try { await widget.activityRepository.add(widget.date, type, int.tryParse(duration.text) ?? 0, intensity, notes.text); if (context.mounted) Navigator.pop(context, true); } on FormatException catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message))); } }, child: const Text('Guardar'))],
        )));
    duration.dispose();
    notes.dispose();
    if (saved == true && mounted) setState(() => _activities = widget.activityRepository.forDay(widget.date));
  }

  Future<void> _deleteActivity(DailyActivitySummary item) async {
    await widget.activityRepository.delete(item.id);
    if (mounted) setState(() => _activities = widget.activityRepository.forDay(widget.date));
  }

  Future<void> _addWater() async {
    final amount = TextEditingController();
    final notes = TextEditingController();
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
          title: const Text('Agregar agua'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: amount, autofocus: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad en ml', hintText: 'Ej. 250')), const SizedBox(height: 8), TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notas (opcional)'))]),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () async { try { await widget.waterRepository.add(widget.date, int.tryParse(amount.text) ?? 0, notes.text); if (context.mounted) Navigator.pop(context, true); } on FormatException catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message))); } }, child: const Text('Guardar'))],
        ));
    amount.dispose();
    notes.dispose();
    if (saved == true && mounted) setState(() => _waterEntries = widget.waterRepository.forDay(widget.date));
  }

  Future<void> _deleteWater(WaterEntrySummary entry) async {
    await widget.waterRepository.delete(entry.id);
    if (mounted) setState(() => _waterEntries = widget.waterRepository.forDay(widget.date));
  }

  Future<void> _editMood() async {
    final current = await _mood;
    if (!mounted) return;
    var selected = current?.mood ?? 3;
    final notes = TextEditingController(text: current?.notes ?? '');
    final saved = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
          title: const Text('Estado de ánimo'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SegmentedButton<int>(segments: const [ButtonSegment(value: 1, label: Text('Muy bajo')), ButtonSegment(value: 2, label: Text('Bajo')), ButtonSegment(value: 3, label: Text('Neutral')), ButtonSegment(value: 4, label: Text('Bueno')), ButtonSegment(value: 5, label: Text('Muy bueno'))], selected: {selected}, onSelectionChanged: (value) => setDialogState(() => selected = value.first)),
            const SizedBox(height: 12),
            TextField(controller: notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notas (opcional)')),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () async { await widget.moodRepository.save(widget.date, selected, notes.text); if (context.mounted) Navigator.pop(context, true); }, child: const Text('Guardar'))],
        )));
    notes.dispose();
    if (saved == true && mounted) setState(() => _mood = widget.moodRepository.forDay(widget.date));
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Medicamentos y suplementos', style: Theme.of(context).textTheme.titleMedium), IconButton(onPressed: _addMedication, tooltip: 'Agregar', icon: const Icon(Icons.add))]),
          FutureBuilder<List<DailyMedicationSummary>>(
            future: _medications,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Column(
                children: snapshot.data!.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(item.kind == 'supplement' ? Icons.eco_outlined : Icons.medication_outlined),
                  title: Text(item.name),
                  subtitle: Text(item.dosage == null ? (item.kind == 'supplement' ? 'Suplemento' : 'Medicamento') : '${item.dosage} ${item.unit ?? ''}'),
                  trailing: IconButton(onPressed: () => _deleteMedication(item), tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline)),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Actividad física', style: Theme.of(context).textTheme.titleMedium), IconButton(onPressed: _addActivity, tooltip: 'Agregar', icon: const Icon(Icons.add))]),
          FutureBuilder<List<DailyActivitySummary>>(
            future: _activities,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Column(
                children: snapshot.data!.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.directions_walk),
                  title: Text(item.activityType),
                  subtitle: Text('${item.durationMinutes} min${item.intensity == null ? '' : ' · Intensidad ${item.intensity}'}'),
                  trailing: IconButton(onPressed: () => _deleteActivity(item), tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline)),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<WaterEntrySummary>>(
            future: _waterEntries,
            builder: (context, snapshot) {
              final entries = snapshot.data ?? const <WaterEntrySummary>[];
              final total = entries.fold<int>(0, (sum, entry) => sum + entry.amountMl);
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.water_drop_outlined),
                      title: const Text('Hidratación'),
                      subtitle: Text('$total ml registrados'),
                      trailing: IconButton(onPressed: _addWater, tooltip: 'Agregar agua', icon: const Icon(Icons.add)),
                    ),
                    ...entries.map((entry) {
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text('${entry.amountMl} ml'),
                        subtitle: entry.notes == null ? null : Text(entry.notes!),
                        trailing: IconButton(onPressed: () => _deleteWater(entry), tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline)),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          FutureBuilder<MoodSummary?>(future: _mood, builder: (context, snapshot) {
            final mood = snapshot.data;
            return Card(child: ListTile(leading: const Icon(Icons.mood_outlined), title: const Text('Estado de ánimo'), subtitle: Text(mood == null ? 'Sin registrar' : _moodLabel(mood.mood)), trailing: const Icon(Icons.chevron_right), onTap: _editMood));
          }),
          const SizedBox(height: 18),
          TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Notas (opcional)')),
          const SizedBox(height: 28),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Guardar contexto')),
        ]),
      );
}

String _moodLabel(int value) => switch (value) { 1 => 'Muy bajo', 2 => 'Bajo', 3 => 'Neutral', 4 => 'Bueno', 5 => 'Muy bueno', _ => 'Sin datos' };
