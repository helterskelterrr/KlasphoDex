import 'package:creature_lens/core/theme/app_theme.dart';
import 'package:creature_lens/models/battle_deck.dart';
import 'package:creature_lens/models/battle_state.dart';
import 'package:creature_lens/models/creature.dart';
import 'package:creature_lens/models/trial_result.dart';
import 'package:creature_lens/providers/battle_provider.dart';
import 'package:creature_lens/providers/creature_provider.dart';
import 'package:creature_lens/providers/deck_provider.dart';
import 'package:creature_lens/providers/user_provider.dart';
import 'package:creature_lens/screens/home/home_screen.dart';
import 'package:creature_lens/screens/deckbuilder/battle_screen.dart';
import 'package:creature_lens/screens/deckbuilder/deck_builder_screen.dart';
import 'package:creature_lens/screens/deckbuilder/trial_result_screen.dart';
import 'package:creature_lens/screens/reveal/creature_reveal_screen.dart';
import 'package:creature_lens/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('deck builder opens a tactical card detail bottom sheet', (
    tester,
  ) async {
    final creatures = _creatures();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allCreaturesProvider.overrideWith(
            () => _TestCreatureCollectionNotifier(creatures),
          ),
          activeDeckProvider.overrideWith(() => _TestDeckNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const DeckBuilderScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Ember Mote').first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('TYPE EFFECT'), findsOneWidget);
    expect(find.text('Speed Tier'), findsOneWidget);
    expect(find.text('ADD TO DECK'), findsOneWidget);
  });

  testWidgets('battle screen calls out the next anomaly intent', (
    tester,
  ) async {
    final creatures = _creatures();
    final deck = BattleDeck(
      id: 'deck-1',
      name: 'Field Deck',
      creatureIds: creatures.map((creature) => creature.id).toList(),
      updatedAt: DateTime.utc(2026, 5, 10),
    );

    final container = ProviderContainer(
      overrides: [
        allCreaturesProvider.overrideWith(
          () => _TestCreatureCollectionNotifier(creatures),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(currentBattleProvider.notifier)
        .startTrial(
          deck: deck,
          creatures: creatures,
          difficulty: TrialDifficulty.wild,
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BattleScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('NEXT INTENT'), findsOneWidget);
    expect(find.text('Attack'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
  });

  testWidgets('victory result shows the shard recipient creature', (
    tester,
  ) async {
    final creatures = _creatures();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allCreaturesProvider.overrideWith(
            () => _TestCreatureCollectionNotifier(creatures),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: TrialResultScreen(
            result: TrialResult(
              deckId: 'deck-1',
              difficulty: 'Wild',
              victory: true,
              turnsTaken: 4,
              xpGained: 40,
              shardCreatureId: 'c1',
              shardsGained: 2,
              completedAt: DateTime.utc(2026, 5, 10),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SHARDS APPLIED TO'), findsOneWidget);
    expect(find.text('Ember Mote'), findsOneWidget);
    expect(find.text('+2 Evolution Shards'), findsOneWidget);
  });

  testWidgets('home daily missions reflect the current demo collection', (
    tester,
  ) async {
    final creatures = _creatures().take(4).toList();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider.overrideWith(() => _TestUserNotifier(creatures.length)),
          allCreaturesProvider.overrideWith(
            () => _TestCreatureCollectionNotifier(creatures),
          ),
          activeDeckProvider.overrideWith(() => _TestDeckNotifier()),
        ],
        child: MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Daily Missions'), findsOneWidget);
    expect(find.text('Scan 3 objects'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Find a Rare+'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('Scan Nature type'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('reveal screen labels fallback creatures as offline synthesis', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allCreaturesProvider.overrideWith(
            () => _TestCreatureCollectionNotifier(const []),
          ),
          userProvider.overrideWith(() => _TestUserNotifier(0)),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: CreatureRevealScreen(creature: _offlineCreature()),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.text('OFFLINE SYNTHESIS MODE'), findsOneWidget);
  });
}

List<Creature> _creatures() {
  final specs = [
    ('c1', 'Ember Mote', 'Fire', 'Rare', 92),
    ('c2', 'Dew Archive', 'Water', 'Uncommon', 78),
    ('c3', 'Stone Warden', 'Earth', 'Common', 74),
    ('c4', 'Gale Quill', 'Air', 'Rare', 70),
    ('c5', 'Spark Finch', 'Electric', 'Epic', 86),
    ('c6', 'Moss Lantern', 'Nature', 'Common', 66),
    ('c7', 'Umbral Thread', 'Shadow', 'Rare', 82),
    ('c8', 'Halo Sprout', 'Light', 'Uncommon', 72),
  ];
  return specs.map((spec) {
    final (id, name, type, rarity, power) = spec;
    return Creature(
      id: id,
      userId: 'guest',
      name: name,
      type: type,
      rarity: rarity,
      hp: power,
      attack: power,
      defense: power,
      speed: power,
      abilities: const [
        CreatureAbility(
          name: 'Field Signal',
          description: 'A stable research-field response.',
          type: 'Light',
        ),
      ],
      lore: 'A compact field trial specimen.',
      scannedObject: 'desk object',
      scannedLabels: const ['object 99%'],
      discoveredAt: DateTime.utc(2026, 5, 10),
    );
  }).toList();
}

Creature _offlineCreature() {
  return Creature(
    id: 'offline-1',
    userId: 'guest',
    name: 'Mystery Creature',
    type: 'Shadow',
    rarity: 'Common',
    hp: 50,
    attack: 50,
    defense: 50,
    speed: 50,
    abilities: const [
      CreatureAbility(
        name: 'Unknown Force',
        description: 'A mysterious power hums under the surface.',
        type: 'Shadow',
      ),
    ],
    lore: 'Offline synthesis mode generated a safe fallback creature.',
    scannedObject: 'ceramic mug',
    scannedLabels: const ['ceramic mug 94%'],
    discoveredAt: DateTime.utc(2026, 5, 10),
  );
}

class _TestCreatureCollectionNotifier extends CreatureCollectionNotifier {
  final List<Creature> initial;

  _TestCreatureCollectionNotifier(this.initial);

  @override
  List<Creature> build() => initial;

  @override
  Future<void> add(Creature creature) async {
    state = [...state, creature];
  }

  @override
  Future<void> remove(String id) async {
    state = state.where((creature) => creature.id != id).toList();
  }

  @override
  Future<void> addShardsToCreature(String id, int count) async {
    state = [
      for (final creature in state)
        if (creature.id == id)
          creature.copyWith(evolutionShards: creature.evolutionShards + count)
        else
          creature,
    ];
  }
}

class _TestDeckNotifier extends ActiveDeckNotifier {
  @override
  BattleDeck? build() => null;

  @override
  Future<void> save(BattleDeck deck) async {
    state = deck.copyWith(isActive: true);
  }

  @override
  Future<void> addCreature(String creatureId) async {
    final current =
        state ??
        BattleDeck(
          id: 'active-deck',
          name: 'Field Deck',
          creatureIds: const [],
          updatedAt: DateTime.utc(2026, 5, 10),
        );
    if (current.creatureIds.contains(creatureId) ||
        current.creatureIds.length >= BattleDeck.requiredCardCount) {
      return;
    }
    await save(
      current.copyWith(creatureIds: [...current.creatureIds, creatureId]),
    );
  }

  @override
  Future<void> removeCreature(String creatureId) async {
    final current = state;
    if (current == null) return;
    await save(
      current.copyWith(
        creatureIds: current.creatureIds
            .where((id) => id != creatureId)
            .toList(),
      ),
    );
  }

  @override
  Future<void> autoBuild(List<Creature> creatures) async {
    final sorted = [...creatures]
      ..sort((a, b) => b.totalPower.compareTo(a.totalPower));
    await save(
      BattleDeck(
        id: 'active-deck',
        name: 'Field Deck',
        creatureIds: sorted
            .take(BattleDeck.requiredCardCount)
            .map((creature) => creature.id)
            .toList(),
        updatedAt: DateTime.utc(2026, 5, 10),
      ),
    );
  }

  @override
  Future<void> repairAgainstCreatures(List<Creature> creatures) async {}
}

class _TestUserNotifier extends UserNotifier {
  final int totalCreatures;

  _TestUserNotifier(this.totalCreatures);

  @override
  UserModel build() {
    return UserModel(
      uid: 'guest',
      displayName: 'Field Researcher',
      email: '',
      level: 1,
      xp: 0,
      totalCreatures: totalCreatures,
      currentStreak: 0,
      longestStreak: 0,
      createdAt: DateTime.utc(2026, 5, 10),
    );
  }

  @override
  Future<void> update(UserModel user) async {
    state = user;
  }
}
