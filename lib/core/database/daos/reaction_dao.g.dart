// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_dao.dart';

// ignore_for_file: type=lint
mixin _$ReactionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReactionsTable get reactions => attachedDatabase.reactions;
  $SymptomsTable get symptoms => attachedDatabase.symptoms;
  $ReactionSymptomsTable get reactionSymptoms =>
      attachedDatabase.reactionSymptoms;
  $ReactionPhotosTable get reactionPhotos => attachedDatabase.reactionPhotos;
  ReactionDaoManager get managers => ReactionDaoManager(this);
}

class ReactionDaoManager {
  final _$ReactionDaoMixin _db;
  ReactionDaoManager(this._db);
  $$ReactionsTableTableManager get reactions =>
      $$ReactionsTableTableManager(_db.attachedDatabase, _db.reactions);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db.attachedDatabase, _db.symptoms);
  $$ReactionSymptomsTableTableManager get reactionSymptoms =>
      $$ReactionSymptomsTableTableManager(
        _db.attachedDatabase,
        _db.reactionSymptoms,
      );
  $$ReactionPhotosTableTableManager get reactionPhotos =>
      $$ReactionPhotosTableTableManager(
        _db.attachedDatabase,
        _db.reactionPhotos,
      );
}
