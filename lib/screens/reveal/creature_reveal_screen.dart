import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/creature.dart';
import '../../providers/creature_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/creature_lens_widgets.dart';

class CreatureRevealScreen extends ConsumerStatefulWidget {
  final Creature? creature;

  const CreatureRevealScreen({super.key, this.creature});

  @override
  ConsumerState<CreatureRevealScreen> createState() =>
      _CreatureRevealScreenState();
}

class _CreatureRevealScreenState extends ConsumerState<CreatureRevealScreen>
    with TickerProviderStateMixin {
  late final AnimationController _revealController;
  late final AnimationController _detailsController;
  late final Creature _creature;

  @override
  void initState() {
    super.initState();
    _creature = widget.creature ?? _demoCreature();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _detailsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _startReveal();
  }

  Future<void> _startReveal() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (mounted) _revealController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 780));
    if (mounted) _detailsController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _addToCollection() async {
    await ref.read(allCreaturesProvider.notifier).add(_creature);
    if (!mounted) return;
    // Read the creature count after the add operation to ensure it's up-to-date.
    final currentCount = ref.read(allCreaturesProvider).length;
    await ref.read(userProvider.notifier).addXp(_creature.xpReward);
    await ref
        .read(userProvider.notifier)
        .setTotalCreatures(currentCount);
    if (!mounted) return;
    context.goNamed('pokedex');
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.getTypeColor(_creature.type);
    final rarityColor = AppColors.getRarityColor(_creature.rarity);
    final offlineSynthesis = _isOfflineSynthesisCreature(_creature);
    final scale = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.elasticOut),
    );
    final fade = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0, 0.62, curve: Curves.easeOut),
    );
    final detailsFade = CurvedAnimation(
      parent: _detailsController,
      curve: Curves.easeOut,
    );

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: rarityColor,
        glowAlignment: Alignment.center,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.pearl,
                      ),
                      const Spacer(),
                      const Text(
                        'NEW DISCOVERY',
                        style: TextStyle(
                          color: AppColors.pearlMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                  child: FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: GlassPanel(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                        radius: 30,
                        borderColor: rarityColor.withValues(alpha: 0.42),
                        gradient: LinearGradient(
                          colors: [
                            rarityColor.withValues(alpha: 0.20),
                            typeColor.withValues(alpha: 0.12),
                            AppColors.surface.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RarityBadge(rarity: _creature.rarity),
                                const SizedBox(width: 8),
                                TypeBadge(type: _creature.type),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Hero(
                              tag: 'creature-${_creature.id}',
                              child: CreaturePortrait(
                                type: _creature.type,
                                rarity: _creature.rarity,
                                size: 206,
                                imageUrl: _creature.imageUrl,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _creature.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.pearl,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Power ${_creature.totalPower}  |  +${_creature.xpReward} XP',
                              style: TextStyle(
                                color: rarityColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (offlineSynthesis) ...[
                              const SizedBox(height: 10),
                              const _OfflineSynthesisBadge(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: detailsFade,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            title: 'Battle Profile',
                            icon: Icons.query_stats_rounded,
                          ),
                          const SizedBox(height: 12),
                          StatBar(
                            label: 'HP',
                            value: _creature.hp,
                            color: AppColors.error,
                          ),
                          StatBar(
                            label: 'Attack',
                            value: _creature.attack,
                            color: AppColors.fire,
                          ),
                          StatBar(
                            label: 'Defense',
                            value: _creature.defense,
                            color: AppColors.scannerCyan,
                          ),
                          StatBar(
                            label: 'Speed',
                            value: _creature.speed,
                            color: AppColors.electric,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _creature.abilities.take(2).map((
                              ability,
                            ) {
                              return _AbilityPreview(
                                ability: ability,
                                color: typeColor,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: detailsFade,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                    child: Column(
                      children: [
                        AppActionButton(
                          label: 'Add to Collection',
                          icon: Icons.library_add_rounded,
                          variant: AppActionVariant.reward,
                          onPressed: _addToCollection,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AppActionButton(
                                label: 'View Details',
                                icon: Icons.auto_stories_rounded,
                                variant: AppActionVariant.ghost,
                                compact: true,
                                onPressed: () => context.pushNamed(
                                  'creatureDetail',
                                  pathParameters: {'id': _creature.id},
                                  extra: _creature,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppActionButton(
                                label: 'Scan Again',
                                icon: Icons.center_focus_strong_rounded,
                                variant: AppActionVariant.ghost,
                                compact: true,
                                onPressed: () => context.goNamed('scan'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Creature _demoCreature() {
    return Creature(
      id: 'scan-flare-1',
      userId: 'guest',
      name: 'Cupflare Drifter',
      type: 'Light',
      rarity: 'Epic',
      hp: 76,
      attack: 84,
      defense: 67,
      speed: 88,
      abilities: const [
        CreatureAbility(
          name: 'Porcelain Halo',
          description: 'Reflects the next status effect into a healing spark.',
          type: 'Light',
        ),
        CreatureAbility(
          name: 'Steam Waltz',
          description: 'Dashes through warm mist and raises evasion.',
          type: 'Air',
        ),
      ],
      lore:
          'Cupflare Drifter forms in the last curl of steam above a quiet drink. It guards the small rituals that keep travelers brave.',
      scannedObject: 'Ceramic Mug',
      scannedLabels: ['mug 94%', 'ceramic 83%', 'tableware 79%'],
      discoveredAt: DateTime.now(),
      evolutionShards: 0,
    );
  }

  bool _isOfflineSynthesisCreature(Creature creature) {
    final lore = creature.lore.toLowerCase();
    return lore.contains('offline synthesis mode') ||
        lore.contains('local synthesis') ||
        lore.contains('gemma was temporarily unavailable') ||
        (creature.name == 'Mystery Creature' &&
            creature.abilities.any(
              (ability) => ability.name == 'Unknown Force',
            ));
  }
}

class _OfflineSynthesisBadge extends StatelessWidget {
  const _OfflineSynthesisBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.rewardGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.rewardGold.withValues(alpha: 0.28)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.rewardGold, size: 15),
          SizedBox(width: 6),
          Text(
            'OFFLINE SYNTHESIS MODE',
            style: TextStyle(
              color: AppColors.rewardGold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbilityPreview extends StatelessWidget {
  final CreatureAbility ability;
  final Color color;

  const _AbilityPreview({required this.ability, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ability.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            ability.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.pearlMuted,
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
