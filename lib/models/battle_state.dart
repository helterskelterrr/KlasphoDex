enum TrialDifficulty { calm, wild, mythic }

enum AnomalyIntent { attack, guard, distort }

enum AnomalyTrait { overgrown, volcanic, static }

class TrialConfig {
  final TrialDifficulty difficulty;
  final String label;
  final AnomalyTrait trait;
  final int anomalyHp;
  final int anomalyAttack;
  final int recommendedPower;
  final int xpReward;
  final int shardReward;

  const TrialConfig({
    required this.difficulty,
    required this.label,
    required this.trait,
    required this.anomalyHp,
    required this.anomalyAttack,
    required this.recommendedPower,
    required this.xpReward,
    required this.shardReward,
  });
}

class BattleState {
  final List<String> drawPile;
  final List<String> hand;
  final List<String> discardPile;
  final int turn;
  final int focus;
  final int nextTurnFocusBonus;
  final int nextTurnFocusPenalty;
  final int playerResolve;
  final int playerShield;
  final int anomalyHp;
  final int anomalyMaxHp;
  final int anomalyAttack;
  final int anomalyShield;
  final AnomalyIntent anomalyIntent;
  final TrialDifficulty difficulty;
  final List<String> battleLog;
  final bool isFinished;
  final bool victory;
  final int pendingBurn;
  final int nextCardDamageBonus;
  final bool airDrewThisTurn;
  final int anomalyAttackReduction;
  final List<String> quickPlayedIds;
  final AnomalyTrait trait;
  final Map<String, int> damageByCreatureId;

  const BattleState({
    required this.drawPile,
    required this.hand,
    required this.discardPile,
    required this.turn,
    required this.focus,
    required this.nextTurnFocusBonus,
    required this.nextTurnFocusPenalty,
    required this.playerResolve,
    required this.playerShield,
    required this.anomalyHp,
    required this.anomalyMaxHp,
    required this.anomalyAttack,
    required this.anomalyShield,
    required this.anomalyIntent,
    required this.difficulty,
    required this.battleLog,
    required this.isFinished,
    required this.victory,
    this.pendingBurn = 0,
    this.nextCardDamageBonus = 0,
    this.airDrewThisTurn = false,
    this.anomalyAttackReduction = 0,
    this.quickPlayedIds = const [],
    required this.trait,
    this.damageByCreatureId = const {},
  });

  BattleState copyWith({
    List<String>? drawPile,
    List<String>? hand,
    List<String>? discardPile,
    int? turn,
    int? focus,
    int? nextTurnFocusBonus,
    int? nextTurnFocusPenalty,
    int? playerResolve,
    int? playerShield,
    int? anomalyHp,
    int? anomalyMaxHp,
    int? anomalyAttack,
    int? anomalyShield,
    AnomalyIntent? anomalyIntent,
    TrialDifficulty? difficulty,
    List<String>? battleLog,
    bool? isFinished,
    bool? victory,
    int? pendingBurn,
    int? nextCardDamageBonus,
    bool? airDrewThisTurn,
    int? anomalyAttackReduction,
    List<String>? quickPlayedIds,
    AnomalyTrait? trait,
    Map<String, int>? damageByCreatureId,
  }) {
    return BattleState(
      drawPile: drawPile ?? this.drawPile,
      hand: hand ?? this.hand,
      discardPile: discardPile ?? this.discardPile,
      turn: turn ?? this.turn,
      focus: focus ?? this.focus,
      nextTurnFocusBonus: nextTurnFocusBonus ?? this.nextTurnFocusBonus,
      nextTurnFocusPenalty: nextTurnFocusPenalty ?? this.nextTurnFocusPenalty,
      playerResolve: playerResolve ?? this.playerResolve,
      playerShield: playerShield ?? this.playerShield,
      anomalyHp: anomalyHp ?? this.anomalyHp,
      anomalyMaxHp: anomalyMaxHp ?? this.anomalyMaxHp,
      anomalyAttack: anomalyAttack ?? this.anomalyAttack,
      anomalyShield: anomalyShield ?? this.anomalyShield,
      anomalyIntent: anomalyIntent ?? this.anomalyIntent,
      difficulty: difficulty ?? this.difficulty,
      battleLog: battleLog ?? this.battleLog,
      isFinished: isFinished ?? this.isFinished,
      victory: victory ?? this.victory,
      pendingBurn: pendingBurn ?? this.pendingBurn,
      nextCardDamageBonus: nextCardDamageBonus ?? this.nextCardDamageBonus,
      airDrewThisTurn: airDrewThisTurn ?? this.airDrewThisTurn,
      anomalyAttackReduction:
          anomalyAttackReduction ?? this.anomalyAttackReduction,
      quickPlayedIds: quickPlayedIds ?? this.quickPlayedIds,
      trait: trait ?? this.trait,
      damageByCreatureId: damageByCreatureId ?? this.damageByCreatureId,
    );
  }
}
