import 'package:uuid/uuid.dart';

class TrialResult {
  final String id;
  final String deckId;
  final String difficulty;
  final bool victory;
  final int turnsTaken;
  final int xpGained;
  final String? shardCreatureId;
  final int shardsGained;
  final DateTime completedAt;

  TrialResult({
    String? id,
    required this.deckId,
    required this.difficulty,
    required this.victory,
    required this.turnsTaken,
    required this.xpGained,
    this.shardCreatureId,
    this.shardsGained = 0,
    DateTime? completedAt,
  }) : id = id ?? const Uuid().v4(),
       completedAt = completedAt ?? DateTime.now();

  factory TrialResult.fromMap(Map<String, dynamic> map) {
    return TrialResult(
      id: map['id'] as String?,
      deckId: map['deckId'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? 'Calm',
      victory: map['victory'] as bool? ?? false,
      turnsTaken: map['turnsTaken'] as int? ?? 0,
      xpGained: map['xpGained'] as int? ?? 0,
      shardCreatureId: map['shardCreatureId'] as String?,
      shardsGained: map['shardsGained'] as int? ?? 0,
      completedAt:
          DateTime.tryParse(map['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deckId': deckId,
      'difficulty': difficulty,
      'victory': victory,
      'turnsTaken': turnsTaken,
      'xpGained': xpGained,
      'shardCreatureId': shardCreatureId,
      'shardsGained': shardsGained,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
