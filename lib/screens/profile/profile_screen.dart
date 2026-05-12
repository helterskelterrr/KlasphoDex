import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/creature.dart';
import '../../models/trial_result.dart';
import '../../providers/battle_provider.dart';
import '../../providers/creature_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/creature_lens_widgets.dart';
import '../../widgets/deckbuilder_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final creatures = ref.watch(allCreaturesProvider);
    final trialResults = ref.watch(trialResultsProvider);
    final activeDeck = ref.watch(activeDeckProvider);
    final byId = {for (final creature in creatures) creature.id: creature};
    final deckCreatures = activeDeck == null
        ? <Creature>[]
        : activeDeck.creatureIds
              .map((id) => byId[id])
              .whereType<Creature>()
              .toList();
    final rarest = _rarestCreature(creatures);

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.rewardGold,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 18,
                  20,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Profile',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    PressableScale(
                      onTap: () => context.pushNamed('settings'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface.withValues(alpha: 0.78),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: AppColors.pearl,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.all(18),
                  radius: 28,
                  borderColor: AppColors.rewardGold.withValues(alpha: 0.18),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.rewardGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.rewardGold.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 26,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.ink,
                              size: 48,
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.scannerCyan,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${user.level}',
                                style: const TextStyle(
                                  color: AppColors.voidBlack,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.pearl,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'AI Field Explorer',
                        style: TextStyle(
                          color: AppColors.pearlMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      XpProgressStrip(
                        level: user.level,
                        xp: user.xp,
                        xpToNext: user.xpToNextLevel,
                        progress: user.levelProgress,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: SectionHeader(
                  title: 'Lifetime Stats',
                  icon: Icons.query_stats_rounded,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ProfileStat(
                      label: 'Total Creatures',
                      value: '${user.totalCreatures}',
                      icon: Icons.auto_stories_rounded,
                      color: AppColors.scannerCyan,
                    ),
                    _ProfileStat(
                      label: 'Rarest Catch',
                      value: rarest?.rarity ?? 'None',
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.rewardGold,
                    ),
                    _ProfileStat(
                      label: 'Current Streak',
                      value: '${user.currentStreak} days',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.fire,
                    ),
                    _ProfileStat(
                      label: 'Longest Streak',
                      value: '${user.longestStreak} days',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.electric,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: _FieldTrialsProfileCard(
                  results: trialResults,
                  deckCreatures: deckCreatures,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: SectionHeader(
                  title: 'Achievements',
                  icon: Icons.military_tech_rounded,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.92,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _AchievementBadge(
                      title: 'First Scan',
                      icon: Icons.center_focus_strong_rounded,
                      color: AppColors.scannerCyan,
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      title: 'Rare Note',
                      icon: Icons.diamond_rounded,
                      color: AppColors.water,
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      title: '7 Day Flame',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.fire,
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      title: 'Nature Master',
                      icon: Icons.eco_rounded,
                      color: AppColors.nature,
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      title: 'Shard Smith',
                      icon: Icons.hexagon_rounded,
                      color: AppColors.rewardGold,
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      title: 'Legend Hunter',
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.shadow,
                      unlocked: false,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                child: PressableScale(
                  onTap: () => context.pushNamed('settings'),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.scannerCyan.withValues(alpha: 0.16),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.settings_rounded,
                          color: AppColors.scannerCyan,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              color: AppColors.pearl,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.pearlMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Creature? _rarestCreature(List<Creature> creatures) {
    if (creatures.isEmpty) return null;
    final sorted = [...creatures]
      ..sort((a, b) => rarityRank(b.rarity).compareTo(rarityRank(a.rarity)));
    return sorted.first;
  }
}

class _FieldTrialsProfileCard extends StatelessWidget {
  final List<TrialResult> results;
  final List<Creature> deckCreatures;

  const _FieldTrialsProfileCard({
    required this.results,
    required this.deckCreatures,
  });

  @override
  Widget build(BuildContext context) {
    final wins = results.where((result) => result.victory).length;
    final bestDifficulty = _bestDifficulty(results);

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.violet.withValues(alpha: 0.18),
      gradient: LinearGradient(
        colors: [
          AppColors.violet.withValues(alpha: 0.13),
          AppColors.surface.withValues(alpha: 0.78),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Field Trials', icon: Icons.style_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniProfileTrialStat(
                  label: 'Completed',
                  value: '${results.length}',
                  icon: Icons.flag_rounded,
                  color: AppColors.scannerCyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniProfileTrialStat(
                  label: 'Wins',
                  value: '$wins',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.rewardGold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniProfileTrialStat(
                  label: 'Best',
                  value: bestDifficulty,
                  icon: Icons.signal_cellular_alt_rounded,
                  color: AppColors.violet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Favorite deck type mix',
            style: TextStyle(
              color: AppColors.pearlMuted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          TypeMixStrip(creatures: deckCreatures),
        ],
      ),
    );
  }

  String _bestDifficulty(List<TrialResult> results) {
    final won = results.where((result) => result.victory).toList();
    if (won.isEmpty) return 'None';
    const rank = {'Calm': 1, 'Wild': 2, 'Mythic': 3};
    won.sort(
      (a, b) => (rank[b.difficulty] ?? 0).compareTo(rank[a.difficulty] ?? 0),
    );
    return won.first.difficulty;
  }
}

class _MiniProfileTrialStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniProfileTrialStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.pearlMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(13),
      radius: 18,
      color: AppColors.surface.withValues(alpha: 0.76),
      borderColor: color.withValues(alpha: 0.16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

class _AchievementBadge extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const _AchievementBadge({
    required this.title,
    required this.icon,
    required this.color,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final visibleColor = unlocked ? color : AppColors.textDim;
    return GlassPanel(
      padding: const EdgeInsets.all(10),
      radius: 18,
      color: AppColors.surface.withValues(alpha: unlocked ? 0.76 : 0.44),
      borderColor: visibleColor.withValues(alpha: unlocked ? 0.20 : 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: visibleColor.withValues(alpha: unlocked ? 0.14 : 0.08),
            ),
            child: Icon(icon, color: visibleColor, size: 22),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? AppColors.pearl : AppColors.pearlMuted,
              fontSize: 11,
              height: 1.14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
