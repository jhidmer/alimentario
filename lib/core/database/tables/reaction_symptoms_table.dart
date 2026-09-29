import 'package:drift/drift.dart';

import 'reactions_table.dart';
import 'symptoms_table.dart';

@TableIndex(name: 'idx_reaction_symptoms_reaction_id', columns: {#reactionId})
@TableIndex(name: 'idx_reaction_symptoms_symptom_id', columns: {#symptomId})
@TableIndex(name: 'uq_reaction_symptoms_reaction_symptom', columns: {#reactionId, #symptomId}, unique: true)
class ReactionSymptoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reactionId => integer().references(Reactions, #id)();
  IntColumn get symptomId => integer().references(Symptoms, #id)();
  IntColumn get intensityOverride => integer().nullable()();
  TextColumn get notes => text().nullable()();
}
