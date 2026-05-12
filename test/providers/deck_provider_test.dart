import 'dart:io';

import 'package:creature_lens/models/battle_deck.dart';
import 'package:creature_lens/models/creature.dart';
import 'package:creature_lens/providers/deck_provider.dart';
import 'package:creature_lens/services/deck_storage.dart';
import 'package:creature_lens/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<Map> box;
  late Box<Map> syncBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('deck_provider_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>(DeckStorage.boxName);
    syncBox = await Hive.openBox<Map>(SyncService.queueBoxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('saves one active deck and repairs deleted creature ids', () async {
    final storage = DeckStorage(box);
    final syncService = SyncService(syncBox);
    final container = ProviderContainer(
      overrides: [
        deckStorageProvider.overrideWithValue(storage),
        syncServiceProvider.overrideWithValue(syncService),
      ],
    );
    addTearDown(container.dispose);

    final deck = BattleDeck(
      id: 'deck-1',
      name: 'Field Deck',
      creatureIds: const ['c1', 'c2', 'deleted'],
      updatedAt: DateTime.utc(2026, 5, 9),
    );

    await container.read(activeDeckProvider.notifier).save(deck);
    expect(container.read(activeDeckProvider)!.creatureIds, const [
      'c1',
      'c2',
      'deleted',
    ]);
    expect(
      syncService.loadPending().single.entityType,
      SyncEntityType.battleDeck,
    );
    expect(syncService.loadPending().single.operation, SyncOperation.upsert);

    await container.read(activeDeckProvider.notifier).repairAgainstCreatures([
      _creature('c1', power: 50),
      _creature('c2', power: 60),
    ]);

    expect(container.read(activeDeckProvider)!.creatureIds, const ['c1', 'c2']);
    expect(storage.loadActive()!.creatureIds, const ['c1', 'c2']);
    expect(syncService.loadPending().single.payload['creatureIds'], const [
      'c1',
      'c2',
    ]);
  });

  test(
    'auto build chooses eight high-power creatures with type variety',
    () async {
      final storage = DeckStorage(box);
      final syncService = SyncService(syncBox);
      final container = ProviderContainer(
        overrides: [
          deckStorageProvider.overrideWithValue(storage),
          syncServiceProvider.overrideWithValue(syncService),
        ],
      );
      addTearDown(container.dispose);

      final creatures = [
        _creature('weak-nature', type: 'Nature', power: 30),
        _creature('earth-a', type: 'Earth', power: 68),
        _creature('water-a', type: 'Water', power: 65),
        _creature('fire-a', type: 'Fire', power: 90),
        _creature('fire-b', type: 'Fire', power: 88),
        _creature('fire-c', type: 'Fire', power: 86),
        _creature('light-a', type: 'Light', power: 84),
        _creature('shadow-a', type: 'Shadow', power: 82),
        _creature('electric-a', type: 'Electric', power: 80),
        _creature('air-a', type: 'Air', power: 78),
      ];

      await container.read(activeDeckProvider.notifier).autoBuild(creatures);

      final deck = container.read(activeDeckProvider)!;
      expect(deck.creatureIds, hasLength(8));
      expect(deck.creatureIds, contains('earth-a'));
      expect(deck.creatureIds, contains('water-a'));
      expect(deck.creatureIds, isNot(contains('weak-nature')));
      expect(deck.isValid, isTrue);
      expect(syncService.loadPending().single.entityId, 'active-deck');
    },
  );
}

Creature _creature(String id, {String type = 'Nature', required int power}) {
  return Creature(
    id: id,
    userId: 'guest',
    name: id,
    type: type,
    rarity: power >= 80 ? 'Epic' : 'Common',
    hp: power,
    attack: power,
    defense: power,
    speed: power,
    abilities: const [],
    lore: 'Test creature',
    scannedObject: 'test object',
    discoveredAt: DateTime.utc(2026, 5, 9),
  );
}
