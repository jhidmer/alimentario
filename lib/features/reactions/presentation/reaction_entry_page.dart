import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/reaction_repository.dart';

class ReactionEntryPage extends StatefulWidget {
  const ReactionEntryPage({required this.repository, this.initialReaction, super.key});

  final ReactionRepository repository;
  final ReactionSummary? initialReaction;

  @override
  State<ReactionEntryPage> createState() => _ReactionEntryPageState();
}

class _ReactionEntryPageState extends State<ReactionEntryPage> {
  final _notesController = TextEditingController();
  late Future<List<SymptomSummary>> _symptoms;
  final _selectedSymptoms = <int>{};
  DateTime _startedAt = DateTime.now();
  int _intensity = 2;
  String? _bodyArea;
  bool _saving = false;
  String? _photoPath;
  late final List<String> _existingPhotos;

  @override
  void initState() {
    super.initState();
    _symptoms = widget.repository.symptoms();
    final reaction = widget.initialReaction;
    _existingPhotos = [...?reaction?.photoPaths];
    if (reaction != null) {
      _selectedSymptoms.addAll(reaction.symptomIds);
      _startedAt = reaction.startedAt;
      _intensity = reaction.intensity;
      _bodyArea = reaction.bodyArea;
      _notesController.text = reaction.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _startedAt,
    );
    if (value == null || !mounted) return;
    setState(() => _startedAt = DateTime(value.year, value.month, value.day, _startedAt.hour, _startedAt.minute));
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startedAt));
    if (value == null || !mounted) return;
    setState(() => _startedAt = DateTime(_startedAt.year, _startedAt.month, _startedAt.day, value.hour, value.minute));
  }

  Future<void> _save() async {
    if (_selectedSymptoms.isEmpty) {
      _showMessage('Selecciona al menos un síntoma.');
      return;
    }
    setState(() => _saving = true);
    try {
      final draft = ReactionDraft(
        startedAt: _startedAt,
        intensity: _intensity,
        symptomIds: _selectedSymptoms.toList(),
        bodyArea: _bodyArea,
        notes: _notesController.text,
        endedAt: widget.initialReaction?.endedAt,
        status: widget.initialReaction?.status ?? ReactionStatus.active,
      );
      final reactionId = widget.initialReaction == null
          ? await widget.repository.create(draft)
          : await _updateReaction(draft);
      if (_photoPath != null && widget.initialReaction == null) await widget.repository.addPhoto(reactionId, _photoPath!);
      if (mounted) Navigator.of(context).pop(true);
    } on FormatException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('No se pudo guardar la reacción.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<int> _updateReaction(ReactionDraft draft) async {
    await widget.repository.update(widget.initialReaction!.id, draft);
    return widget.initialReaction!.id;
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galería'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Cámara'), onTap: () => Navigator.pop(context, ImageSource.camera)),
          ])),
    );
    if (source == null || !mounted) return;
    final image = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    setState(() => _photoPath = image.path);
  }

  Future<void> _deletePhoto(String filePath) async {
    if (widget.initialReaction == null) return;
    await widget.repository.deletePhoto(widget.initialReaction!.id, filePath);
    if (mounted) setState(() => _existingPhotos.remove(filePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialReaction == null ? 'Registrar reacción' : 'Editar reacción')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today), label: Text(_dateLabel(_startedAt)))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: _pickTime, icon: const Icon(Icons.schedule), label: Text(_timeLabel(_startedAt)))),
          ]),
          const SizedBox(height: 24),
          Text('¿Qué síntomas tienes?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<SymptomSummary>>(
            future: _symptoms,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
              if (snapshot.hasError) return const Text('No se pudieron cargar los síntomas.');
              return Column(children: (snapshot.data ?? []).map((symptom) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(symptom.name),
                    value: _selectedSymptoms.contains(symptom.id),
                    onChanged: (selected) => setState(() => selected == true ? _selectedSymptoms.add(symptom.id) : _selectedSymptoms.remove(symptom.id)),
                  )).toList());
            },
          ),
          const SizedBox(height: 16),
          Text('Intensidad', style: Theme.of(context).textTheme.titleMedium),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('Leve')),
              ButtonSegment(value: 2, label: Text('Moderada')),
              ButtonSegment(value: 3, label: Text('Fuerte')),
            ],
            selected: {_intensity},
            onSelectionChanged: (value) => setState(() => _intensity = value.first),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _bodyArea,
            decoration: const InputDecoration(labelText: 'Zona del cuerpo (opcional)'),
            items: const ['Cabeza', 'Cara', 'Pecho', 'Abdomen', 'Brazo', 'Pierna', 'Espalda', 'General']
                .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                .toList(),
            onChanged: (value) => setState(() => _bodyArea = value),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.photo_camera_back_outlined),
            label: Text(_photoPath == null ? 'Agregar fotografía' : 'Fotografía seleccionada'),
          ),
          if (_existingPhotos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Fotografías guardadas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _existingPhotos.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filePath = _existingPhotos[index];
                  return Stack(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(filePath), width: 110, height: 110, fit: BoxFit.cover, errorBuilder: (_, error, stack) => const SizedBox(width: 110, height: 110, child: Icon(Icons.broken_image)))),
                    Positioned(top: 2, right: 2, child: IconButton(onPressed: () => _deletePhoto(filePath), icon: const Icon(Icons.delete, color: Colors.white), style: IconButton.styleFrom(backgroundColor: Colors.black54))),
                  ]);
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Observaciones (opcional)')),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            label: Text(widget.initialReaction == null ? 'Guardar reacción' : 'Guardar cambios'),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _timeLabel(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
