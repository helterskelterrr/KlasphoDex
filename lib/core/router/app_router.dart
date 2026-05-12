import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/creature.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/scan/scan_screen.dart';
import '../../screens/reveal/creature_reveal_screen.dart';
import '../../screens/pokedex/pokedex_screen.dart';
import '../../screens/creature_detail/creature_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/privacy_permissions_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/deckbuilder/deck_builder_screen.dart';
import '../../screens/deckbuilder/trial_setup_screen.dart';
import '../../screens/deckbuilder/battle_screen.dart';
import '../../screens/deckbuilder/trial_result_screen.dart';
import '../../models/trial_result.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // App Shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: '/pokedex',
            name: 'pokedex',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PokedexScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
        ],
      ),

      // Scan (full-screen, no bottom nav)
      GoRoute(
        path: '/scan',
        name: 'scan',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ScanScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // Creature Reveal (full-screen)
      GoRoute(
        path: '/reveal',
        name: 'reveal',
        pageBuilder: (context, state) {
          final creature = state.extra as Creature?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CreatureRevealScreen(creature: creature),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeIn,
                    ),
                    child: child,
                  );
                },
          );
        },
      ),

      // Creature Detail
      GoRoute(
        path: '/creature/:id',
        name: 'creatureDetail',
        pageBuilder: (context, state) {
          final creature = state.extra as Creature?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CreatureDetailScreen(creature: creature),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/settings/privacy',
        name: 'privacyPermissions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PrivacyPermissionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/field-trials/deck',
        name: 'fieldDeck',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DeckBuilderScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/field-trials/setup',
        name: 'fieldSetup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TrialSetupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/field-trials/battle',
        name: 'fieldBattle',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BattleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/field-trials/result',
        name: 'fieldResult',
        pageBuilder: (context, state) {
          final result = state.extra as TrialResult?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: TrialResultScreen(result: result),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
    ],
  );
});
