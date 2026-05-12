import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/battle_state.dart';
import '../../providers/battle_provider.dart';
import '../../providers/creature_provider.dart';
import '../../widgets/creature_lens_widgets.dart';
import '../../widgets/deckbuilder_widgets.dart';

class BattleScreen extends ConsumerWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentBattleProvider);
    final creatures = ref.watch(allCreaturesProvider);
    final byId = {for (final creature in creatures) creature.id: creature};
    final compactHeight = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.fire,
        glowAlignment: Alignment.topCenter,
        child: SafeArea(
          child: state == null
              ? _MissingBattle()
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    compactHeight ? 12 : 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.pearl,
                          ),
                          Expanded(
                            child: Text(
                              'Field Trial',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TrialStatChip(
                            icon: Icons.hourglass_top_rounded,
                            label: 'Turn',
                            value: '${state.turn}/7',
                            color: AppColors.rewardGold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GlassPanel(
                        padding: const EdgeInsets.all(16),
                        radius: 24,
                        borderColor: AppColors.fire.withValues(alpha: 0.24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Scanner Anomaly',
                                    style: TextStyle(
                                      color: AppColors.pearl,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.voidBlack.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.violet.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    difficultyLabel(state.difficulty),
                                    style: const TextStyle(
                                      color: AppColors.violet,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _Bar(
                              label: 'HP',
                              value: state.anomalyHp,
                              max: state.anomalyMaxHp,
                              color: AppColors.fire,
                            ),
                            const SizedBox(height: 12),
                            _IntentStrip(intent: state.anomalyIntent),
                            if (state.anomalyShield > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Shield ${state.anomalyShield}',
                                  style: const TextStyle(
                                    color: AppColors.scannerCyan,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: compactHeight ? 8 : 12),
                      GlassPanel(
                        padding: EdgeInsets.all(compactHeight ? 10 : 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: _Bar(
                                label: 'Resolve',
                                value: state.playerResolve,
                                max: 20,
                                color: AppColors.nature,
                              ),
                            ),
                            const SizedBox(width: 12),
                            TrialStatChip(
                              icon: Icons.bolt_rounded,
                              label: 'Focus',
                              value: '${state.focus}',
                              color: AppColors.scannerCyan,
                            ),
                            if (state.playerShield > 0) ...[
                              const SizedBox(width: 8),
                              TrialStatChip(
                                icon: Icons.shield_rounded,
                                label: 'Shield',
                                value: '${state.playerShield}',
                                color: AppColors.water,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: compactHeight ? 8 : 12),
                      Expanded(
                        child: GlassPanel(
                          padding: EdgeInsets.all(compactHeight ? 10 : 14),
                          color: AppColors.surface.withValues(alpha: 0.62),
                          child: ListView(
                            reverse: true,
                            physics: const BouncingScrollPhysics(),
                            children: state.battleLog.reversed
                                .take(12)
                                .map(
                                  (line) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      line,
                                      style: const TextStyle(
                                        color: AppColors.pearlMuted,
                                        fontSize: 12,
                                        height: 1.3,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: compactHeight ? 8 : 12),
                      if (state.isFinished)
                        AppActionButton(
                          label: 'View Result',
                          icon: Icons.emoji_events_rounded,
                          variant: state.victory
                              ? AppActionVariant.reward
                              : AppActionVariant.danger,
                          onPressed: () async {
                            final result = await ref
                                .read(currentBattleProvider.notifier)
                                .completeBattle();
                            if (context.mounted) {
                              context.goNamed('fieldResult', extra: result);
                            }
                          },
                        )
                      else ...[
                        SizedBox(
                          height: compactHeight ? 148 : 182,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.hand.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final creature = byId[state.hand[index]];
                              if (creature == null) {
                                return const SizedBox.shrink();
                              }
                              return BattleHandCard(
                                creature: creature,
                                focus: state.focus,
                                onTap: () => ref
                                    .read(currentBattleProvider.notifier)
                                    .playCreature(creature),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: compactHeight ? 8 : 10),
                        AppActionButton(
                          label: 'End Turn',
                          icon: Icons.keyboard_double_arrow_right_rounded,
                          variant: AppActionVariant.ghost,
                          onPressed: () => ref
                              .read(currentBattleProvider.notifier)
                              .endTurn(),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _IntentStrip extends StatelessWidget {
  final AnomalyIntent intent;

  const _IntentStrip({required this.intent});

  @override
  Widget build(BuildContext context) {
    final color = switch (intent) {
      AnomalyIntent.attack => AppColors.fire,
      AnomalyIntent.guard => AppColors.water,
      AnomalyIntent.distort => AppColors.rewardGold,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.voidBlack.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'NEXT INTENT',
              style: TextStyle(
                color: AppColors.pearlMuted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.32)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(intentIcon(intent), color: color, size: 15),
                const SizedBox(width: 6),
                Text(
                  intentLabel(intent),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingBattle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassPanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LensMark(size: 80, progress: 0.4),
              const SizedBox(height: 16),
              Text(
                'No active trial signal.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppActionButton(
                label: 'Return to Setup',
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.goNamed('fieldSetup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _Bar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.pearlMuted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              '$value/$max',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: max == 0 ? 0 : (value / max).clamp(0, 1),
            minHeight: 9,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
