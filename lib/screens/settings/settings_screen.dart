import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/sync_service.dart';
import '../../widgets/creature_lens_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dailyMissions = true;
  bool _rareAlerts = true;
  bool _streakReminder = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.scannerCyan,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  8,
                  MediaQuery.of(context).padding.top + 6,
                  20,
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
                        'Settings',
                        style: Theme.of(context).textTheme.headlineMedium,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Appearance',
                        icon: Icons.palette_rounded,
                      ),
                      const SizedBox(height: 14),
                      _ThemeToggle(
                        themeMode: themeMode,
                        onChanged: (mode) =>
                            ref.read(themeModeProvider.notifier).setMode(mode),
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
                        title: 'Notifications',
                        icon: Icons.notifications_rounded,
                      ),
                      const SizedBox(height: 10),
                      _SettingsSwitchTile(
                        icon: Icons.flag_rounded,
                        title: 'Daily missions',
                        subtitle: 'Morning field tasks and XP reminders',
                        value: _dailyMissions,
                        onChanged: (value) =>
                            setState(() => _dailyMissions = value),
                      ),
                      _SettingsSwitchTile(
                        icon: Icons.diamond_rounded,
                        title: 'Rare alerts',
                        subtitle: 'Rarity boosts, streak bonuses, and events',
                        value: _rareAlerts,
                        onChanged: (value) =>
                            setState(() => _rareAlerts = value),
                      ),
                      _SettingsSwitchTile(
                        icon: Icons.local_fire_department_rounded,
                        title: 'Streak reminder',
                        subtitle: 'A gentle ping before your streak expires',
                        value: _streakReminder,
                        onChanged: (value) =>
                            setState(() => _streakReminder = value),
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
                        title: 'Account',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 12),
                      _AccountRow(label: user.displayName, value: user.email),
                      const Divider(height: 22),
                      _SettingsLinkTile(
                        icon: Icons.cloud_sync_rounded,
                        title: 'Sync collection',
                        color: AppColors.scannerCyan,
                        onTap: _syncCollection,
                      ),
                      _SettingsLinkTile(
                        icon: Icons.lock_rounded,
                        title: 'Privacy controls',
                        color: AppColors.rewardGold,
                        onTap: () => context.pushNamed('privacyPermissions'),
                      ),
                      _SettingsLinkTile(
                        icon: Icons.policy_rounded,
                        title: 'Data and camera permissions',
                        color: AppColors.water,
                        onTap: () => context.pushNamed('privacyPermissions'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
                child: AppActionButton(
                  label: 'Return Home',
                  icon: Icons.home_rounded,
                  variant: AppActionVariant.ghost,
                  onPressed: () => context.goNamed('home'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncCollection() async {
    final summary = await ref.read(syncServiceProvider).syncPending();
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.voidBlack.withValues(alpha: 0.72),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: GlassPanel(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Sync collection',
                  icon: Icons.cloud_done_rounded,
                ),
                const SizedBox(height: 12),
                Text(
                  'Attempted ${summary.attempted}, synced ${summary.succeeded}, failed ${summary.failed}, pending ${summary.skipped}.',
                  style: const TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                AppActionButton(
                  label: 'Close',
                  icon: Icons.check_rounded,
                  compact: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeToggle({required this.themeMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.voidBlack.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ThemeChoice(
              icon: Icons.dark_mode_rounded,
              label: 'Dark',
              selected: themeMode == ThemeMode.dark,
              onTap: () => onChanged(ThemeMode.dark),
            ),
          ),
          Expanded(
            child: _ThemeChoice(
              icon: Icons.light_mode_rounded,
              label: 'Light',
              selected: themeMode == ThemeMode.light,
              onTap: () => onChanged(ThemeMode.light),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? AppColors.scannerTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.voidBlack : AppColors.pearlMuted,
              size: 18,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.voidBlack : AppColors.pearlMuted,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.scannerTeal.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: AppColors.scannerCyan, size: 20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.rewardGradient,
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.pearl,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.pearlMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SettingsLinkTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.pearl,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.pearlMuted,
            ),
          ],
        ),
      ),
    );
  }
}
