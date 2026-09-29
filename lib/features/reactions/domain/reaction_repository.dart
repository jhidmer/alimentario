enum ReactionStatus { active, finished }

class ReactionDraft {
  const ReactionDraft({
    required this.startedAt,
    required this.intensity,
    required this.symptomIds,
    this.bodyArea,
    this.notes,
    this.endedAt,
    this.status = ReactionStatus.active,
  });

  final DateTime startedAt;
  final int intensity;
  final List<int> symptomIds;
  final String? bodyArea;
  final String? notes;
  final DateTime? endedAt;
  final ReactionStatus status;
}

class SymptomSummary {
  const SymptomSummary({required this.id, required this.name});

  final int id;
  final String name;
}

class ReactionSummary {
  const ReactionSummary({
    required this.id,
    required this.startedAt,
    required this.intensity,
    required this.symptoms,
    required this.symptomIds,
    required this.status,
    this.endedAt,
    this.durationMinutes,
    this.bodyArea,
    this.notes,
    this.photoPaths = const [],
  });

  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int intensity;
  final int? durationMinutes;
  final String? bodyArea;
  final String? notes;
  final ReactionStatus status;
  final List<String> symptoms;
  final List<int> symptomIds;
  final List<String> photoPaths;
}

abstract interface class ReactionRepository {
  Future<int> create(ReactionDraft draft);

  Future<void> finish(int reactionId, DateTime endedAt);

  Future<bool> hasActiveReaction();

  Future<List<SymptomSummary>> symptoms();

  Future<List<ReactionSummary>> forDay(DateTime day);

  Future<void> addPhoto(int reactionId, String sourcePath);

  Future<void> delete(int reactionId);

  Future<void> deletePhoto(int reactionId, String filePath);

  Future<void> update(int reactionId, ReactionDraft draft);
}
