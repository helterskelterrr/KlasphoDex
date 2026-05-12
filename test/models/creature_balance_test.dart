import 'package:creature_lens/models/creature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Creature balance normalization', () {
    test('clamps generated stats into the legal 30-100 range', () {
      final creature = Creature.fromMap({
        'rarity': 'Rare',
        'hp': 4,
        'attack': 999,
        'defense': -12,
        'speed': 150,
        'discoveredAt': DateTime.utc(2026, 5, 12).toIso8601String(),
      });

      expect(creature.hp, inInclusiveRange(30, 100));
      expect(creature.attack, inInclusiveRange(30, 100));
      expect(creature.defense, inInclusiveRange(30, 100));
      expect(creature.speed, inInclusiveRange(30, 100));
    });

    test(
      'normalizes rarity text and keeps legendary stats in a strong band',
      () {
        final creature = Creature.fromMap({
          'rarity': 'legendary',
          'hp': 35,
          'attack': 42,
          'defense': 48,
          'speed': 51,
          'discoveredAt': DateTime.utc(2026, 5, 12).toIso8601String(),
        });

        expect(creature.rarity, 'Legendary');
        expect(creature.hp, greaterThanOrEqualTo(70));
        expect(creature.attack, greaterThanOrEqualTo(70));
        expect(creature.defense, greaterThanOrEqualTo(70));
        expect(creature.speed, greaterThanOrEqualTo(70));
        expect(creature.totalPower, lessThanOrEqualTo(100));
      },
    );

    test('caps common outliers so rarity still matters', () {
      final creature = Creature.fromMap({
        'rarity': 'Common',
        'hp': 100,
        'attack': 100,
        'defense': 100,
        'speed': 100,
        'discoveredAt': DateTime.utc(2026, 5, 12).toIso8601String(),
      });

      expect(creature.totalPower, lessThanOrEqualTo(70));
    });
  });
}
