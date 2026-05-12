import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/creature_lens_widgets.dart';

class PrivacyPermissionsScreen extends StatelessWidget {
  const PrivacyPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.water,
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
                        'Privacy',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
              sliver: SliverList.list(
                children: const [
                  _PolicyBlock(
                    icon: Icons.camera_alt_rounded,
                    title: 'Camera',
                    body:
                        'CreatureLens uses camera access only when you capture a scan photo. The selected photo is sent to the AI provider for creature generation.',
                  ),
                  SizedBox(height: 12),
                  _PolicyBlock(
                    icon: Icons.image_search_rounded,
                    title: 'Vision scan',
                    body:
                        'The demo build sends a generic scan label and the final scan image to the AI provider. Real-time YOLO detection is not used.',
                  ),
                  SizedBox(height: 12),
                  _PolicyBlock(
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI generation',
                    body:
                        'Creature generation uses OpenRouter/Gemma in the class demo. Production builds should move this behind a backend proxy.',
                  ),
                  SizedBox(height: 12),
                  _PolicyBlock(
                    icon: Icons.cloud_sync_rounded,
                    title: 'Cloud sync',
                    body:
                        'Your collection, decks, and trial results can sync to Firestore under your Firebase user id so local data can be recovered later.',
                  ),
                  SizedBox(height: 12),
                  _PolicyBlock(
                    icon: Icons.person_rounded,
                    title: 'Anonymous account',
                    body:
                        'The MVP signs you in anonymously. This creates a stable private user id without asking for email or social login.',
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

class _PolicyBlock extends StatelessWidget {
  const _PolicyBlock({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.scannerCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.pearl,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.pearlMuted,
                    fontSize: 13,
                    height: 1.4,
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
