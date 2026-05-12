import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/creature.dart';
import '../services/creature_storage.dart';
import '../services/sync_service.dart';

class CreatureCollectionNotifier extends Notifier<List<Creature>> {
  @override
  List<Creature> build() {
    return ref.watch(creatureStorageProvider).loadAll();
  }

  Future<void> add(Creature creature) async {
    final storage = ref.read(creatureStorageProvider);
    final duplicateIndex = state.indexWhere(
      (item) => item.name == creature.name && item.type == creature.type,
    );
    if (duplicateIndex == -1) {
      state = [...state, creature];
      await storage.save(creature);
      await ref
          .read(syncServiceProvider)
          .enqueueUpsert(
            entityType: SyncEntityType.creature,
            entityId: creature.id,
            payload: creature.toMap(),
          );
      return;
    }

    final next = [...state];
    next[duplicateIndex] = next[duplicateIndex].copyWith(
      evolutionShards: next[duplicateIndex].evolutionShards + 3,
      discoveredAt: DateTime.now(),
    );
    state = next;
    await storage.replaceAll(next);
    await ref
        .read(syncServiceProvider)
        .enqueueUpsert(
          entityType: SyncEntityType.creature,
          entityId: next[duplicateIndex].id,
          payload: next[duplicateIndex].toMap(),
        );
  }

  Future<void> remove(String id) async {
    state = state.where((creature) => creature.id != id).toList();
    await ref.read(creatureStorageProvider).remove(id);
    await ref
        .read(syncServiceProvider)
        .enqueueDelete(entityType: SyncEntityType.creature, entityId: id);
  }

  Future<void> addShardsToCreature(String id, int count) async {
    if (count <= 0) return;
    final index = state.indexWhere((creature) => creature.id == id);
    if (index == -1) return;

    final next = [...state];
    next[index] = next[index].copyWith(
      evolutionShards: next[index].evolutionShards + count,
    );
    state = next;
    await ref.read(creatureStorageProvider).replaceAll(next);
    await ref
        .read(syncServiceProvider)
        .enqueueUpsert(
          entityType: SyncEntityType.creature,
          entityId: next[index].id,
          payload: next[index].toMap(),
        );
  }
}

final allCreaturesProvider =
    NotifierProvider<CreatureCollectionNotifier, List<Creature>>(
      CreatureCollectionNotifier.new,
    );

final recentCreaturesProvider = Provider<List<Creature>>((ref) {
  final all = ref.watch(allCreaturesProvider);
  final sorted = List<Creature>.from(all)
    ..sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
  return sorted.take(5).toList();
});
