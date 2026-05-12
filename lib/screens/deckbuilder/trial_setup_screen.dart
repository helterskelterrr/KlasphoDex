import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/battle_deck.dart';
import '../../models/battle_state.dart';
import '../../models/creature.dart';
import '../../providers/battle_provider.dart';
import '../../providers/creature_provider.dart';
import '../../providers/deck_provider.dart';
import '../../services/battle_rules.dart';
import '../../widgets/creature_lens_widgets.dart';
import '../../widgets/deckbuilder_widgets.dart';

class TrialSetupScreen extends ConsumerStatefulWidget {
  const TrialSetupScreen({super.key});

  @override
  ConsumerState<TrialSetupScreen> createState() => _TrialSetupScreenState();
}

class _TrialSetupScreenState extends ConsumerState<TrialSetupScreen> {
  TrialDifficulty _difficulty = TrialDifficulty.calm;

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(activeDeckProvider);
    final creatures = ref.watch(allCreaturesProvider);
    final config = BattleRules.configFor(_difficulty);
    final byId = {for (final creature in creatures) creature.id: creature};
    final deckCreatures = deck == null
        ? <Creature>[]
        : deck.creatureIds.map((id) => byId[id]).whereType<Creature>().toList();
    final deckPower = BattleRules.averageDeckPower(
      deck: deck,
      creatures: creatures,
    );
    final valid = deck?.isValid == true;

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.rewardGold,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.pearl,
                    ),
                    Expanded(
                      child: Text(
                        'Trial Setup',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.all(18),
                        radius: 28,
                        borderColor: AppColors.violet.withValues(alpha: 0.24),
                        child: Column(
                          children: [
                            const LensMark(size: 104, progress: 0.9),
                            const SizedBox(height: 16),
                            const Text(
                              'Scanner Anomaly',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.pearl,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Stabilize the signal with an 8-creature research deck.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.pearlMuted,
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Difficulty',
                              icon: Icons.signal_cellular_alt_rounded,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: TrialDifficulty.values.map((
                                difficulty,
                              ) {
                                final selected = _difficulty == difficulty;
                                final itemConfig = BattleRules.configFor(
                                  difficulty,
                                );
                                return FilterPill(
                                  label:
                                      '${itemConfig.label} ${itemConfig.anomalyHp}HP',
                                  selected: selected,
                                  color: difficulty == TrialDifficulty.mythic
                                      ? AppColors.rewardGold
                                      : difficulty == TrialDifficulty.wild
                                      ? AppColors.fire
                                      : AppColors.scannerCyan,
                                  icon: Icons.auto_awesome_rounded,
                                  onTap: () =>
                                      setState(() => _difficulty = difficulty),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassPanel(
                        padding: const EdgeInsets.all(16),
                        borderColor: AppColors.rewardGold.withValues(
                          alpha: 0.18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Signal Forecast',
                              icon: Icons.insights_rounded,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TrialStatChip(
                                  icon: Icons.favorite_rounded,
                                  label: 'Anomaly HP',
                                  value: '${config.anomalyHp}',
                                  color: AppColors.fire,
                                ),
                                TrialStatChip(
                                  icon: Icons.flash_on_rounded,
                                  label: 'Attack',
                                  value: '${config.anomalyAttack}',
                                  color: AppColors.rewardGold,
                                ),
                                TrialStatChip(
                                  icon: Icons.query_stats_rounded,
                                  label: 'Rec PWR',
                                  value: '${config.recommendedPower}',
                                  color: AppColors.scannerCyan,
                                ),
                                TrialStatChip(
                                  icon: Icons.hexagon_rounded,
                                  label: 'Shards',
                                  value: '${config.shardReward} shard',
                                  color: AppColors.violet,
                                ),
                                TrialStatChip(
                                  icon: Icons.bolt_rounded,
                                  label: 'XP',
                                  value: '+${config.xpReward}',
                                  color: AppColors.rewardGold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              deckPower >= config.recommendedPower
                                  ? 'Deck power is above the recommended signal threshold.'
                                  : 'Average deck power is below recommended. Earth and Water cards can help survival.',
                              style: TextStyle(
                                color: deckPower >= config.recommendedPower
                                    ? AppColors.nature
                                    : AppColors.rewardGold,
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassPanel(
                        padding: const EdgeInsets.all(16),
                        borderColor: AppColors.scannerCyan.withValues(
                          alpha: 0.16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Your Deck',
                              icon: Icons.style_rounded,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TacticalStatCell(
                                    label: 'CARDS',
                                    value:
                                        '${deckCreatures.length}/${BattleDeck.requiredCardCount}',
                                    icon: Icons.style_rounded,
                                    color: valid
                                        ? AppColors.nature
                                        : AppColors.rewardGold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TacticalStatCell(
                                    label: 'AVG PWR',
                                    value: '$deckPower',
                                    icon: Icons.query_stats_rounded,
                                    color: deckPower >= config.recommendedPower
                                        ? AppColors.nature
                                        : AppColors.rewardGold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TypeMixStrip(creatures: deckCreatures),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppActionButton(
                        label: 'Edit Deck',
                        icon: Icons.style_rounded,
                        variant: AppActionVariant.ghost,
                        compact: true,
                        onPressed: () => context.pushNamed('fieldDeck'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppActionButton(
                        label: 'Start Trial',
                        icon: Icons.play_arrow_rounded,
                        variant: AppActionVariant.reward,
                        compact: true,
                        onPressed: valid
                            ? () {
                                ref
                                    .read(currentBattleProvider.notifier)
                                    .startTrial(
                                      deck: deck!,
                                      creatures: creatures,
                                      difficulty: _difficulty,
                                    );
                                context.pushNamed('fieldBattle');
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
