import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/creature.dart';
import '../../providers/creature_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/battle_rules.dart';
import '../../widgets/creature_lens_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final recentCreatures = ref.watch(recentCreaturesProvider);
    final allCreatures = ref.watch(allCreaturesProvider);
    final activeDeck = ref.watch(activeDeckProvider);
    final rarest = _rarestCreature(allCreatures);

    return Scaffold(
      body: CreatureLensBackground(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.rewardGradient,
                            border: Border.all(
                              color: AppColors.pearl.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.ink,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${user.displayName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'The field journal is humming.',
                                style: TextStyle(
                                  color: AppColors.pearlMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StreakFlame(count: user.currentStreak),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GlassPanel(
                      padding: const EdgeInsets.all(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surfaceHigh.withValues(alpha: 0.92),
                          AppColors.surface.withValues(alpha: 0.82),
                        ],
                      ),
                      child: Stack(
                        children: [
                          XpProgressStrip(
                            level: user.level,
                            xp: user.xp,
                            xpToNext: user.xpToNextLevel,
                            progress: user.levelProgress,
                          ),
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: _XpGainBadge(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: AppActionButton(
                  label: 'Scan Creature',
                  icon: Icons.center_focus_strong_rounded,
                  onPressed: () => context.pushNamed('scan'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: _DailyMissionsCard(creatures: allCreatures),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: _FieldTrialsCard(
                  creatureCount: allCreatures.length,
                  deckReady: activeDeck?.isValid == true,
                  deckCount: activeDeck?.creatureIds.length ?? 0,
                  averagePower: BattleRules.averageDeckPower(
                    deck: activeDeck,
                    creatures: allCreatures,
                  ),
                  onPrimary: () {
                    if (allCreatures.length < 5) {
                      context.pushNamed('scan');
                      return;
                    }
                    if (activeDeck?.isValid == true) {
                      context.pushNamed('fieldSetup');
                    } else {
                      context.pushNamed('fieldDeck');
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: SectionHeader(
                  title: 'Recent Discovery',
                  actionLabel: 'View all',
                  onAction: () => context.goNamed('pokedex'),
                  icon: Icons.auto_stories_rounded,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: recentCreatures.isEmpty
                    ? const _EmptyDiscovery()
                    : _FeaturedDiscovery(
                        creature: recentCreatures.first,
                        onTap: () => context.pushNamed(
                          'creatureDetail',
                          pathParameters: {'id': recentCreatures.first.id},
                          extra: recentCreatures.first,
                        ),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: SectionHeader(
                  title: 'Stats Summary',
                  icon: Icons.query_stats_rounded,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: 'Creatures',
                        value: '${user.totalCreatures}',
                        icon: Icons.auto_stories_rounded,
                        color: AppColors.scannerCyan,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryTile(
                        label: 'Rarest',
                        value: rarest?.rarity ?? 'None',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.rewardGold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryTile(
                        label: 'Longest',
                        value: '${user.longestStreak}d',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.fire,
                      ),
                    ),
                  ],
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

class _FieldTrialsCard extends StatelessWidget {
  final int creatureCount;
  final bool deckReady;
  final int deckCount;
  final int averagePower;
  final VoidCallback onPrimary;

  const _FieldTrialsCard({
    required this.creatureCount,
    required this.deckReady,
    required this.deckCount,
    required this.averagePower,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = creatureCount >= 5;
    const title = 'Field Trials';
    final body = unlocked
        ? deckReady
              ? 'An anomaly signal is stable.'
              : 'Build an 8-creature research deck.'
        : 'Awaken 5 creatures to begin Field Trials.';
    final buttonLabel = unlocked
        ? deckReady
              ? 'Start Trial'
              : 'Build Deck'
        : 'Scan Creature';

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.violet.withValues(alpha: 0.20),
      gradient: LinearGradient(
        colors: [
          AppColors.violet.withValues(alpha: 0.16),
          AppColors.surface.withValues(alpha: 0.84),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.violet.withValues(alpha: 0.16),
                  border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.style_rounded,
                  color: AppColors.violet,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.pearl,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.pearlMuted,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniTrialStat(
                label: unlocked ? 'Deck' : 'Awakened',
                value: unlocked ? '$deckCount/8' : '$creatureCount/5',
                icon: Icons.style_rounded,
                color: AppColors.scannerCyan,
              ),
              const SizedBox(width: 8),
              _MiniTrialStat(
                label: 'Avg PWR',
                value: '$averagePower',
                icon: Icons.query_stats_rounded,
                color: AppColors.rewardGold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppActionButton(
            label: buttonLabel,
            icon: unlocked && deckReady
                ? Icons.play_arrow_rounded
                : Icons.center_focus_strong_rounded,
            variant: unlocked && deckReady
                ? AppActionVariant.reward
                : AppActionVariant.ghost,
            compact: true,
            onPressed: onPrimary,
          ),
        ],
      ),
    );
  }
}

class _MiniTrialStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniTrialStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyMissionsCard extends StatelessWidget {
  final List<Creature> creatures;

  const _DailyMissionsCard({required this.creatures});

  @override
  Widget build(BuildContext context) {
    final scanCount = creatures.length >= 3 ? 3 : creatures.length;
    final foundRare = creatures.any(
      (creature) => rarityRank(creature.rarity) >= rarityRank('Rare'),
    );
    final foundNature = creatures.any(
      (creature) => creature.type.toLowerCase() == 'nature',
    );
    final missions = [
      _MissionData(
        'Scan 3 objects',
        '$scanCount/3',
        scanCount / 3,
        30,
        Icons.camera_alt_rounded,
      ),
      _MissionData(
        'Find a Rare+',
        foundRare ? '1/1' : '0/1',
        foundRare ? 1 : 0,
        50,
        Icons.diamond_rounded,
      ),
      _MissionData(
        'Scan Nature type',
        foundNature ? '1/1' : '0/1',
        foundNature ? 1 : 0,
        25,
        Icons.eco_rounded,
      ),
    ];

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.rewardGold.withValues(alpha: 0.16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Daily Missions',
            icon: Icons.flag_rounded,
          ),
          const SizedBox(height: 10),
          ...missions.map(
            (mission) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MissionRow(mission: mission),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final _MissionData mission;

  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.voidBlack.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.scannerTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(mission.icon, color: AppColors.scannerCyan, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mission.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.pearl,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      mission.count,
                      style: const TextStyle(
                        color: AppColors.pearlMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mission.progress > 0
                          ? AppColors.rewardGold
                          : AppColors.scannerCyan.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.rewardGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${mission.xp} XP',
              style: const TextStyle(
                color: AppColors.rewardGold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedDiscovery extends StatelessWidget {
  final Creature creature;
  final VoidCallback onTap;

  const _FeaturedDiscovery({required this.creature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.getTypeColor(creature.type);

    return PressableScale(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        borderColor: typeColor.withValues(alpha: 0.22),
        gradient: LinearGradient(
          colors: [
            typeColor.withValues(alpha: 0.16),
            AppColors.surface.withValues(alpha: 0.86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            CreaturePortrait(
              type: creature.type,
              rarity: creature.rarity,
              size: 104,
              compact: true,
              imageUrl: creature.imageUrl,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          creature.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.pearl,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.pearlMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      TypeBadge(type: creature.type, compact: true),
                      RarityBadge(rarity: creature.rarity, compact: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Scanned from ${creature.scannedObject}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.pearlMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      radius: 18,
      borderColor: color.withValues(alpha: 0.16),
      color: AppColors.surface.withValues(alpha: 0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.pearlMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakFlame extends StatelessWidget {
  final int count;

  const _StreakFlame({required this.count});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.fire.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.fire.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.fire,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.fire,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _XpGainBadge extends StatelessWidget {
  const _XpGainBadge();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: (1 - value).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -12 * value),
            child: const Text(
              '+120 XP',
              style: TextStyle(
                color: AppColors.rewardGold,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyDiscovery extends StatelessWidget {
  const _EmptyDiscovery();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const LensMark(size: 76, progress: 0.7),
          const SizedBox(height: 16),
          Text(
            'Your first creature is waiting.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Open the scanner and point CreatureLens at any everyday object.',
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
    );
  }
}

class _MissionData {
  final String title;
  final String count;
  final double progress;
  final int xp;
  final IconData icon;

  const _MissionData(this.title, this.count, this.progress, this.xp, this.icon);
}
