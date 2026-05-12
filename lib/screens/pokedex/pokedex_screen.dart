import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/creature.dart';
import '../../providers/creature_provider.dart';
import '../../widgets/creature_lens_widgets.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  String _selectedType = 'All';
  String _selectedRarity = 'All';
  String _dateFilter = 'All';
  String _sortBy = 'Date';
  bool _isGrid = true;

  static const _types = [
    'All',
    'Nature',
    'Fire',
    'Water',
    'Electric',
    'Shadow',
    'Light',
    'Earth',
    'Air',
  ];
  static const _rarities = [
    'All',
    'Common',
    'Uncommon',
    'Rare',
    'Epic',
    'Legendary',
  ];
  static const _dates = ['All', 'Today', '7 days', '30 days'];
  static const _sorts = ['Date', 'Name', 'Rarity', 'Stats'];

  @override
  Widget build(BuildContext context) {
    final creatures = ref.watch(allCreaturesProvider);
    final filtered = _applyFilters(creatures);

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.violet,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pokedex',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Field journal of awakened creatures.',
                            style: TextStyle(
                              color: AppColors.pearlMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ViewToggle(
                      isGrid: _isGrid,
                      onChanged: (value) => setState(() => _isGrid = value),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FilterStrip(
                        title: 'Type',
                        values: _types,
                        selected: _selectedType,
                        colorFor: (value) => value == 'All'
                            ? AppColors.scannerCyan
                            : AppColors.getTypeColor(value),
                        iconFor: (value) => value == 'All'
                            ? Icons.tune_rounded
                            : typeIcon(value),
                        onSelected: (value) =>
                            setState(() => _selectedType = value),
                      ),
                      const SizedBox(height: 12),
                      _FilterStrip(
                        title: 'Rarity',
                        values: _rarities,
                        selected: _selectedRarity,
                        colorFor: (value) => value == 'All'
                            ? AppColors.rewardGold
                            : AppColors.getRarityColor(value),
                        iconFor: (value) => value == 'All'
                            ? Icons.diamond_rounded
                            : Icons.workspace_premium_rounded,
                        onSelected: (value) =>
                            setState(() => _selectedRarity = value),
                      ),
                      const SizedBox(height: 12),
                      _FilterStrip(
                        title: 'Date',
                        values: _dates,
                        selected: _dateFilter,
                        colorFor: (_) => AppColors.pearl,
                        iconFor: (_) => Icons.calendar_month_rounded,
                        onSelected: (value) =>
                            setState(() => _dateFilter = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${filtered.length} creature${filtered.length == 1 ? '' : 's'} found',
                        style: const TextStyle(
                          color: AppColors.pearlMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      initialValue: _sortBy,
                      color: AppColors.surfaceHigh,
                      icon: const Icon(
                        Icons.sort_rounded,
                        color: AppColors.scannerCyan,
                      ),
                      onSelected: (value) => setState(() => _sortBy = value),
                      itemBuilder: (context) => _sorts.map((sort) {
                        return PopupMenuItem<String>(
                          value: sort,
                          child: Text(
                            sort,
                            style: const TextStyle(
                              color: AppColors.pearl,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 118),
                  child: _PokedexEmptyState(
                    onScan: () => context.pushNamed('scan'),
                  ),
                ),
              )
            else if (_isGrid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverGrid.builder(
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final creature = filtered[index];
                    return _CreatureGridCard(
                      creature: creature,
                      onTap: () => context.pushNamed(
                        'creatureDetail',
                        pathParameters: {'id': creature.id},
                        extra: creature,
                      ),
                    );
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final creature = filtered[index];
                    return _CreatureListCard(
                      creature: creature,
                      onTap: () => context.pushNamed(
                        'creatureDetail',
                        pathParameters: {'id': creature.id},
                        extra: creature,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Creature> _applyFilters(List<Creature> creatures) {
    final now = DateTime.now();
    final filtered = creatures.where((creature) {
      if (_selectedType != 'All' && creature.type != _selectedType) {
        return false;
      }
      if (_selectedRarity != 'All' && creature.rarity != _selectedRarity) {
        return false;
      }
      final age = now.difference(creature.discoveredAt);
      if (_dateFilter == 'Today' && age.inDays >= 1) return false;
      if (_dateFilter == '7 days' && age.inDays > 7) return false;
      if (_dateFilter == '30 days' && age.inDays > 30) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Rarity':
        filtered.sort(
          (a, b) => rarityRank(b.rarity).compareTo(rarityRank(a.rarity)),
        );
        break;
      case 'Stats':
        filtered.sort((a, b) => b.totalPower.compareTo(a.totalPower));
        break;
      case 'Date':
      default:
        filtered.sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
    }
    return filtered;
  }
}

class _FilterStrip extends StatelessWidget {
  final String title;
  final List<String> values;
  final String selected;
  final Color Function(String value) colorFor;
  final IconData Function(String value) iconFor;
  final ValueChanged<String> onSelected;

  const _FilterStrip({
    required this.title,
    required this.values,
    required this.selected,
    required this.colorFor,
    required this.iconFor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.pearlMuted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final value = values[index];
              return FilterPill(
                label: value,
                selected: selected == value,
                color: colorFor(value),
                icon: iconFor(value),
                onTap: () => onSelected(value),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: values.length,
          ),
        ),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.isGrid, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _ToggleIcon(
            icon: Icons.grid_view_rounded,
            selected: isGrid,
            onTap: () => onChanged(true),
          ),
          _ToggleIcon(
            icon: Icons.view_agenda_rounded,
            selected: !isGrid,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? AppColors.scannerTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.voidBlack : AppColors.pearlMuted,
        ),
      ),
    );
  }
}

class _CreatureGridCard extends StatelessWidget {
  final Creature creature;
  final VoidCallback onTap;

  const _CreatureGridCard({required this.creature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.getTypeColor(creature.type);
    final rarityColor = AppColors.getRarityColor(creature.rarity);

    return PressableScale(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        radius: 22,
        borderColor: rarityColor.withValues(alpha: 0.22),
        gradient: LinearGradient(
          colors: [
            typeColor.withValues(alpha: 0.13),
            AppColors.surface.withValues(alpha: 0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RarityBadge(rarity: creature.rarity, compact: true),
                ),
                if (creature.evolutionShards > 0)
                  ShardChip(count: creature.evolutionShards),
              ],
            ),
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'creature-${creature.id}',
                  child: CreaturePortrait(
                    type: creature.type,
                    rarity: creature.rarity,
                    size: 118,
                    compact: true,
                    imageUrl: creature.imageUrl,
                  ),
                ),
              ),
            ),
            Text(
              creature.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.pearl,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TypeBadge(type: creature.type, compact: true)),
                const SizedBox(width: 6),
                Text(
                  'PWR ${creature.totalPower}',
                  style: const TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatureListCard extends StatelessWidget {
  final Creature creature;
  final VoidCallback onTap;

  const _CreatureListCard({required this.creature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.getTypeColor(creature.type);

    return PressableScale(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        borderColor: typeColor.withValues(alpha: 0.16),
        color: AppColors.surface.withValues(alpha: 0.78),
        child: Row(
          children: [
            Hero(
              tag: 'creature-${creature.id}',
              child: CreaturePortrait(
                type: creature.type,
                rarity: creature.rarity,
                size: 74,
                compact: true,
                imageUrl: creature.imageUrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creature.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.pearl,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      TypeBadge(type: creature.type, compact: true),
                      RarityBadge(rarity: creature.rarity, compact: true),
                      if (creature.evolutionShards > 0)
                        ShardChip(count: creature.evolutionShards),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${creature.totalPower}',
                  style: const TextStyle(
                    color: AppColors.rewardGold,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'PWR',
                  style: TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PokedexEmptyState extends StatelessWidget {
  final VoidCallback onScan;

  const _PokedexEmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        radius: 26,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CreaturePortrait(type: 'Nature', rarity: 'Common', size: 132),
            const SizedBox(height: 16),
            Text(
              'No creatures match this view.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Clear filters or scan something nearby to start filling your collection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.pearlMuted,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            AppActionButton(
              label: 'Scan Creature',
              icon: Icons.center_focus_strong_rounded,
              onPressed: onScan,
            ),
          ],
        ),
      ),
    );
  }
}
