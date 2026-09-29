import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reaction_symptoms_table.dart';
import '../tables/reaction_photos_table.dart';
import '../tables/reactions_table.dart';

part 'reaction_dao.g.dart';

@DriftAccessor(tables: [Reactions, ReactionSymptoms, ReactionPhotos])
class ReactionDao extends DatabaseAccessor<AppDatabase> with _$ReactionDaoMixin {
  ReactionDao(super.attachedDatabase);

  Future<Reaction?> active() => (select(reactions)..where((reaction) => reaction.status.equals('active'))).getSingleOrNull();

  Future<int> insertReaction(ReactionsCompanion entry) => into(reactions).insert(entry);

  Future<void> finish(int id, DateTime endedAt, int durationMinutes) => (update(reactions)..where((reaction) => reaction.id.equals(id))).write(
        ReactionsCompanion(
          endedAt: Value(endedAt),
          durationMinutes: Value(durationMinutes),
          status: const Value('finished'),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<List<Reaction>> between(DateTime from, DateTime to) => (select(reactions)
        ..where((reaction) => reaction.startedAt.isBetweenValues(from, to))
        ..orderBy([(reaction) => OrderingTerm(expression: reaction.startedAt)]))
      .get();

  Future<List<ReactionSymptom>> symptomsForReaction(int reactionId) =>
      (select(reactionSymptoms)..where((item) => item.reactionId.equals(reactionId))).get();

  Future<void> insertReactionSymptom(ReactionSymptomsCompanion entry) => into(reactionSymptoms).insert(entry);

  Future<void> updateReaction(int reactionId, ReactionsCompanion entry) =>
      (update(reactions)..where((reaction) => reaction.id.equals(reactionId))).write(entry);

  Future<void> deleteReactionSymptoms(int reactionId) =>
      (delete(reactionSymptoms)..where((item) => item.reactionId.equals(reactionId))).go();

  Future<void> insertPhoto(ReactionPhotosCompanion entry) => into(reactionPhotos).insert(entry);

  Future<List<ReactionPhoto>> photosForReaction(int reactionId) =>
      (select(reactionPhotos)..where((photo) => photo.reactionId.equals(reactionId))).get();

  Future<void> deletePhoto(String filePath) => (delete(reactionPhotos)..where((photo) => photo.filePath.equals(filePath))).go();

  Future<void> deleteReaction(int reactionId) async {
    await (delete(reactionSymptoms)..where((item) => item.reactionId.equals(reactionId))).go();
    await (delete(reactionPhotos)..where((photo) => photo.reactionId.equals(reactionId))).go();
    await (delete(reactions)..where((reaction) => reaction.id.equals(reactionId))).go();
  }
}
