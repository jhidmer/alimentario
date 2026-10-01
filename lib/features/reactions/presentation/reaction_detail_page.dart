import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/reaction_repository.dart';

class ReactionDetailPage extends StatelessWidget {
  const ReactionDetailPage({required this.reaction, required this.onEdit, required this.onDelete, super.key});

  final ReactionSummary reaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de reacción'), actions: [IconButton(onPressed: onEdit, tooltip: 'Editar', icon: const Icon(Icons.edit_outlined)), IconButton(onPressed: onDelete, tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28), children: [
        Card(child: Column(children: [
          ListTile(leading: const Icon(Icons.play_arrow), title: const Text('Inicio'), trailing: Text(_dateTime(reaction.startedAt))),
          if (reaction.endedAt != null) ListTile(leading: const Icon(Icons.stop), title: const Text('Finalización'), trailing: Text(_dateTime(reaction.endedAt!))),
          ListTile(leading: const Icon(Icons.speed), title: const Text('Intensidad'), trailing: Text(_intensity(reaction.intensity))),
          ListTile(leading: const Icon(Icons.timer_outlined), title: const Text('Duración'), trailing: Text(reaction.durationMinutes == null ? 'Continúa' : '${reaction.durationMinutes} min')),
          if (reaction.bodyArea != null) ListTile(leading: const Icon(Icons.accessibility_new), title: const Text('Zona'), trailing: Text(reaction.bodyArea!)),
        ])),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Síntomas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: reaction.symptoms.map((symptom) => Chip(label: Text(symptom))).toList()),
        ]))),
        if (reaction.notes != null && reaction.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.notes), title: const Text('Observaciones'), subtitle: Text(reaction.notes!))),
        ],
        if (reaction.photoPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Fotografías', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reaction.photoPaths.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(reaction.photoPaths[index]), width: 150, height: 150, fit: BoxFit.cover, errorBuilder: (_, error, stack) => const SizedBox(width: 150, child: Icon(Icons.broken_image))),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

String _dateTime(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String _intensity(int value) => switch (value) { 1 => 'Leve', 2 => 'Moderada', 3 => 'Fuerte', _ => 'Sin datos' };
