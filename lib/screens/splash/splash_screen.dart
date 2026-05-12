import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/creature_lens_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lensController;
  late final AnimationController _contentController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _lensController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
    unawaited(_start());
  }

  Future<void> _start() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) _contentController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (mounted) context.goNamed('home');
  }

  @override
  void dispose() {
    _lensController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreatureLensBackground(
        glowColor: AppColors.rewardGold,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: AnimatedBuilder(
                        animation: _lensController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 164,
                                height: 164,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.scannerCyan.withValues(
                                        alpha: 0.28,
                                      ),
                                      blurRadius: 46,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              LensMark(
                                size: 142,
                                progress: _lensController.value,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.scanGradient.createShader(bounds),
                        child: const Text(
                          'CreatureLens',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Scan. Awaken. Collect.',
                        style: TextStyle(
                          color: AppColors.pearlMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fade,
                  child: GlassPanel(
                    padding: const EdgeInsets.all(14),
                    radius: 18,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.rewardGold,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _lensController,
                                builder: (context, child) {
                                  final states = [
                                    'Calibrating scanner',
                                    'Indexing field journal',
                                    'Charging rarity matrix',
                                  ];
                                  final index =
                                      (_lensController.value * states.length)
                                          .floor()
                                          .clamp(0, states.length - 1);
                                  return Text(
                                    states[index],
                                    style: const TextStyle(
                                      color: AppColors.pearl,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  );
                                },
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _lensController,
                              builder: (context, child) {
                                return Text(
                                  '${(_lensController.value * 100).round()}%',
                                  style: const TextStyle(
                                    color: AppColors.scannerCyan,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: AnimatedBuilder(
                            animation: _lensController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                minHeight: 6,
                                value: _lensController.value,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.08,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.scannerCyan,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
