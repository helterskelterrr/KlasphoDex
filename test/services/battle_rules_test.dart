import 'package:creature_lens/models/battle_deck.dart';
import 'package:creature_lens/models/battle_state.dart';
import 'package:creature_lens/models/creature.dart';
import 'package:creature_lens/services/battle_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BattleRules card derivation', () {
    test('derives cost damage shield and speed tier from a creature', () {
      final card = BattleRules.cardFromCreature(
        _creature(
          id: 'rare-light',
          type: 'Light',
          rarity: 'Rare',
          attack: 84,
          defense: 67,
          speed: 88,
        ),
      );

      expect(card.cost, 2);
      expect(card.damage, 9);
      expect(card.shield, 4);
      expect(card.speedTier, SpeedTier.quick);
      expect(card.effect, BattleCardEffect.focus);
    });

    test('keeps weak common cards cheap without dropping below one focus', () {
      final card = BattleRules.cardFromCreature(
        _creature(
          id: 'small-stone',
          type: 'Earth',
          rarity: 'Common',
          hp: 34,
          attack: 20,
          defense: 22,
          speed: 28,
        ),
      );

      expect(card.cost, 1);
      expect(card.damage, 2);
      expect(card.shield, 1);
      expect(card.speedTier, SpeedTier.slow);
      expect(card.effect, BattleCardEffect.guard);
    });
  });

  group('BattleRules turn flow', () {
    test(
      'starts a calm trial by drawing three cards with visible attack intent',
      () {
        final creatures = _deckCreatures();
        final deck = BattleDeck(
          id: 'deck-1',
          name: 'Field Deck',
          creatureIds: creatures.map((creature) => creature.id).toList(),
          updatedAt: DateTime.utc(2026, 5, 9),
        );

        final state = BattleRules.createInitialState(
          deck: deck,
          creatures: creatures,
          difficulty: TrialDifficulty.calm,
        );

        expect(state.hand, const ['c1', 'c2', 'c3']);
        expect(state.drawPile.length, 5);
        expect(state.focus, 3);
        expect(state.playerResolve, 20);
        expect(state.anomalyHp, 24);
        expect(state.anomalyIntent, AnomalyIntent.attack);
      },
    );

    test('plays type effects and resolves the anomaly intent at end turn', () {
      final creatures = _deckCreatures();
      final deck = BattleDeck(
        id: 'deck-1',
        name: 'Field Deck',
        creatureIds: creatures.map((creature) => creature.id).toList(),
        updatedAt: DateTime.utc(2026, 5, 9),
      );
      final initial = BattleRules.createInitialState(
        deck: deck,
        creatures: creatures,
        difficulty: TrialDifficulty.calm,
      );

      final afterEarth = BattleRules.playCard(
        state: initial,
        card: BattleRules.cardFromCreature(creatures[0]),
      );
      final afterLight = BattleRules.playCard(
        state: afterEarth,
        card: BattleRules.cardFromCreature(creatures[1]),
      );
      final afterTurn = BattleRules.endTurn(afterLight);

      expect(afterEarth.playerShield, 5);
      expect(afterLight.nextTurnFocusBonus, 1);
      expect(afterTurn.turn, 2);
      expect(afterTurn.focus, 4);
      expect(afterTurn.playerResolve, 20);
      expect(afterTurn.playerShield, 0);
      expect(afterTurn.anomalyIntent, AnomalyIntent.guard);
    });

    test('marks victory when card damage defeats the anomaly', () {
      final creatures = _deckCreatures();
      final state = BattleRules.createInitialState(
        deck: BattleDeck(
          id: 'deck-1',
          name: 'Field Deck',
          creatureIds: creatures.map((creature) => creature.id).toList(),
          updatedAt: DateTime.utc(2026, 5, 9),
        ),
        creatures: creatures,
        difficulty: TrialDifficulty.calm,
      ).copyWith(anomalyHp: 2);

      final next = BattleRules.playCard(
        state: state,
        card: BattleRules.cardFromCreature(creatures[2]),
      );

      expect(next.isFinished, isTrue);
      expect(next.victory, isTrue);
      expect(next.anomalyHp, 0);
    });
  });
}

List<Creature> _deckCreatures() {
  return [
    _creature(id: 'c1', type: 'Earth', rarity: 'Common', attack: 48),
    _creature(id: 'c2', type: 'Light', rarity: 'Rare', attack: 60, speed: 78),
    _creature(id: 'c3', type: 'Fire', rarity: 'Uncommon', attack: 72),
    _creature(id: 'c4', type: 'Water', rarity: 'Common'),
    _creature(id: 'c5', type: 'Air', rarity: 'Rare', speed: 86),
    _creature(id: 'c6', type: 'Nature', rarity: 'Common'),
    _creature(id: 'c7', type: 'Shadow', rarity: 'Rare'),
    _creature(id: 'c8', type: 'Electric', rarity: 'Epic', attack: 82),
  ];
}

Creature _creature({
  required String id,
  String type = 'Nature',
  String rarity = 'Common',
  int hp = 60,
  int attack = 60,
  int defense = 55,
  int speed = 55,
}) {
  return Creature(
    id: id,
    userId: 'guest',
    name: 'Creature $id',
    type: type,
    rarity: rarity,
    hp: hp,
    attack: attack,
    defense: defense,
    speed: speed,
    abilities: const [
      CreatureAbility(
        name: 'Field Spark',
        description: 'A useful trial move.',
        type: 'Light',
      ),
    ],
    lore: 'A test creature.',
    scannedObject: 'test object',
    scannedLabels: const ['test 99%'],
    discoveredAt: DateTime.utc(2026, 5, 9),
  );
}
