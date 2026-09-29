import 'package:drift/drift.dart';

import 'reactions_table.dart';

class ReactionPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reactionId => integer().references(Reactions, #id)();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime()();
}
