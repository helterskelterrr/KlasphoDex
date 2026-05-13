import 'dart:io';

import 'package:creature_lens/models/battle_deck.dart';
import 'package:creature_lens/models/battle_state.dart';
import 'package:creature_lens/models/creature.dart';
import 'package:creature_lens/models/user_model.dart';
import 'package:creature_lens/providers/battle_provider.dart';
import 'package:creature_lens/providers/creature_provider.dart';
import 'package:creature_lens/providers/user_provider.dart';
import 'package:creature_lens/services/creature_storage.dart';
import 'package:creature_lens/services/sync_service.dart';
import 'package:creature_lens/services/trial_result_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<Map> creatureBox;
  late Box<Map> resultBox;
  late Box<Map> syncBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('battle_provider_test_');
    Hive.init(tempDir.path);
    creatureBox = await Hive.openBox<Map>(CreatureStorage.boxName);
    resultBox = await Hive.openBox<Map>(TrialResultStorage.boxName);
    syncBox = await Hive.openBox<Map>(SyncService.queueBoxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'still completes a victory result when user reward persistence fails',
    () async {
      final creatures = _deckCreatures();
      final syncService = SyncService(syncBox);
      final container = ProviderContainer(
        overrides: [
          initialUserProvider.overrideWithValue(_user()),
          userRepositoryProvider.overrideWithValue(_FailingUserRepository()),
          creatureStorageProvider.overrideWithValue(
            CreatureStorage(creatureBox),
          ),
          trialResultStorageProvider.overrideWithValue(
            TrialResultStorage(resultBox),
          ),
          syncServiceProvider.overrideWithValue(syncService),
        ],
      );
      addTearDown(container.dispose);

      for (final creature in creatures) {
        await container.read(allCreaturesProvider.notifier).add(creature);
      }

      final deck = BattleDeck(
        id: 'deck-1',
        name: 'Field Deck',
        creatureIds: creatures.map((creature) => creature.id).toList(),
        updatedAt: DateTime.utc(2026, 5, 9),
      );

      container
          .read(currentBattleProvider.notifier)
          .startTrial(
            deck: deck,
            creatures: creatures,
            difficulty: TrialDifficulty.calm,
          );
      container.read(currentBattleProvider.notifier).playCreature(creatures[0]);
      container.read(currentBattleProvider.notifier).playCreature(creatures[1]);
      container.read(currentBattleProvider.notifier).playCreature(creatures[2]);

      final result = await container
          .read(currentBattleProvider.notifier)
          .completeBattle();

      expect(result, isNotNull);
      expect(result!.victory, isTrue);
      expect(container.read(trialResultsProvider), hasLength(1));
    },
  );

  test('records victory rewards as XP, shards, and a trial result', () async {
    final creatures = _deckCreatures();
    final syncService = SyncService(syncBox);
    final container = ProviderContainer(
      overrides: [
        initialUserProvider.overrideWithValue(_user()),
        userRepositoryProvider.overrideWithValue(_RecordingUserRepository()),
        creatureStorageProvider.overrideWithValue(CreatureStorage(creatureBox)),
        trialResultStorageProvider.overrideWithValue(
          TrialResultStorage(resultBox),
        ),
        syncServiceProvider.overrideWithValue(syncService),
      ],
    );
    addTearDown(container.dispose);

    for (final creature in creatures) {
      await container.read(allCreaturesProvider.notifier).add(creature);
    }

    final deck = BattleDeck(
      id: 'deck-1',
      name: 'Field Deck',
      creatureIds: creatures.map((creature) => creature.id).toList(),
      updatedAt: DateTime.utc(2026, 5, 9),
    );

    container
        .read(currentBattleProvider.notifier)
        .startTrial(
          deck: deck,
          creatures: creatures,
          difficulty: TrialDifficulty.calm,
        );
    container.read(currentBattleProvider.notifier).playCreature(creatures[0]);
    container.read(currentBattleProvider.notifier).playCreature(creatures[1]);
    container.read(currentBattleProvider.notifier).playCreature(creatures[2]);

    expect(container.read(currentBattleProvider)!.isFinished, isTrue);
    expect(container.read(currentBattleProvider)!.victory, isTrue);

    final result = await container
        .read(currentBattleProvider.notifier)
        .completeBattle();

    expect(result!.victory, isTrue);
    expect(result.xpGained, 20);
    expect(result.shardsGained, 1);
    expect(result.shardCreatureId, 'c1');
    expect(container.read(userProvider).xp, 640);
    expect(container.read(trialResultsProvider), hasLength(1));
    expect(
      container
          .read(allCreaturesProvider)
          .firstWhere((creature) => creature.id == 'c1')
          .evolutionShards,
      1,
    );
    expect(
      syncService.loadPending().any(
        (item) =>
            item.entityType == SyncEntityType.trialResult &&
            item.operation == SyncOperation.upsert &&
            item.entityId == result.id,
      ),
      isTrue,
    );
  });

  test('applies victory shards to the battle MVP creature', () async {
    final creatures = [
      _creatureForMvp(
        id: 'support',
        type: 'Water',
        rarity: 'Common',
        attack: 30,
      ),
      _creatureForMvp(id: 'striker', type: 'Fire', rarity: 'Rare', attack: 100),
      _creatureForMvp(
        id: 'finisher',
        type: 'Fire',
        rarity: 'Common',
        attack: 100,
      ),
      _creatureForMvp(id: 'c4', type: 'Nature', rarity: 'Common', attack: 40),
      _creatureForMvp(id: 'c5', type: 'Air', rarity: 'Common', attack: 40),
      _creatureForMvp(id: 'c6', type: 'Electric', rarity: 'Common', attack: 40),
      _creatureForMvp(id: 'c7', type: 'Shadow', rarity: 'Common', attack: 40),
      _creatureForMvp(id: 'c8', type: 'Light', rarity: 'Common', attack: 40),
    ];
    final syncService = SyncService(syncBox);
    final container = ProviderContainer(
      overrides: [
        initialUserProvider.overrideWithValue(_user()),
        userRepositoryProvider.overrideWithValue(_RecordingUserRepository()),
        creatureStorageProvider.overrideWithValue(CreatureStorage(creatureBox)),
        trialResultStorageProvider.overrideWithValue(
          TrialResultStorage(resultBox),
        ),
        syncServiceProvider.overrideWithValue(syncService),
      ],
    );
    addTearDown(container.dispose);

    for (final creature in creatures) {
      await container.read(allCreaturesProvider.notifier).add(creature);
    }

    final deck = BattleDeck(
      id: 'deck-1',
      name: 'Field Deck',
      creatureIds: creatures.map((creature) => creature.id).toList(),
      updatedAt: DateTime.utc(2026, 5, 12),
    );

    container
        .read(currentBattleProvider.notifier)
        .startTrial(
          deck: deck,
          creatures: creatures,
          difficulty: TrialDifficulty.calm,
        );
    container.read(currentBattleProvider.notifier).playCreature(creatures[1]);
    container.read(currentBattleProvider.notifier).playCreature(creatures[2]);
    container.read(currentBattleProvider.notifier).endTurn();

    expect(container.read(currentBattleProvider)!.isFinished, isTrue);

    final result = await container
        .read(currentBattleProvider.notifier)
        .completeBattle();

    expect(result!.shardCreatureId, 'striker');
    expect(
      container
          .read(allCreaturesProvider)
          .firstWhere((creature) => creature.id == 'striker')
          .evolutionShards,
      1,
    );
    expect(
      container
          .read(allCreaturesProvider)
          .firstWhere((creature) => creature.id == 'support')
          .evolutionShards,
      0,
    );
    expect(
      syncService.loadPending().any(
        (item) =>
            item.entityType == SyncEntityType.creature &&
            item.operation == SyncOperation.upsert &&
            item.entityId == 'striker' &&
            item.payload['evolutionShards'] == 1,
      ),
      isTrue,
    );
  });
}

UserModel _user() {
  return UserModel(
    uid: 'guest',
    displayName: 'Field Researcher',
    email: '',
    level: 8,
    xp: 620,
    totalCreatures: 42,
    currentStreak: 9,
    longestStreak: 21,
    createdAt: DateTime.utc(2026, 5, 12),
  );
}

class _RecordingUserRepository implements UserRepository {
  @override
  Future<UserModel> loadOrCreateUser(String uid) async => _user();

  @override
  Future<void> saveUser(UserModel user) async {}
}

class _FailingUserRepository implements UserRepository {
  @override
  Future<UserModel> loadOrCreateUser(String uid) async => _user();

  @override
  Future<void> saveUser(UserModel user) async {
    throw StateError('User reward persistence failed.');
  }
}

List<Creature> _deckCreatures() {
  return List.generate(8, (index) {
    return Creature(
      id: 'c${index + 1}',
      userId: 'guest',
      name: 'Trial Creature ${index + 1}',
      type: 'Fire',
      rarity: 'Common',
      hp: 20,
      attack: 100,
      defense: 20,
      speed: 20,
      abilities: const [],
      lore: 'A focused test creature.',
      scannedObject: 'test object',
      scannedLabels: const ['test 99%'],
      discoveredAt: DateTime.utc(2026, 5, 9),
    );
  });
}

Creature _creatureForMvp({
  required String id,
  required String type,
  required String rarity,
  required int attack,
}) {
  return Creature(
    id: id,
    userId: 'guest',
    name: id,
    type: type,
    rarity: rarity,
    hp: 70,
    attack: attack,
    defense: 55,
    speed: 55,
    abilities: const [],
    lore: 'A test creature.',
    scannedObject: 'test object',
    scannedLabels: const ['test 99%'],
    discoveredAt: DateTime.utc(2026, 5, 12),
  );
}
