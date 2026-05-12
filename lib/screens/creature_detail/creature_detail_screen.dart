import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/creature.dart';
import '../../widgets/creature_lens_widgets.dart';

class CreatureDetailScreen extends StatelessWidget {
  final Creature? creature;

  const CreatureDetailScreen({super.key, this.creature});

  @override
  Widget build(BuildContext context) {
    final c = creature ?? _fallbackCreature();
    final typeColor = AppColors.getTypeColor(c.type);
    final rarityColor = AppColors.getRarityColor(c.rarity);

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: typeColor,
        glowAlignment: Alignment.topCenter,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  MediaQuery.of(context).padding.top + 6,
                  12,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.pearl,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.ios_share_rounded),
                      color: AppColors.pearlMuted,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                  radius: 30,
                  borderColor: rarityColor.withValues(alpha: 0.30),
                  gradient: LinearGradient(
                    colors: [
                      typeColor.withValues(alpha: 0.18),
                      rarityColor.withValues(alpha: 0.10),
                      AppColors.surface.withValues(alpha: 0.88),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'creature-${c.id}',
                        child: CreaturePortrait(
                          type: c.type,
                          rarity: c.rarity,
                          size: 220,
                          imageUrl: c.imageUrl,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.pearl,
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          height: 1.06,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TypeBadge(type: c.type),
                          RarityBadge(rarity: c.rarity),
                          ShardChip(count: c.evolutionShards),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Stats',
                        icon: Icons.query_stats_rounded,
                      ),
                      const SizedBox(height: 12),
                      StatBar(label: 'HP', value: c.hp, color: AppColors.error),
                      StatBar(
                        label: 'Attack',
                        value: c.attack,
                        color: AppColors.fire,
                      ),
                      StatBar(
                        label: 'Defense',
                        value: c.defense,
                        color: AppColors.scannerCyan,
                      ),
                      StatBar(
                        label: 'Speed',
                        value: c.speed,
                        color: AppColors.electric,
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total Power ${c.totalPower}',
                          style: const TextStyle(
                            color: AppColors.rewardGold,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  borderColor: typeColor.withValues(alpha: 0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Lore',
                        icon: Icons.menu_book_rounded,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        c.lore,
                        style: const TextStyle(
                          color: AppColors.pearlMuted,
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Abilities',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      const SizedBox(height: 12),
                      ...c.abilities.map(
                        (ability) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AbilityTile(
                            ability: ability,
                            color: typeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Scan Info',
                        icon: Icons.document_scanner_rounded,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Object', value: c.scannedObject),
                      _InfoRow(
                        label: 'Labels',
                        value: c.scannedLabels.join(', '),
                      ),
                      _InfoRow(
                        label: 'Discovered',
                        value: _formatDate(c.discoveredAt),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  borderColor: AppColors.rewardGold.withValues(alpha: 0.22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.hexagon_rounded,
                            color: AppColors.rewardGold,
                            size: 23,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${c.evolutionShards} Evolution Shards',
                              style: const TextStyle(
                                color: AppColors.pearl,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Duplicate scans become shards. Spend them to upgrade stats and unlock a stronger field form.',
                        style: TextStyle(
                          color: AppColors.pearlMuted,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppActionButton(
                        label: c.evolutionShards >= 10
                            ? 'Upgrade Creature'
                            : 'Need ${10 - c.evolutionShards} More Shards',
                        icon: Icons.upgrade_rounded,
                        variant: AppActionVariant.reward,
                        onPressed: c.evolutionShards >= 10 ? () {} : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.month}/${value.day}/${value.year} at ${value.hour}:$minute';
  }

  Creature _fallbackCreature() {
    return Creature(
      id: 'unknown',
      userId: 'guest',
      name: 'Uncatalogued Echo',
      type: 'Shadow',
      rarity: 'Common',
      hp: 50,
      attack: 50,
      defense: 50,
      speed: 50,
      abilities: const [
        CreatureAbility(
          name: 'Static Hush',
          description: 'A faint signal that has not been fully decoded.',
          type: 'Shadow',
        ),
      ],
      lore: 'This entry is still forming in the journal.',
      scannedObject: 'Unknown',
      scannedLabels: const ['unknown 42%'],
      discoveredAt: DateTime.now(),
    );
  }
}

class _AbilityTile extends StatelessWidget {
  final CreatureAbility ability;
  final Color color;

  const _AbilityTile({required this.ability, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(typeIcon(ability.type), color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ability.name,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ability.description,
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.pearlMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.pearl,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
