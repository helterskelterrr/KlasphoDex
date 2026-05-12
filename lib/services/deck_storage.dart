import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/battle_deck.dart';

class DeckStorage {
  static const boxName = 'battle_decks';
  static const activeDeckKey = 'active';

  final Box<Map> _box;

  const DeckStorage(this._box);

  BattleDeck? loadActive() {
    final map = _box.get(activeDeckKey);
    if (map == null) return null;
    return BattleDeck.fromMap(Map<String, dynamic>.from(map));
  }

  Future<void> saveActive(BattleDeck deck) {
    return _box.put(
      activeDeckKey,
      deck.copyWith(isActive: true, updatedAt: DateTime.now()).toMap(),
    );
  }
}

final deckStorageProvider = Provider<DeckStorage>((ref) {
  return DeckStorage(Hive.box<Map>(DeckStorage.boxName));
});
