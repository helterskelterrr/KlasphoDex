import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/trial_result.dart';
import '../../providers/battle_provider.dart';
import '../../providers/creature_provider.dart';
import '../../widgets/creature_lens_widgets.dart';

class TrialResultScreen extends ConsumerWidget {
  final TrialResult? result;

  const TrialResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest =
        result ??
        (ref.watch(trialResultsProvider).isEmpty
            ? null
            : ref.watch(trialResultsProvider).first);
    final victory = latest?.victory ?? false;
    final color = victory ? AppColors.rewardGold : AppColors.fire;
    final creatures = ref.watch(allCreaturesProvider);
    final shardRecipientId = latest?.shardCreatureId;
    final shardRecipient = shardRecipientId == null
        ? null
        : creatures
              .where((creature) => creature.id == shardRecipientId)
              .firstOrNull;

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: color,
        glowAlignment: Alignment.center,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              children: [
                const Spacer(),
                GlassPanel(
                  padding: const EdgeInsets.all(24),
                  radius: 30,
                  borderColor: color.withValues(alpha: 0.32),
                  child: Column(
                    children: [
                      LensMark(size: 112, progress: victory ? 1 : 0.46),
                      const SizedBox(height: 18),
                      Text(
                        victory ? 'Anomaly Stabilized' : 'Signal Lost',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color,
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        victory
                            ? 'Field data secured.'
                            : 'The anomaly slipped beyond scanner range.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.pearlMuted,
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (latest != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _RewardChip(
                              icon: Icons.bolt_rounded,
                              label: '+${latest.xpGained} XP',
                              color: AppColors.rewardGold,
                            ),
                            _RewardChip(
                              icon: Icons.hexagon_rounded,
                              label: '+${latest.shardsGained} Shards',
                              color: AppColors.violet,
                            ),
                            _RewardChip(
                              icon: Icons.hourglass_top_rounded,
                              label: '${latest.turnsTaken} Turns',
                              color: AppColors.scannerCyan,
                            ),
                          ],
                        ),
                      if (victory &&
                          latest != null &&
                          shardRecipient != null &&
                          latest.shardsGained > 0) ...[
                        const SizedBox(height: 14),
                        _ShardRecipientCard(
                          name: shardRecipient.name,
                          type: shardRecipient.type,
                          rarity: shardRecipient.rarity,
                          shards: latest.shardsGained,
                        ),
                      ],
                      if (!victory) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Try more Earth cards for shield, or add higher-power Fire and Electric cards for faster stabilization.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.rewardGold,
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                AppActionButton(
                  label: 'Run Another Trial',
                  icon: Icons.replay_rounded,
                  variant: AppActionVariant.reward,
                  onPressed: () => context.goNamed('fieldSetup'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppActionButton(
                        label: 'Edit Deck',
                        icon: Icons.style_rounded,
                        variant: AppActionVariant.ghost,
                        compact: true,
                        onPressed: () => context.goNamed('fieldDeck'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppActionButton(
                        label: 'Home',
                        icon: Icons.home_rounded,
                        variant: AppActionVariant.ghost,
                        compact: true,
                        onPressed: () => context.goNamed('home'),
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

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShardRecipientCard extends StatelessWidget {
  final String name;
  final String type;
  final String rarity;
  final int shards;

  const _ShardRecipientCard({
    required this.name,
    required this.type,
    required this.rarity,
    required this.shards,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getTypeColor(type);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          CreaturePortrait(type: type, rarity: rarity, size: 54, compact: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SHARDS APPLIED TO',
                  style: TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.pearl,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '+$shards Evolution Shards',
                  style: const TextStyle(
                    color: AppColors.rewardGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.rewardGold,
            size: 18,
          ),
        ],
      ),
    );
  }
}
