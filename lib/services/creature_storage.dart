import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/creature.dart';

class CreatureStorage {
  static const boxName = 'creatures';

  final Box<Map> _box;

  const CreatureStorage(this._box);

  List<Creature> loadAll() {
    return _box.values
        .map((value) => Creature.fromMap(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<void> save(Creature creature) {
    return _box.put(creature.id, creature.toMap());
  }

  Future<void> replaceAll(List<Creature> creatures) async {
    await _box.clear();
    for (final creature in creatures) {
      await save(creature);
    }
  }

  Future<void> remove(String id) {
    return _box.delete(id);
  }
}

final creatureStorageProvider = Provider<CreatureStorage>((ref) {
  return CreatureStorage(Hive.box<Map>(CreatureStorage.boxName));
});
