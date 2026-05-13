import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/battle_deck.dart';
import '../../models/creature.dart';
import '../../providers/creature_provider.dart';
import '../../providers/deck_provider.dart';
import '../../services/battle_rules.dart';
import '../../widgets/creature_lens_widgets.dart';
import '../../widgets/deckbuilder_widgets.dart';

class DeckBuilderScreen extends ConsumerStatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  ConsumerState<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends ConsumerState<DeckBuilderScreen> {
  String _type = 'All';
  String _rarity = 'All';
  String _sort = 'Power';

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

  @override
  Widget build(BuildContext context) {
    final creatures = ref.watch(allCreaturesProvider);
    final deck = ref.watch(activeDeckProvider);
    final selectedIds = deck?.creatureIds ?? const <String>[];
    final selectedCreatures = selectedIds
        .map((id) => _creatureById(creatures, id))
        .whereType<Creature>()
        .toList();
    final filtered = _filteredCreatures(creatures);
    final unlocked = creatures.length >= 5;
    final canAutoBuild = creatures.length >= BattleDeck.requiredCardCount;
    final deckPower = BattleRules.averageDeckPower(
      deck: deck,
      creatures: creatures,
    );

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.violet,
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
                    Expanded(
                      child: Text(
                        'Field Trials',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: canAutoBuild
                          ? () => ref
                                .read(activeDeckProvider.notifier)
                                .autoBuild(creatures)
                          : null,
                      tooltip: 'Auto Build',
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      color: canAutoBuild
                          ? AppColors.rewardGold
                          : AppColors.textDim,
                    ),
                  ],
                ),
              ),
            ),
            if (!unlocked)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 34),
                  child: _LockedTrialsCard(creatureCount: creatures.length),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.rewardGold.withValues(alpha: 0.18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SectionHeader(
                                title:
                                    'Active Deck ${selectedIds.length}/${BattleDeck.requiredCardCount}',
                                icon: Icons.style_rounded,
                              ),
                            ),
                            Text(
                              '$deckPower PWR',
                              style: const TextStyle(
                                color: AppColors.rewardGold,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            BattleDeck.requiredCardCount,
                            (index) {
                              final id = index < selectedIds.length
                                  ? selectedIds[index]
                                  : null;
                              final creature = _creatureById(creatures, id);
                              return _DeckSlot(
                                index: index,
                                creature: creature,
                                onRemove: id == null
                                    ? null
                                    : () => ref
                                          .read(activeDeckProvider.notifier)
                                          .removeCreature(id),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        TypeMixStrip(creatures: selectedCreatures),
                        const SizedBox(height: 14),
                        _ValidityHint(
                          selectedCount: selectedIds.length,
                          canAutoBuild: canAutoBuild,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: AppActionButton(
                                label: 'Auto Build',
                                icon: Icons.auto_fix_high_rounded,
                                variant: AppActionVariant.ghost,
                                compact: true,
                                onPressed: canAutoBuild
                                    ? () => ref
                                          .read(activeDeckProvider.notifier)
                                          .autoBuild(creatures)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppActionButton(
                                label: 'Start Trial',
                                icon: Icons.play_arrow_rounded,
                                variant: AppActionVariant.reward,
                                compact: true,
                                onPressed: deck?.isValid == true
                                    ? () => context.pushNamed('fieldSetup')
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterStrip(
                          values: _types,
                          selected: _type,
                          colorFor: (value) => value == 'All'
                              ? AppColors.scannerCyan
                              : AppColors.getTypeColor(value),
                          iconFor: (value) => value == 'All'
                              ? Icons.tune_rounded
                              : typeIcon(value),
                          onSelected: (value) => setState(() => _type = value),
                        ),
                        const SizedBox(height: 10),
                        _FilterStrip(
                          values: _rarities,
                          selected: _rarity,
                          colorFor: (value) => value == 'All'
                              ? AppColors.rewardGold
                              : AppColors.getRarityColor(value),
                          iconFor: (value) => value == 'All'
                              ? Icons.diamond_rounded
                              : Icons.workspace_premium_rounded,
                          onSelected: (value) =>
                              setState(() => _rarity = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${filtered.length} eligible creatures',
                          style: const TextStyle(
                            color: AppColors.pearlMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        initialValue: _sort,
                        color: AppColors.surfaceHigh,
                        icon: const Icon(
                          Icons.sort_rounded,
                          color: AppColors.scannerCyan,
                        ),
                        onSelected: (value) => setState(() => _sort = value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'Power', child: Text('Power')),
                          PopupMenuItem(value: 'Name', child: Text('Name')),
                          PopupMenuItem(value: 'Newest', child: Text('Newest')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 34),
                    child: _EmptyFilterCard(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 34),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final creature = filtered[index];
                      final selected = selectedIds.contains(creature.id);
                      final deckFull =
                          selectedIds.length >= BattleDeck.requiredCardCount;
                      return TrialCreatureCard(
                        creature: creature,
                        selected: selected,
                        disabled: !selected && deckFull,
                        onTap: () => _showCardDetail(
                          creature: creature,
                          inDeck: selected,
                          canAdd: selected || !deckFull,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Creature> _filteredCreatures(List<Creature> creatures) {
    final filtered = creatures.where((creature) {
      if (_type != 'All' && creature.type != _type) return false;
      if (_rarity != 'All' && creature.rarity != _rarity) return false;
      return true;
    }).toList();

    switch (_sort) {
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Newest':
        filtered.sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
        break;
      case 'Power':
      default:
        filtered.sort((a, b) => b.totalPower.compareTo(a.totalPower));
    }
    return filtered;
  }

  Creature? _creatureById(List<Creature> creatures, String? id) {
    if (id == null) return null;
    for (final creature in creatures) {
      if (creature.id == id) return creature;
    }
    return null;
  }

  void _showCardDetail({
    required Creature creature,
    required bool inDeck,
    required bool canAdd,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.voidBlack.withValues(alpha: 0.72),
      builder: (context) {
        return TrialCardDetailSheet(
          creature: creature,
          inDeck: inDeck,
          canAdd: canAdd,
          onToggle: () {
            final notifier = ref.read(activeDeckProvider.notifier);
            if (inDeck) {
              notifier.removeCreature(creature.id);
            } else {
              notifier.addCreature(creature.id);
            }
          },
        );
      },
    );
  }
}

class _EmptyFilterCard extends StatelessWidget {
  const _EmptyFilterCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.scannerCyan.withValues(alpha: 0.16),
      child: const Column(
        children: [
          Icon(Icons.filter_alt_off_rounded, color: AppColors.scannerCyan),
          SizedBox(height: 10),
          Text(
            'No creatures match these filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pearl,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try another type or rarity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pearlMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidityHint extends StatelessWidget {
  final int selectedCount;
  final bool canAutoBuild;

  const _ValidityHint({
    required this.selectedCount,
    required this.canAutoBuild,
  });

  @override
  Widget build(BuildContext context) {
    final valid = selectedCount == BattleDeck.requiredCardCount;
    final missing = BattleDeck.requiredCardCount - selectedCount;
    final color = valid ? AppColors.nature : AppColors.rewardGold;
    final text = valid
        ? 'Deck ready. Scanner anomaly can be engaged.'
        : canAutoBuild
        ? 'Needs $missing more ${missing == 1 ? 'card' : 'cards'} to start.'
        : 'Collect 8 creatures to start a trial. Deck Builder unlocks early so you can plan the lineup.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedTrialsCard extends StatelessWidget {
  final int creatureCount;

  const _LockedTrialsCard({required this.creatureCount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        radius: 26,
        borderColor: AppColors.violet.withValues(alpha: 0.22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LensMark(size: 88, progress: 0.82),
            const SizedBox(height: 18),
            Text(
              'Awaken 5 creatures to begin Field Trials.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$creatureCount/5 creatures awakened',
              style: const TextStyle(
                color: AppColors.rewardGold,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            AppActionButton(
              label: 'Scan Creature',
              icon: Icons.center_focus_strong_rounded,
              onPressed: () => context.pushNamed('scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckSlot extends StatelessWidget {
  final int index;
  final Creature? creature;
  final VoidCallback? onRemove;

  const _DeckSlot({
    required this.index,
    required this.creature,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final color = creature == null
        ? AppColors.textDim
        : AppColors.getTypeColor(creature!.type);
    return PressableScale(
      onTap: onRemove,
      child: Container(
        width: 72,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: creature == null ? 0.06 : 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: creature == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.textDim,
                    size: 18,
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: CreaturePortrait(
                      type: creature!.type,
                      rarity: creature!.rarity,
                      size: 42,
                      compact: true,
                      imageUrl: creature!.imageUrl,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    creature!.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.pearl,
                      fontSize: 10,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  final List<String> values;
  final String selected;
  final Color Function(String value) colorFor;
  final IconData Function(String value) iconFor;
  final ValueChanged<String> onSelected;

  const _FilterStrip({
    required this.values,
    required this.selected,
    required this.colorFor,
    required this.iconFor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
