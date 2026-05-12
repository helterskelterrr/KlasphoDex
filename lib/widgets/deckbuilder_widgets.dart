import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/battle_state.dart';
import '../models/creature.dart';
import '../services/battle_rules.dart';
import 'creature_lens_widgets.dart';

String difficultyLabel(TrialDifficulty difficulty) {
  return BattleRules.configFor(difficulty).label;
}

String intentLabel(AnomalyIntent intent) {
  switch (intent) {
    case AnomalyIntent.attack:
      return 'Attack';
    case AnomalyIntent.guard:
      return 'Guard';
    case AnomalyIntent.distort:
      return 'Distort';
  }
}

IconData intentIcon(AnomalyIntent intent) {
  switch (intent) {
    case AnomalyIntent.attack:
      return Icons.flash_on_rounded;
    case AnomalyIntent.guard:
      return Icons.shield_rounded;
    case AnomalyIntent.distort:
      return Icons.blur_on_rounded;
  }
}

String effectLabel(BattleCardEffect effect) {
  switch (effect) {
    case BattleCardEffect.burn:
      return 'Burn: +1 end-turn damage';
    case BattleCardEffect.mend:
      return 'Mend: restore 1 resolve';
    case BattleCardEffect.guard:
      return 'Guard: gain extra shield';
    case BattleCardEffect.draft:
      return 'Draft: draw 1 card';
    case BattleCardEffect.spark:
      return 'Spark: pierce 1 damage';
    case BattleCardEffect.grow:
      return 'Grow: next card +1 damage';
    case BattleCardEffect.weaken:
      return 'Weaken: next attack -1';
    case BattleCardEffect.focus:
      return 'Focus: +1 focus next turn';
  }
}

String effectTitle(BattleCardEffect effect) {
  switch (effect) {
    case BattleCardEffect.burn:
      return 'Burn';
    case BattleCardEffect.mend:
      return 'Mend';
    case BattleCardEffect.guard:
      return 'Guard';
    case BattleCardEffect.draft:
      return 'Draft';
    case BattleCardEffect.spark:
      return 'Spark';
    case BattleCardEffect.grow:
      return 'Grow';
    case BattleCardEffect.weaken:
      return 'Weaken';
    case BattleCardEffect.focus:
      return 'Focus';
  }
}

String effectDescription(BattleCardEffect effect) {
  switch (effect) {
    case BattleCardEffect.burn:
      return 'Deals 1 extra damage at the end of the turn.';
    case BattleCardEffect.mend:
      return 'Restores 1 Resolve when this card is played.';
    case BattleCardEffect.guard:
      return 'Adds extra Shield to help survive anomaly attacks.';
    case BattleCardEffect.draft:
      return 'Draws 1 card from the research deck.';
    case BattleCardEffect.spark:
      return 'Pierces 1 damage through anomaly Shield.';
    case BattleCardEffect.grow:
      return 'The next card you play deals +1 damage.';
    case BattleCardEffect.weaken:
      return 'Reduces the next anomaly attack by 1.';
    case BattleCardEffect.focus:
      return 'Gain +1 Focus on the next turn.';
  }
}

String speedLabel(SpeedTier tier) {
  switch (tier) {
    case SpeedTier.slow:
      return 'Slow';
    case SpeedTier.normal:
      return 'Normal';
    case SpeedTier.quick:
      return 'Quick';
  }
}

class TrialStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const TrialStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.pearlMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FocusGem extends StatelessWidget {
  final int value;
  final double size;
  final Color color;

  const FocusGem({
    super.key,
    required this.value,
    this.size = 34,
    this.color = AppColors.scannerCyan,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _FocusGemPainter(color: color),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              color: AppColors.voidBlack,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class TacticalStatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const TacticalStatCell({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.voidBlack.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class TypeMixStrip extends StatelessWidget {
  final List<Creature> creatures;
  final bool showLegend;

  const TypeMixStrip({
    super.key,
    required this.creatures,
    this.showLegend = true,
  });

  static const _typeOrder = [
    'Fire',
    'Water',
    'Earth',
    'Air',
    'Electric',
    'Nature',
    'Shadow',
    'Light',
  ];

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final creature in creatures) {
      counts.update(creature.type, (value) => value + 1, ifAbsent: () => 1);
    }
    final total = creatures.length;
    final activeTypes = _typeOrder
        .where((type) => (counts[type] ?? 0) > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (total == 0)
                  Expanded(
                    child: ColoredBox(
                      color: AppColors.pearlMuted.withValues(alpha: 0.12),
                    ),
                  )
                else
                  for (final type in activeTypes)
                    Expanded(
                      flex: counts[type]!,
                      child: ColoredBox(color: AppColors.getTypeColor(type)),
                    ),
              ],
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (activeTypes.isEmpty)
                const Text(
                  'No type mix yet',
                  style: TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                for (final type in activeTypes)
                  _TypeMixToken(type: type, count: counts[type]!),
            ],
          ),
        ],
      ],
    );
  }
}

class TrialCardDetailSheet extends StatelessWidget {
  final Creature creature;
  final bool inDeck;
  final bool canAdd;
  final VoidCallback onToggle;

  const TrialCardDetailSheet({
    super.key,
    required this.creature,
    required this.inDeck,
    required this.canAdd,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final card = BattleRules.cardFromCreature(creature);
    final typeColor = AppColors.getTypeColor(creature.type);
    final rarityColor = AppColors.getRarityColor(creature.rarity);
    final ability = creature.abilities.isEmpty
        ? null
        : creature.abilities.first;
    final actionEnabled = inDeck || canAdd;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              typeColor.withValues(alpha: 0.22),
              AppColors.surfaceHigh,
              AppColors.voidBlack,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(
            top: BorderSide(color: typeColor.withValues(alpha: 0.5)),
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.22),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.pearlMuted.withValues(alpha: 0.26),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 102,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.voidBlack.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.42),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CreaturePortrait(
                      type: creature.type,
                      rarity: creature.rarity,
                      size: 98,
                      compact: true,
                      imageUrl: creature.imageUrl,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            TypeBadge(type: creature.type, compact: true),
                            RarityBadge(rarity: creature.rarity, compact: true),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          creature.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.pearl,
                            fontSize: 21,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Speed Tier',
                              style: TextStyle(
                                color: AppColors.pearlMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                speedLabel(card.speedTier),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.pearlMuted,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7,
                childAspectRatio: 0.92,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  TacticalStatCell(
                    label: 'COST',
                    value: '${card.cost}',
                    icon: Icons.bolt_rounded,
                    color: AppColors.scannerCyan,
                  ),
                  TacticalStatCell(
                    label: 'DMG',
                    value: '${card.damage}',
                    icon: Icons.gps_fixed_rounded,
                    color: AppColors.fire,
                  ),
                  TacticalStatCell(
                    label: 'SHLD',
                    value: '${card.shield}',
                    icon: Icons.shield_rounded,
                    color: AppColors.water,
                  ),
                  TacticalStatCell(
                    label: 'PWR',
                    value: '${card.power}',
                    icon: Icons.query_stats_rounded,
                    color: rarityColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _TacticalInfoBlock(
                label:
                    'TYPE EFFECT · ${effectTitle(card.effect).toUpperCase()}',
                value: effectDescription(card.effect),
                color: typeColor,
              ),
              const SizedBox(height: 10),
              _TacticalInfoBlock(
                label: '// FIELD NOTE',
                value: ability == null
                    ? creature.lore
                    : '${ability.name}: ${ability.description}',
                color: AppColors.pearlMuted,
                subdued: true,
              ),
              const SizedBox(height: 16),
              AppActionButton(
                label: inDeck
                    ? 'REMOVE FROM DECK'
                    : actionEnabled
                    ? 'ADD TO DECK'
                    : 'DECK FULL',
                icon: inDeck ? Icons.remove_rounded : Icons.add_rounded,
                variant: inDeck
                    ? AppActionVariant.danger
                    : AppActionVariant.reward,
                onPressed: actionEnabled
                    ? () {
                        onToggle();
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TacticalInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool subdued;

  const _TacticalInfoBlock({
    required this.label,
    required this.value,
    required this.color,
    this.subdued = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.voidBlack.withValues(alpha: subdued ? 0.24 : 0.36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: subdued ? 0.18 : 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: subdued ? AppColors.pearlMuted : color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: subdued ? AppColors.pearlMuted : AppColors.pearl,
              fontSize: 13,
              height: 1.42,
              fontWeight: FontWeight.w700,
              fontStyle: subdued ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeMixToken extends StatelessWidget {
  final String type;
  final int count;

  const _TypeMixToken({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(typeIcon(type), color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            '$type $count',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusGemPainter extends CustomPainter {
  final Color color;

  const _FocusGemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.04)
      ..lineTo(size.width * 0.93, size.height * 0.34)
      ..lineTo(size.width * 0.77, size.height * 0.92)
      ..lineTo(size.width * 0.23, size.height * 0.92)
      ..lineTo(size.width * 0.07, size.height * 0.34)
      ..close();
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color, AppColors.scannerTeal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.pearl.withValues(alpha: 0.4);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _FocusGemPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class TrialCreatureCard extends StatelessWidget {
  final Creature creature;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  final String? trailingLabel;

  const TrialCreatureCard({
    super.key,
    required this.creature,
    this.selected = false,
    this.disabled = false,
    this.onTap,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final card = BattleRules.cardFromCreature(creature);
    final typeColor = AppColors.getTypeColor(creature.type);
    final rarityColor = AppColors.getRarityColor(creature.rarity);

    return PressableScale(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.45 : 1,
        duration: const Duration(milliseconds: 160),
        child: GlassPanel(
          padding: const EdgeInsets.all(12),
          radius: 14,
          color: selected
              ? typeColor.withValues(alpha: 0.18)
              : AppColors.surface.withValues(alpha: 0.78),
          borderColor: selected
              ? typeColor.withValues(alpha: 0.48)
              : rarityColor.withValues(alpha: 0.14),
          child: Row(
            children: [
              CreaturePortrait(
                type: creature.type,
                rarity: creature.rarity,
                size: 58,
                compact: true,
                imageUrl: creature.imageUrl,
              ),
              const SizedBox(width: 10),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        TypeBadge(type: creature.type, compact: true),
                        RarityBadge(rarity: creature.rarity, compact: true),
                        TrialStatChip(
                          icon: Icons.bolt_rounded,
                          label: 'Cost',
                          value: '${card.cost}',
                          color: AppColors.scannerCyan,
                        ),
                        TrialStatChip(
                          icon: Icons.gps_fixed_rounded,
                          label: 'Dmg',
                          value: '${card.damage}',
                          color: AppColors.fire,
                        ),
                        TrialStatChip(
                          icon: Icons.shield_rounded,
                          label: 'Shld',
                          value: '${card.shield}',
                          color: AppColors.water,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${effectTitle(card.effect)} · ${speedLabel(card.speedTier)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.pearlMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.nature.withValues(alpha: 0.92)
                          : AppColors.voidBlack.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.nature
                            : typeColor.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.check_rounded : Icons.add_rounded,
                      color: selected ? AppColors.voidBlack : typeColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trailingLabel ?? '${creature.totalPower}',
                    style: TextStyle(
                      color: selected ? AppColors.nature : AppColors.rewardGold,
                      fontSize: 15,
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
      ),
    );
  }
}

class BattleHandCard extends StatelessWidget {
  final Creature creature;
  final int focus;
  final VoidCallback onTap;

  const BattleHandCard({
    super.key,
    required this.creature,
    required this.focus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = BattleRules.cardFromCreature(creature);
    final typeColor = AppColors.getTypeColor(creature.type);
    final affordable = focus >= card.cost;

    return SizedBox(
      width: 132,
      child: PressableScale(
        onTap: affordable ? onTap : null,
        child: AnimatedOpacity(
          opacity: affordable ? 1 : 0.46,
          duration: const Duration(milliseconds: 160),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: typeColor.withValues(alpha: affordable ? 0.42 : 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: affordable ? 0.14 : 0),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: typeColor.withValues(alpha: 0.16),
                      ),
                      child: Center(
                        child: Text(
                          '${card.cost}',
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(typeIcon(creature.type), color: typeColor, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  creature.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.pearl,
                    fontSize: 13,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  effectLabel(card.effect),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 10,
                    height: 1.22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _TinyCardStat(
                      icon: Icons.gps_fixed_rounded,
                      value: '${card.damage}',
                      color: AppColors.fire,
                    ),
                    const SizedBox(width: 6),
                    _TinyCardStat(
                      icon: Icons.shield_rounded,
                      value: '${card.shield}',
                      color: AppColors.scannerCyan,
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

class _TinyCardStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _TinyCardStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 3),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
