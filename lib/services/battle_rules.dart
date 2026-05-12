import 'dart:math' as math;

import '../models/battle_deck.dart';
import '../models/battle_state.dart';
import '../models/creature.dart';

enum SpeedTier { slow, normal, quick }

enum BattleCardEffect { burn, mend, guard, draft, spark, grow, weaken, focus }

class BattleCard {
  final String creatureId;
  final String displayName;
  final String type;
  final String rarity;
  final int power;
  final int cost;
  final int damage;
  final int shield;
  final SpeedTier speedTier;
  final BattleCardEffect effect;

  const BattleCard({
    required this.creatureId,
    required this.displayName,
    required this.type,
    required this.rarity,
    required this.power,
    required this.cost,
    required this.damage,
    required this.shield,
    required this.speedTier,
    required this.effect,
  });
}

class BattleRules {
  static const maxResolve = 20;
  static const maxTurns = 7;

  static const calm = TrialConfig(
    difficulty: TrialDifficulty.calm,
    label: 'Calm',
    trait: AnomalyTrait.overgrown,
    anomalyHp: 24,
    anomalyAttack: 3,
    recommendedPower: 45,
    xpReward: 20,
    shardReward: 1,
  );

  static const wild = TrialConfig(
    difficulty: TrialDifficulty.wild,
    label: 'Wild',
    trait: AnomalyTrait.volcanic,
    anomalyHp: 36,
    anomalyAttack: 5,
    recommendedPower: 60,
    xpReward: 40,
    shardReward: 2,
  );

  static const mythic = TrialConfig(
    difficulty: TrialDifficulty.mythic,
    label: 'Mythic',
    trait: AnomalyTrait.static,
    anomalyHp: 52,
    anomalyAttack: 7,
    recommendedPower: 75,
    xpReward: 70,
    shardReward: 3,
  );

  static TrialConfig configFor(TrialDifficulty difficulty) {
    switch (difficulty) {
      case TrialDifficulty.calm:
        return calm;
      case TrialDifficulty.wild:
        return wild;
      case TrialDifficulty.mythic:
        return mythic;
    }
  }

  static BattleCard cardFromCreature(Creature creature) {
    return BattleCard(
      creatureId: creature.id,
      displayName: creature.name,
      type: creature.type,
      rarity: creature.rarity,
      power: creature.totalPower,
      cost: _costFor(creature),
      damage: _damageFor(creature),
      shield: math.max(0, (creature.defense / 18).round()),
      speedTier: _speedTierFor(creature.speed),
      effect: _effectFor(creature.type),
    );
  }

  static BattleState createInitialState({
    required BattleDeck deck,
    required List<Creature> creatures,
    required TrialDifficulty difficulty,
  }) {
    final config = configFor(difficulty);
    final availableIds = creatures.map((creature) => creature.id).toSet();
    final drawPile = deck.creatureIds
        .where((id) => availableIds.contains(id))
        .take(BattleDeck.requiredCardCount)
        .toList();
    final firstHand = drawPile.take(3).toList();
    final remaining = drawPile.skip(3).toList();

    return BattleState(
      drawPile: remaining,
      hand: firstHand,
      discardPile: const [],
      turn: 1,
      focus: 3,
      nextTurnFocusBonus: 0,
      nextTurnFocusPenalty: 0,
      playerResolve: maxResolve,
      playerShield: 0,
      anomalyHp: config.anomalyHp,
      anomalyMaxHp: config.anomalyHp,
      anomalyAttack: config.anomalyAttack,
      anomalyShield: 0,
      anomalyIntent: AnomalyIntent.attack,
      difficulty: difficulty,
      trait: config.trait,
      battleLog: const ['Anomaly signal acquired.'],
      isFinished: false,
      victory: false,
    );
  }

  static BattleState playCard({
    required BattleState state,
    required BattleCard card,
  }) {
    if (state.isFinished) return state;
    if (!state.hand.contains(card.creatureId)) return state;
    if (state.focus < card.cost) return state;

    final hand = [...state.hand]..remove(card.creatureId);
    var drawPile = [...state.drawPile];
    final discard = [...state.discardPile, card.creatureId];
    final log = [...state.battleLog];
    var focus = state.focus - card.cost;
    var playerResolve = state.playerResolve;
    var playerShield = state.playerShield;
    var anomalyHp = state.anomalyHp;
    var anomalyShield = state.anomalyShield;
    var pendingBurn = state.pendingBurn;
    var nextDamage = state.nextCardDamageBonus;
    var airDrew = state.airDrewThisTurn;
    var nextTurnFocusBonus = state.nextTurnFocusBonus;
    var attackReduction = state.anomalyAttackReduction;
    var quickPlayedIds = [...state.quickPlayedIds];
    final damageByCreatureId = Map<String, int>.from(state.damageByCreatureId);

    final traitModifier = damageModifierFor(
      trait: state.trait,
      type: card.type,
    );
    final damage = math.max(1, card.damage + nextDamage + traitModifier);
    nextDamage = 0;
    final beforeHp = anomalyHp;
    final damageResult = _damageAnomaly(
      hp: anomalyHp,
      shield: anomalyShield,
      amount: damage,
    );
    anomalyHp = damageResult.$1;
    anomalyShield = damageResult.$2;
    var creditedDamage = math.max(0, beforeHp - anomalyHp);

    if (traitModifier != 0) {
      final sign = traitModifier > 0 ? '+' : '';
      log.add(
        '${card.displayName} met a ${traitLabel(state.trait)} anomaly ($sign$traitModifier damage).',
      );
    }

    switch (card.effect) {
      case BattleCardEffect.burn:
        pendingBurn += 1;
        log.add('${card.displayName} marked the anomaly with Burn.');
        break;
      case BattleCardEffect.mend:
        playerResolve = math.min(maxResolve, playerResolve + 1);
        log.add('${card.displayName} restored 1 resolve.');
        break;
      case BattleCardEffect.guard:
        playerShield += card.shield + 2;
        log.add('${card.displayName} raised a guard.');
        break;
      case BattleCardEffect.draft:
        if (!airDrew) {
          final draw = _drawCards(
            drawPile: drawPile,
            hand: hand,
            discardPile: discard,
            count: 1,
          );
          drawPile = draw.drawPile;
          hand
            ..clear()
            ..addAll(draw.hand);
          discard
            ..clear()
            ..addAll(draw.discardPile);
          airDrew = true;
        }
        log.add('${card.displayName} drafted a new card.');
        break;
      case BattleCardEffect.spark:
        final beforeSparkHp = anomalyHp;
        anomalyHp = math.max(0, anomalyHp - 1);
        creditedDamage += math.max(0, beforeSparkHp - anomalyHp);
        log.add('${card.displayName} sparked through the shield.');
        break;
      case BattleCardEffect.grow:
        nextDamage += 1;
        log.add('${card.displayName} empowered the next card.');
        break;
      case BattleCardEffect.weaken:
        attackReduction += 1;
        log.add('${card.displayName} weakened the next attack.');
        break;
      case BattleCardEffect.focus:
        nextTurnFocusBonus += 1;
        log.add('${card.displayName} focused the scanner field.');
        break;
    }

    if (creditedDamage > 0) {
      damageByCreatureId.update(
        card.creatureId,
        (value) => value + creditedDamage,
        ifAbsent: () => creditedDamage,
      );
    }

    if (card.speedTier == SpeedTier.quick &&
        !quickPlayedIds.contains(card.creatureId)) {
      final draw = _drawCards(
        drawPile: drawPile,
        hand: hand,
        discardPile: discard,
        count: 1,
      );
      drawPile = draw.drawPile;
      hand
        ..clear()
        ..addAll(draw.hand);
      discard
        ..clear()
        ..addAll(draw.discardPile);
      quickPlayedIds.add(card.creatureId);
      log.add('${card.displayName} moved quickly and drew a card.');
    }

    log.add('${card.displayName} dealt $damage damage.');
    final won = anomalyHp <= 0;
    return state.copyWith(
      drawPile: drawPile,
      hand: hand,
      discardPile: discard,
      focus: focus,
      playerResolve: playerResolve,
      playerShield: playerShield,
      anomalyHp: anomalyHp,
      anomalyShield: anomalyShield,
      pendingBurn: pendingBurn,
      nextCardDamageBonus: nextDamage,
      airDrewThisTurn: airDrew,
      nextTurnFocusBonus: nextTurnFocusBonus,
      anomalyAttackReduction: attackReduction,
      quickPlayedIds: quickPlayedIds,
      damageByCreatureId: damageByCreatureId,
      battleLog: log,
      isFinished: won,
      victory: won,
    );
  }

  static BattleState endTurn(BattleState state) {
    if (state.isFinished) return state;

    final log = [...state.battleLog];
    var anomalyHp = state.anomalyHp;
    var anomalyShield = state.anomalyShield;
    var playerResolve = state.playerResolve;
    var nextTurnFocusPenalty = state.nextTurnFocusPenalty;

    if (state.pendingBurn > 0) {
      final burn = _damageAnomaly(
        hp: anomalyHp,
        shield: anomalyShield,
        amount: state.pendingBurn,
      );
      anomalyHp = burn.$1;
      anomalyShield = burn.$2;
      log.add('Burn dealt ${state.pendingBurn} end-turn damage.');
    }

    if (anomalyHp <= 0) {
      return state.copyWith(
        anomalyHp: 0,
        anomalyShield: anomalyShield,
        battleLog: log,
        isFinished: true,
        victory: true,
      );
    }

    switch (state.anomalyIntent) {
      case AnomalyIntent.attack:
        final incoming = math.max(
          0,
          state.anomalyAttack - state.anomalyAttackReduction,
        );
        final blocked = math.min(state.playerShield, incoming);
        final damage = incoming - blocked;
        playerResolve = math.max(0, playerResolve - damage);
        log.add('Anomaly attacked for $damage resolve damage.');
        break;
      case AnomalyIntent.guard:
        anomalyShield += 4;
        log.add('Anomaly formed a 4-point guard.');
        break;
      case AnomalyIntent.distort:
        nextTurnFocusPenalty += 1;
        log.add('Signal distortion will reduce next-turn focus.');
        break;
    }

    if (playerResolve <= 0) {
      return state.copyWith(
        playerResolve: 0,
        anomalyHp: anomalyHp,
        anomalyShield: anomalyShield,
        battleLog: log,
        isFinished: true,
        victory: false,
      );
    }

    final nextTurn = state.turn + 1;
    if (nextTurn > maxTurns) {
      log.add('The anomaly slipped beyond scanner range.');
      return state.copyWith(
        turn: nextTurn,
        playerResolve: playerResolve,
        playerShield: 0,
        anomalyHp: anomalyHp,
        anomalyShield: anomalyShield,
        battleLog: log,
        isFinished: true,
        victory: false,
      );
    }

    final drawn = _drawUntilHandLimit(
      drawPile: state.drawPile,
      hand: state.hand,
      discardPile: state.discardPile,
    );
    final focus = math.max(
      1,
      3 + state.nextTurnFocusBonus - nextTurnFocusPenalty,
    );

    return state.copyWith(
      drawPile: drawn.drawPile,
      hand: drawn.hand,
      discardPile: drawn.discardPile,
      turn: nextTurn,
      focus: focus,
      nextTurnFocusBonus: 0,
      nextTurnFocusPenalty: 0,
      playerResolve: playerResolve,
      playerShield: 0,
      anomalyHp: anomalyHp,
      anomalyShield: anomalyShield,
      anomalyIntent: _intentForTurn(nextTurn),
      pendingBurn: 0,
      nextCardDamageBonus: 0,
      airDrewThisTurn: false,
      anomalyAttackReduction: 0,
      battleLog: log,
    );
  }

  static int averageDeckPower({
    required BattleDeck? deck,
    required List<Creature> creatures,
  }) {
    if (deck == null || deck.creatureIds.isEmpty) return 0;
    final byId = {for (final creature in creatures) creature.id: creature};
    final powers = deck.creatureIds
        .map((id) => byId[id]?.totalPower)
        .whereType<int>()
        .toList();
    if (powers.isEmpty) return 0;
    return (powers.reduce((a, b) => a + b) / powers.length).round();
  }

  static int damageModifierFor({
    required AnomalyTrait trait,
    required String type,
  }) {
    final normalizedType = type.toLowerCase();
    return switch (trait) {
      AnomalyTrait.overgrown =>
        normalizedType == 'fire'
            ? 2
            : normalizedType == 'nature'
            ? -1
            : 0,
      AnomalyTrait.volcanic =>
        normalizedType == 'water'
            ? 2
            : normalizedType == 'nature'
            ? -1
            : 0,
      AnomalyTrait.static =>
        normalizedType == 'earth'
            ? 2
            : normalizedType == 'air'
            ? -1
            : 0,
    };
  }

  static String traitLabel(AnomalyTrait trait) {
    return switch (trait) {
      AnomalyTrait.overgrown => 'Overgrown',
      AnomalyTrait.volcanic => 'Volcanic',
      AnomalyTrait.static => 'Static',
    };
  }

  static String? mvpCreatureId(BattleState state) {
    final entries =
        state.damageByCreatureId.entries
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) return null;
    return entries.first.key;
  }

  static int _costFor(Creature creature) {
    final rarity = creature.rarity.toLowerCase();
    var cost = switch (rarity) {
      'rare' => 2,
      'epic' => 3,
      'legendary' => 3,
      _ => 1,
    };
    if (creature.totalPower < 45) cost -= 1;
    if (creature.totalPower >= 85) cost += 1;
    return cost.clamp(1, 3);
  }

  static int _damageFor(Creature creature) {
    final rarityBonus = switch (creature.rarity.toLowerCase()) {
      'uncommon' => 1,
      'rare' => 2,
      'epic' => 3,
      'legendary' => 4,
      _ => 0,
    };
    return math.max(1, (creature.attack / 12).round()) + rarityBonus;
  }

  static SpeedTier _speedTierFor(int speed) {
    if (speed < 45) return SpeedTier.slow;
    if (speed >= 75) return SpeedTier.quick;
    return SpeedTier.normal;
  }

  static BattleCardEffect _effectFor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return BattleCardEffect.burn;
      case 'water':
        return BattleCardEffect.mend;
      case 'earth':
        return BattleCardEffect.guard;
      case 'air':
        return BattleCardEffect.draft;
      case 'electric':
        return BattleCardEffect.spark;
      case 'nature':
        return BattleCardEffect.grow;
      case 'shadow':
        return BattleCardEffect.weaken;
      case 'light':
        return BattleCardEffect.focus;
      default:
        return BattleCardEffect.grow;
    }
  }

  static (int, int) _damageAnomaly({
    required int hp,
    required int shield,
    required int amount,
  }) {
    final absorbed = math.min(shield, amount);
    final remainingShield = shield - absorbed;
    final damageToHp = amount - absorbed;
    return (math.max(0, hp - damageToHp), remainingShield);
  }

  static _DrawResult _drawUntilHandLimit({
    required List<String> drawPile,
    required List<String> hand,
    required List<String> discardPile,
  }) {
    return _drawCards(
      drawPile: drawPile,
      hand: hand,
      discardPile: discardPile,
      count: math.max(0, 3 - hand.length),
    );
  }

  static _DrawResult _drawCards({
    required List<String> drawPile,
    required List<String> hand,
    required List<String> discardPile,
    required int count,
  }) {
    final nextDraw = [...drawPile];
    final nextHand = [...hand];
    final nextDiscard = [...discardPile];
    for (var i = 0; i < count; i++) {
      if (nextDraw.isEmpty && nextDiscard.isNotEmpty) {
        nextDraw.addAll(nextDiscard.reversed);
        nextDiscard.clear();
      }
      if (nextDraw.isEmpty) break;
      nextHand.add(nextDraw.removeAt(0));
    }
    return _DrawResult(
      drawPile: nextDraw,
      hand: nextHand,
      discardPile: nextDiscard,
    );
  }

  static AnomalyIntent _intentForTurn(int turn) {
    final patternIndex = (turn - 1) % 4;
    return switch (patternIndex) {
      0 => AnomalyIntent.attack,
      1 => AnomalyIntent.guard,
      2 => AnomalyIntent.attack,
      _ => AnomalyIntent.distort,
    };
  }
}

class _DrawResult {
  final List<String> drawPile;
  final List<String> hand;
  final List<String> discardPile;

  const _DrawResult({
    required this.drawPile,
    required this.hand,
    required this.discardPile,
  });
}
