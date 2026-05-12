import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum AppActionVariant { scanner, reward, ghost, danger }

IconData typeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'fire':
      return Icons.local_fire_department_rounded;
    case 'water':
      return Icons.water_drop_rounded;
    case 'earth':
      return Icons.terrain_rounded;
    case 'air':
      return Icons.air_rounded;
    case 'electric':
      return Icons.bolt_rounded;
    case 'nature':
      return Icons.eco_rounded;
    case 'shadow':
      return Icons.dark_mode_rounded;
    case 'light':
      return Icons.flare_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}

int rarityRank(String rarity) {
  switch (rarity.toLowerCase()) {
    case 'legendary':
      return 5;
    case 'epic':
      return 4;
    case 'rare':
      return 3;
    case 'uncommon':
      return 2;
    default:
      return 1;
  }
}

class CreatureLensBackground extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final Alignment glowAlignment;

  const CreatureLensBackground({
    super.key,
    required this.child,
    this.glowColor = AppColors.scannerTeal,
    this.glowAlignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.appBackdrop),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FieldGridPainter(
                  glowColor: glowColor,
                  glowAlignment: glowAlignment,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? borderColor;
  final Gradient? gradient;
  final Color? color;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 20,
    this.borderColor,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.surface.withValues(alpha: 0.74);
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint,
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius? borderRadius;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.borderRadius,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class AppActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final AppActionVariant variant;
  final bool expanded;
  final bool compact;

  const AppActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.variant = AppActionVariant.scanner,
    this.expanded = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _variantColors();
    final foreground = variant == AppActionVariant.ghost
        ? colors.$1
        : variant == AppActionVariant.reward
        ? AppColors.ink
        : Colors.white;
    final disabled = onPressed == null;

    final button = AnimatedOpacity(
      opacity: disabled ? 0.42 : 1,
      duration: const Duration(milliseconds: 160),
      child: Container(
        height: compact ? 44 : 56,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(compact ? 14 : 18),
          gradient: variant == AppActionVariant.ghost
              ? null
              : LinearGradient(colors: [colors.$1, colors.$2]),
          color: variant == AppActionVariant.ghost
              ? colors.$1.withValues(alpha: 0.08)
              : null,
          border: Border.all(
            color: colors.$1.withValues(
              alpha: variant == AppActionVariant.ghost ? 0.35 : 0.22,
            ),
          ),
          boxShadow: variant == AppActionVariant.ghost || disabled
              ? null
              : [
                  BoxShadow(
                    color: colors.$1.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: compact ? 18 : 21, color: foreground),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: PressableScale(onTap: disabled ? null : onPressed, child: button),
    );
  }

  (Color, Color) _variantColors() {
    switch (variant) {
      case AppActionVariant.reward:
        return (AppColors.rewardGold, AppColors.amber);
      case AppActionVariant.ghost:
        return (AppColors.scannerCyan, AppColors.scannerTeal);
      case AppActionVariant.danger:
        return (AppColors.error, AppColors.ember);
      case AppActionVariant.scanner:
        return (AppColors.scannerCyan, AppColors.scannerTeal);
    }
  }
}

class LensMark extends StatelessWidget {
  final double size;
  final double progress;
  final bool showCore;

  const LensMark({
    super.key,
    this.size = 96,
    this.progress = 1,
    this.showCore = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LensMarkPainter(progress: progress, showCore: showCore),
      ),
    );
  }
}

class CreaturePortrait extends StatelessWidget {
  final String type;
  final String rarity;
  final double size;
  final bool compact;
  final String? imageUrl;

  const CreaturePortrait({
    super.key,
    required this.type,
    required this.rarity,
    this.size = 132,
    this.compact = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.getTypeColor(type);
    final rarityColor = AppColors.getRarityColor(rarity);
    final glow = rarity.toLowerCase() == 'legendary'
        ? AppColors.rewardGold
        : typeColor;

    final imageBytes = _imageBytesFromDataUrl(imageUrl);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glow.withValues(alpha: 0.30),
                  typeColor.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.22),
                  blurRadius: compact ? 18 : 34,
                  spreadRadius: compact ? 1 : 5,
                ),
              ],
            ),
          ),
          if (imageBytes == null)
            CustomPaint(
              size: Size.square(size * 0.82),
              painter: _CreatureSilhouettePainter(
                typeColor: typeColor,
                rarityColor: rarityColor,
                rank: rarityRank(rarity),
              ),
            )
          else
            Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: rarityColor.withValues(alpha: 0.46),
                  width: compact ? 1.2 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.voidBlack.withValues(alpha: 0.38),
                    blurRadius: compact ? 10 : 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return CustomPaint(
                    size: Size.square(size * 0.72),
                    painter: _CreatureSilhouettePainter(
                      typeColor: typeColor,
                      rarityColor: rarityColor,
                      rank: rarityRank(rarity),
                    ),
                  );
                },
              ),
            ),
          Positioned(
            bottom: size * 0.16,
            right: size * 0.18,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.voidBlack.withValues(alpha: 0.72),
                border: Border.all(color: typeColor.withValues(alpha: 0.52)),
              ),
              child: Icon(typeIcon(type), color: typeColor, size: size * 0.13),
            ),
          ),
        ],
      ),
    );
  }

  Uint8List? _imageBytesFromDataUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final match = RegExp(
      r'^data:image\/[a-zA-Z0-9.+-]+;base64,([\s\S]+)$',
    ).firstMatch(value);
    if (match == null) return null;
    try {
      return base64Decode(match.group(1)!);
    } on FormatException {
      return null;
    }
  }
}

class TypeBadge extends StatelessWidget {
  final String type;
  final bool compact;

  const TypeBadge({super.key, required this.type, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getTypeColor(type);
    return _BadgeShell(
      icon: typeIcon(type),
      label: type,
      color: color,
      compact: compact,
    );
  }
}

class RarityBadge extends StatelessWidget {
  final String rarity;
  final bool compact;

  const RarityBadge({super.key, required this.rarity, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getRarityColor(rarity);
    return _BadgeShell(
      icon: rarity.toLowerCase() == 'legendary'
          ? Icons.workspace_premium_rounded
          : Icons.diamond_rounded,
      label: rarity,
      color: color,
      compact: compact,
      filled: rarity.toLowerCase() == 'legendary',
    );
  }
}

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? color : color.withValues(alpha: 0.09),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.9)
                : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.voidBlack : color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.voidBlack : color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.scannerCyan, size: 19),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.pearlMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0, 1),
                minHeight: 9,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class XpProgressStrip extends StatelessWidget {
  final int level;
  final int xp;
  final int xpToNext;
  final double progress;

  const XpProgressStrip({
    super.key,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.rewardGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rewardGold.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$level',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Field Rank',
                    style: TextStyle(
                      color: AppColors.pearl,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.rewardGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$xp/$xpToNext XP',
              style: const TextStyle(
                color: AppColors.pearlMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ScannerFrame extends StatelessWidget {
  final double progress;
  final bool locked;
  final bool analyzing;

  const ScannerFrame({
    super.key,
    this.progress = 0,
    this.locked = false,
    this.analyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerFramePainter(
        progress: progress,
        locked: locked,
        analyzing: analyzing,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class ConfidenceLabel extends StatelessWidget {
  final String label;
  final double confidence;
  final bool locked;

  const ConfidenceLabel({
    super.key,
    required this.label,
    required this.confidence,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = locked ? AppColors.rewardGold : AppColors.scannerCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.voidBlack.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            locked ? Icons.lock_rounded : Icons.center_focus_strong_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.pearl,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(confidence * 100).round()}%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class ShardChip extends StatelessWidget {
  final int count;

  const ShardChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.rewardGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rewardGold.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.hexagon_rounded,
            color: AppColors.rewardGold,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.rewardGold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeShell extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool compact;
  final bool filled;

  const _BadgeShell({
    required this.icon,
    required this.label,
    required this.color,
    this.compact = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: filled ? 0.8 : 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: filled ? AppColors.ink : color,
            size: compact ? 12 : 14,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: filled ? AppColors.ink : color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldGridPainter extends CustomPainter {
  final Color glowColor;
  final Alignment glowAlignment;

  _FieldGridPainter({required this.glowColor, required this.glowAlignment});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.scannerCyan.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final center = glowAlignment.alongSize(size);
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size.shortestSide * 0.72,
        [
          glowColor.withValues(alpha: 0.16),
          AppColors.rewardGold.withValues(alpha: 0.045),
          Colors.transparent,
        ],
        const [0, 0.46, 1],
      );
    canvas.drawRect(Offset.zero & size, glowPaint);

    final sweep = Paint()
      ..color = AppColors.scannerCyan.withValues(alpha: 0.05)
      ..strokeWidth = 2;
    canvas.save();
    canvas.translate(size.width * 0.18, size.height * 0.14);
    canvas.rotate(-0.35);
    canvas.drawLine(Offset.zero, Offset(size.width * 1.2, 0), sweep);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FieldGridPainter oldDelegate) {
    return oldDelegate.glowColor != glowColor ||
        oldDelegate.glowAlignment != glowAlignment;
  }
}

class _LensMarkPainter extends CustomPainter {
  final double progress;
  final bool showCore;

  _LensMarkPainter({required this.progress, required this.showCore});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.045
      ..shader = AppColors.scanGradient.createShader(Offset.zero & size);
    final dimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.018
      ..color = AppColors.scannerCyan.withValues(alpha: 0.18);

    canvas.drawCircle(center, radius * 0.88, dimPaint);
    canvas.drawCircle(center, radius * 0.62, dimPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.86),
      -math.pi / 2,
      math.pi * 1.7 * progress.clamp(0, 1),
      false,
      ringPaint,
    );

    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.72;
      final end =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.82;
      canvas.drawLine(start, end, dimPaint);
    }

    if (showCore) {
      final core = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius * 0.38,
          [
            AppColors.rewardGold.withValues(alpha: 0.96),
            AppColors.scannerTeal.withValues(alpha: 0.52),
            AppColors.scannerDeep.withValues(alpha: 0.22),
          ],
          const [0, 0.58, 1],
        );
      canvas.drawCircle(center, radius * 0.34, core);
      final irisPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.025
        ..color = AppColors.voidBlack.withValues(alpha: 0.55);
      canvas.drawCircle(center, radius * 0.18, irisPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LensMarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.showCore != showCore;
  }
}

class _CreatureSilhouettePainter extends CustomPainter {
  final Color typeColor;
  final Color rarityColor;
  final int rank;

  _CreatureSilhouettePainter({
    required this.typeColor,
    required this.rarityColor,
    required this.rank,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.15, size.height * 0.10),
        Offset(size.width * 0.88, size.height * 0.95),
        [
          typeColor.withValues(alpha: 0.95),
          rarityColor.withValues(alpha: 0.82),
          AppColors.pearl.withValues(alpha: 0.7),
        ],
        const [0, 0.58, 1],
      );
    final shadePaint = Paint()
      ..color = AppColors.voidBlack.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = AppColors.pearl.withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    final wing = Path()
      ..moveTo(center.dx - size.width * 0.05, center.dy + size.height * 0.04)
      ..quadraticBezierTo(
        size.width * 0.02,
        size.height * 0.12,
        size.width * 0.16,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.52,
        center.dx - size.width * 0.02,
        center.dy + size.height * 0.18,
      )
      ..close();
    final rightWing = Path()
      ..moveTo(center.dx + size.width * 0.05, center.dy + size.height * 0.04)
      ..quadraticBezierTo(
        size.width * 0.98,
        size.height * 0.12,
        size.width * 0.84,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.52,
        center.dx + size.width * 0.02,
        center.dy + size.height * 0.18,
      )
      ..close();

    if (rank >= 3) {
      canvas.drawPath(wing, bodyPaint);
      canvas.drawPath(rightWing, bodyPaint);
    }

    final body = Path()
      ..moveTo(center.dx, size.height * 0.18)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.24,
        size.width * 0.22,
        size.height * 0.74,
        center.dx,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.74,
        size.width * 0.82,
        size.height * 0.24,
        center.dx,
        size.height * 0.18,
      )
      ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.16),
        width: size.width * 0.42,
        height: size.height * 0.46,
      ),
      shadePaint,
    );

    final leftHorn = Path()
      ..moveTo(size.width * 0.39, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.23,
        size.height * 0.02,
        size.width * 0.32,
        size.height * 0.36,
      );
    final rightHorn = Path()
      ..moveTo(size.width * 0.61, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.77,
        size.height * 0.02,
        size.width * 0.68,
        size.height * 0.36,
      );
    canvas.drawPath(leftHorn, linePaint);
    canvas.drawPath(rightHorn, linePaint);

    final eyePaint = Paint()
      ..color = AppColors.voidBlack.withValues(alpha: 0.72);
    canvas.drawCircle(
      Offset(size.width * 0.43, size.height * 0.40),
      size.width * 0.035,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.57, size.height * 0.40),
      size.width * 0.035,
      eyePaint,
    );

    final runePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.022
      ..color = AppColors.scannerCyan.withValues(alpha: 0.55);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.12),
        width: size.width * 0.2,
        height: size.height * 0.2,
      ),
      0,
      math.pi * 1.5,
      false,
      runePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CreatureSilhouettePainter oldDelegate) {
    return oldDelegate.typeColor != typeColor ||
        oldDelegate.rarityColor != rarityColor ||
        oldDelegate.rank != rank;
  }
}

class _ScannerFramePainter extends CustomPainter {
  final double progress;
  final bool locked;
  final bool analyzing;

  _ScannerFramePainter({
    required this.progress,
    required this.locked,
    required this.analyzing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.74,
      height: size.height * 0.38,
    );
    final radius = Radius.circular(size.width * 0.065);
    final color = analyzing
        ? AppColors.rewardGold
        : locked
        ? AppColors.nature
        : AppColors.scannerCyan;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.78);
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.18);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), faint);

    const corner = 42.0;
    final path = Path()
      ..moveTo(rect.left, rect.top + corner)
      ..lineTo(rect.left, rect.top + radius.y)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + radius.x, rect.top)
      ..lineTo(rect.left + corner, rect.top)
      ..moveTo(rect.right - corner, rect.top)
      ..lineTo(rect.right - radius.x, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + radius.y)
      ..lineTo(rect.right, rect.top + corner)
      ..moveTo(rect.right, rect.bottom - corner)
      ..lineTo(rect.right, rect.bottom - radius.y)
      ..quadraticBezierTo(
        rect.right,
        rect.bottom,
        rect.right - radius.x,
        rect.bottom,
      )
      ..lineTo(rect.right - corner, rect.bottom)
      ..moveTo(rect.left + corner, rect.bottom)
      ..lineTo(rect.left + radius.x, rect.bottom)
      ..quadraticBezierTo(
        rect.left,
        rect.bottom,
        rect.left,
        rect.bottom - radius.y,
      )
      ..lineTo(rect.left, rect.bottom - corner);
    canvas.drawPath(path, stroke);

    final y = rect.top + rect.height * progress.clamp(0, 1);
    final scanPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(rect.left, y),
        Offset(rect.right, y),
        [
          Colors.transparent,
          color.withValues(alpha: analyzing ? 0.88 : 0.58),
          Colors.transparent,
        ],
        const [0, 0.5, 1],
      )
      ..strokeWidth = analyzing ? 4 : 2;
    canvas.drawLine(
      Offset(rect.left + 18, y),
      Offset(rect.right - 18, y),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.locked != locked ||
        oldDelegate.analyzing != analyzing;
  }
}
