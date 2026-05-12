import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/battle_deck.dart';
import '../models/creature.dart';
import '../services/deck_storage.dart';
import '../services/sync_service.dart';

class ActiveDeckNotifier extends Notifier<BattleDeck?> {
  @override
  BattleDeck? build() {
    return ref.watch(deckStorageProvider).loadActive();
  }

  Future<void> save(BattleDeck deck) async {
    final next = deck.copyWith(updatedAt: DateTime.now(), isActive: true);
    state = next;
    await ref.read(deckStorageProvider).saveActive(next);
    await ref
        .read(syncServiceProvider)
        .enqueueUpsert(
          entityType: SyncEntityType.battleDeck,
          entityId: next.id,
          payload: next.toMap(),
        );
  }

  Future<void> addCreature(String creatureId) async {
    final current =
        state ??
        BattleDeck(
          id: 'active-deck',
          name: 'Field Deck',
          creatureIds: const [],
          updatedAt: DateTime.now(),
        );
    if (current.creatureIds.contains(creatureId) ||
        current.creatureIds.length >= BattleDeck.requiredCardCount) {
      return;
    }
    await save(
      current.copyWith(creatureIds: [...current.creatureIds, creatureId]),
    );
  }

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

  Future<void> repairAgainstCreatures(List<Creature> creatures) async {
    final current = state;
    if (current == null) return;
    final validIds = creatures.map((creature) => creature.id).toSet();
    final repaired = current.creatureIds
        .where((id) => validIds.contains(id))
        .toList();
    if (repaired.length == current.creatureIds.length) return;
    await save(current.copyWith(creatureIds: repaired));
  }

  Future<void> autoBuild(List<Creature> creatures) async {
    final selected = _autoBuildCreatures(creatures);
    await save(
      BattleDeck(
        id: 'active-deck',
        name: 'Field Deck',
        creatureIds: selected.map((creature) => creature.id).toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  List<Creature> _autoBuildCreatures(List<Creature> creatures) {
    final sorted = [...creatures]
      ..sort((a, b) => b.totalPower.compareTo(a.totalPower));
    final selected = <Creature>[];

    void addIfAvailable(bool Function(Creature creature) predicate) {
      if (selected.length >= BattleDeck.requiredCardCount) return;
      for (final creature in sorted) {
        if (selected.any((item) => item.id == creature.id)) continue;
        if (predicate(creature)) {
          selected.add(creature);
          return;
        }
      }
    }

    addIfAvailable((creature) => creature.type == 'Earth');
    addIfAvailable((creature) => creature.type == 'Water');

    final seenTypes = selected.map((creature) => creature.type).toSet();
    for (final creature in sorted) {
      if (selected.length >= 3) break;
      if (selected.any((item) => item.id == creature.id)) continue;
      if (!seenTypes.contains(creature.type)) {
        selected.add(creature);
        seenTypes.add(creature.type);
      }
    }

    for (final creature in sorted) {
      if (selected.length >= BattleDeck.requiredCardCount) break;
      if (selected.any((item) => item.id == creature.id)) continue;
      selected.add(creature);
    }

    return selected.take(BattleDeck.requiredCardCount).toList();
  }
}

final activeDeckProvider = NotifierProvider<ActiveDeckNotifier, BattleDeck?>(
  ActiveDeckNotifier.new,
);
