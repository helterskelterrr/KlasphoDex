import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/battle_deck.dart';
import '../models/battle_state.dart';
import '../models/creature.dart';
import '../models/trial_result.dart';
import '../services/battle_rules.dart';
import '../services/sync_service.dart';
import '../services/trial_result_storage.dart';
import 'creature_provider.dart';
import 'user_provider.dart';

class TrialResultsNotifier extends Notifier<List<TrialResult>> {
  @override
  List<TrialResult> build() {
    return ref.watch(trialResultStorageProvider).loadAll();
  }

  Future<void> add(TrialResult result) async {
    state = [result, ...state];
    await ref.read(trialResultStorageProvider).save(result);
    await ref
        .read(syncServiceProvider)
        .enqueueUpsert(
          entityType: SyncEntityType.trialResult,
          entityId: result.id,
          payload: result.toMap(),
        );
  }
}

final trialResultsProvider =
    NotifierProvider<TrialResultsNotifier, List<TrialResult>>(
      TrialResultsNotifier.new,
    );

class BattleNotifier extends Notifier<BattleState?> {
  BattleDeck? _deck;
  List<Creature> _creatures = const [];
  TrialResult? _completedResult;

  @override
  BattleState? build() {
    return null;
  }

  void startTrial({
    required BattleDeck deck,
    required List<Creature> creatures,
    TrialDifficulty difficulty = TrialDifficulty.calm,
  }) {
    _deck = deck;
    _creatures = creatures;
    _completedResult = null;
    state = BattleRules.createInitialState(
      deck: deck,
      creatures: creatures,
      difficulty: difficulty,
    );
  }

  void playCreature(Creature creature) {
    final current = state;
    if (current == null) return;
    state = BattleRules.playCard(
      state: current,
      card: BattleRules.cardFromCreature(creature),
    );
  }

  void endTurn() {
    final current = state;
    if (current == null) return;
    state = BattleRules.endTurn(current);
  }

  Future<TrialResult?> completeBattle() async {
    final current = state;
    final deck = _deck;
    if (current == null || deck == null || !current.isFinished) return null;
    if (_completedResult != null) return _completedResult;

    final config = BattleRules.configFor(current.difficulty);
    final shardCreatureId = current.victory
        ? BattleRules.mvpCreatureId(current) ??
              (deck.creatureIds.isNotEmpty ? deck.creatureIds.first : null)
        : null;
    final result = TrialResult(
      deckId: deck.id,
      difficulty: config.label,
      victory: current.victory,
      turnsTaken: current.turn,
      xpGained: current.victory ? config.xpReward : 5,
      shardCreatureId: shardCreatureId,
      shardsGained: current.victory ? config.shardReward : 0,
    );

    await ref.read(userProvider.notifier).addXp(result.xpGained);
    if (result.shardCreatureId != null && result.shardsGained > 0) {
      await ref
          .read(allCreaturesProvider.notifier)
          .addShardsToCreature(result.shardCreatureId!, result.shardsGained);
    }
    await ref.read(trialResultsProvider.notifier).add(result);
    _completedResult = result;
    return result;
  }

  Creature? creatureForId(String id) {
    for (final creature in _creatures) {
      if (creature.id == id) return creature;
    }
    return null;
  }
}

final currentBattleProvider = NotifierProvider<BattleNotifier, BattleState?>(
  BattleNotifier.new,
);
