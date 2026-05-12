import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/creature_lens_widgets.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/pokedex')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('home');
        break;
      case 1:
        context.pushNamed('scan');
        break;
      case 2:
        context.goNamed('pokedex');
        break;
      case 3:
        context.goNamed('profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          radius: 24,
          borderColor: AppColors.scannerCyan.withValues(alpha: 0.14),
          color: AppColors.surface.withValues(alpha: 0.88),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
              ),
              Expanded(child: _ScanNavItem(onTap: () => _onTap(context, 1))),
              Expanded(
                child: _NavItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Pokedex',
                  isSelected: currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanNavItem extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanNavItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.scanGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.scannerCyan.withValues(alpha: 0.36),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: AppColors.voidBlack,
              size: 25,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Scan',
            style: TextStyle(
              color: AppColors.scannerCyan,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? AppColors.scannerTeal.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.scannerCyan : AppColors.pearlMuted,
              size: 23,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? AppColors.scannerCyan
                    : AppColors.pearlMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
