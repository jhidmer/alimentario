import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../domain/reaction_repository.dart';

class ReactionRepositoryImpl implements ReactionRepository {
  ReactionRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<SymptomSummary>> symptoms() async {
    final items = await _database.symptomDao.findActive();
    return items.map((item) => SymptomSummary(id: item.id, name: item.name)).toList();
  }

  @override
  Future<int> create(ReactionDraft draft) async {
    if (draft.symptomIds.isEmpty) throw const FormatException('Selecciona al menos un síntoma.');
    if (draft.intensity < 1 || draft.intensity > 3) throw const FormatException('La intensidad no es válida.');
    if (await hasActiveReaction()) throw const FormatException('Ya existe una reacción activa.');

    final now = DateTime.now();
    late int reactionId;
    await _database.transaction(() async {
      reactionId = await _database.reactionDao.insertReaction(ReactionsCompanion.insert(
        startedAt: draft.startedAt,
        intensity: draft.intensity,
        bodyArea: Value(draft.bodyArea?.trim().isEmpty == true ? null : draft.bodyArea?.trim()),
        notes: Value(draft.notes?.trim().isEmpty == true ? null : draft.notes?.trim()),
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ));
      for (final symptomId in draft.symptomIds.toSet()) {
        await _database.reactionDao.insertReactionSymptom(
          ReactionSymptomsCompanion.insert(reactionId: reactionId, symptomId: symptomId),
        );
      }
    });
    return reactionId;
  }

  @override
  Future<void> finish(int reactionId, DateTime endedAt) async {
    final active = await _database.reactionDao.active();
    if (active == null || active.id != reactionId) throw const FormatException('La reacción ya no está activa.');
    if (endedAt.isBefore(active.startedAt)) throw const FormatException('La hora final no puede ser anterior al inicio.');
    await _database.reactionDao.finish(reactionId, endedAt, endedAt.difference(active.startedAt).inMinutes);
  }

  @override
  Future<bool> hasActiveReaction() async => await _database.reactionDao.active() != null;

  @override
  Future<List<ReactionSummary>> forDay(DateTime day) async {
    final from = DateTime(day.year, day.month, day.day);
    final reactions = await _database.reactionDao.between(from, from.add(const Duration(days: 1)));
    final result = <ReactionSummary>[];
    for (final reaction in reactions) {
      final links = await _database.reactionDao.symptomsForReaction(reaction.id);
      final photos = await _database.reactionDao.photosForReaction(reaction.id);
      final symptomNames = <String>[];
      for (final link in links) {
        final symptom = await _database.symptomDao.findById(link.symptomId);
        if (symptom != null) symptomNames.add(symptom.name);
      }
      result.add(ReactionSummary(
        id: reaction.id,
        startedAt: reaction.startedAt,
        endedAt: reaction.endedAt,
        intensity: reaction.intensity,
        durationMinutes: reaction.durationMinutes,
        bodyArea: reaction.bodyArea,
        notes: reaction.notes,
        status: reaction.status == 'active' ? ReactionStatus.active : ReactionStatus.finished,
        symptoms: symptomNames,
        symptomIds: links.map((link) => link.symptomId).toList(),
        photoPaths: photos.map((photo) => photo.filePath).toList(),
      ));
    }
    return result;
  }

  Future<Set<DateTime>> daysWithReactions(DateTime month) async {
    final from = DateTime(month.year, month.month);
    final reactions = await _database.reactionDao.between(from, DateTime(month.year, month.month + 1));
    return reactions.map((reaction) => DateTime(reaction.startedAt.year, reaction.startedAt.month, reaction.startedAt.day)).toSet();
  }

  @override
  Future<void> addPhoto(int reactionId, String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(path.join(directory.path, 'reaction_photos'));
    await photoDirectory.create(recursive: true);
    final extension = path.extension(sourcePath).isEmpty ? '.jpg' : path.extension(sourcePath);
    final targetPath = path.join(photoDirectory.path, '${reactionId}_${DateTime.now().microsecondsSinceEpoch}$extension');
    await File(sourcePath).copy(targetPath);
    await _database.reactionDao.insertPhoto(ReactionPhotosCompanion.insert(
      reactionId: reactionId,
      filePath: targetPath,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> delete(int reactionId) async {
    final photos = await _database.reactionDao.photosForReaction(reactionId);
    await _database.transaction(() => _database.reactionDao.deleteReaction(reactionId));
    for (final photo in photos) {
      final file = File(photo.filePath);
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<void> update(int reactionId, ReactionDraft draft) async {
    if (draft.symptomIds.isEmpty) throw const FormatException('Selecciona al menos un síntoma.');
    if (draft.intensity < 1 || draft.intensity > 3) throw const FormatException('La intensidad no es válida.');
    if (draft.status == ReactionStatus.active) {
      final active = await _database.reactionDao.active();
      if (active != null && active.id != reactionId) throw const FormatException('Ya existe otra reacción activa.');
    }
    final now = DateTime.now();
    final duration = draft.endedAt?.difference(draft.startedAt).inMinutes;
    await _database.transaction(() async {
      await _database.reactionDao.updateReaction(
        reactionId,
        ReactionsCompanion(
          startedAt: Value(draft.startedAt),
          endedAt: Value(draft.endedAt),
          intensity: Value(draft.intensity),
          durationMinutes: Value(duration),
          bodyArea: Value(draft.bodyArea?.trim().isEmpty == true ? null : draft.bodyArea?.trim()),
          notes: Value(draft.notes?.trim().isEmpty == true ? null : draft.notes?.trim()),
          status: Value(draft.status == ReactionStatus.active ? 'active' : 'finished'),
          updatedAt: Value(now),
        ),
      );
      await _database.reactionDao.deleteReactionSymptoms(reactionId);
      for (final symptomId in draft.symptomIds.toSet()) {
        await _database.reactionDao.insertReactionSymptom(ReactionSymptomsCompanion.insert(reactionId: reactionId, symptomId: symptomId));
      }
    });
  }

  @override
  Future<void> deletePhoto(int reactionId, String filePath) async {
    final photos = await _database.reactionDao.photosForReaction(reactionId);
    if (!photos.any((photo) => photo.filePath == filePath)) return;
    await _database.reactionDao.deletePhoto(filePath);
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  }
}
