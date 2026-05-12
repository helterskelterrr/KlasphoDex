import 'package:creature_lens/models/battle_state.dart';
import 'package:creature_lens/models/creature.dart';
import 'package:creature_lens/services/battle_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Battle balance constants', () {
    test('Calm matches the MVP requirements', () {
      final config = BattleRules.configFor(TrialDifficulty.calm);

      expect(config.anomalyHp, 24);
      expect(config.anomalyAttack, 3);
      expect(config.recommendedPower, 45);
      expect(config.xpReward, 20);
      expect(config.shardReward, 1);
    });

    test('Wild matches the MVP requirements', () {
      final config = BattleRules.configFor(TrialDifficulty.wild);

      expect(config.anomalyHp, 36);
      expect(config.anomalyAttack, 5);
      expect(config.recommendedPower, 60);
      expect(config.xpReward, 40);
      expect(config.shardReward, 2);
    });

    test('Mythic matches the MVP requirements', () {
      final config = BattleRules.configFor(TrialDifficulty.mythic);

      expect(config.anomalyHp, 52);
      expect(config.anomalyAttack, 7);
      expect(config.recommendedPower, 75);
      expect(config.xpReward, 70);
      expect(config.shardReward, 3);
    });
  });

  group('Battle card formulas', () {
    test('applies documented cost by rarity and power band', () {
      expect(
        BattleRules.cardFromCreature(
          _creature('weak-common', rarity: 'Common', power: 40),
        ).cost,
        1,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('rare', rarity: 'Rare', power: 65),
        ).cost,
        2,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('epic', rarity: 'Epic', power: 65),
        ).cost,
        3,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('strong-uncommon', rarity: 'Uncommon', power: 90),
        ).cost,
        2,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('strong-legendary', rarity: 'Legendary', power: 90),
        ).cost,
        3,
      );
    });

    test('applies documented damage bonuses by rarity', () {
      expect(
        BattleRules.cardFromCreature(
          _creature('common', rarity: 'Common', power: 60, attack: 60),
        ).damage,
        5,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('uncommon', rarity: 'Uncommon', power: 60, attack: 60),
        ).damage,
        6,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('rare', rarity: 'Rare', power: 60, attack: 60),
        ).damage,
        7,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('epic', rarity: 'Epic', power: 60, attack: 60),
        ).damage,
        8,
      );
      expect(
        BattleRules.cardFromCreature(
          _creature('legendary', rarity: 'Legendary', power: 60, attack: 60),
        ).damage,
        9,
      );
    });

    test('adds anomaly traits with type bonuses and penalties', () {
      expect(
        BattleRules.damageModifierFor(
          trait: AnomalyTrait.overgrown,
          type: 'Fire',
        ),
        2,
      );
      expect(
        BattleRules.damageModifierFor(
          trait: AnomalyTrait.overgrown,
          type: 'Nature',
        ),
        -1,
      );
    });
  });
}

Creature _creature(
  String id, {
  String type = 'Fire',
  String rarity = 'Common',
  required int power,
  int? attack,
}) {
  return Creature(
    id: id,
    userId: 'guest',
    name: 'Creature $id',
    type: type,
    rarity: rarity,
    hp: power,
    attack: attack ?? power,
    defense: power,
    speed: power,
    abilities: const [],
    lore: 'A balance test creature.',
    scannedObject: 'test object',
    discoveredAt: DateTime.utc(2026, 5, 12),
  );
}
