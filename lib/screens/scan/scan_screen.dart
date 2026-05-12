import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/gemini_service.dart';
import '../../services/live_scanner_service.dart';
import '../../services/scan_session_controller.dart';
import '../../widgets/creature_lens_widgets.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _maxGenerationImageBytes = 3 * 1024 * 1024;

  late final AnimationController _scanLineController;
  final _imagePicker = ImagePicker();
  final _session = ScanSessionController(requiredStableSamples: 3);
  final _scanner = LiveScannerService(confidenceThreshold: 0.50);

  ScanSessionState _scanState = const ScanSessionState();
  Uint8List? _previewBytes;
  List<DetectedLabel> _liveLabels = [];
  StreamSubscription<List<DetectedLabel>>? _labelSub;
  bool _cameraPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanLineController.dispose();
    _labelSub?.cancel();
    _scanner.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _scanner.pauseDetection();
    } else if (state == AppLifecycleState.resumed) {
      if (_scanState.phase != ScanPhase.analyzing) {
        _scanner.resumeDetection();
      }
    }
  }

  Future<void> _initializeCamera() async {
    setState(() => _scanState = _session.initializing());

    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _cameraPermissionDenied = true;
          _scanState = _session.cameraUnavailable(
            'Camera permission denied. Use gallery instead.',
          );
        });
      }
      return;
    }

    final success = await _scanner.initialize();
    if (!mounted) return;

    if (success) {
      _labelSub = _scanner.labelStream.listen(_onLabelsDetected);
      setState(() => _scanState = _session.cameraReady());
    } else {
      setState(() {
        _scanState = _session.cameraUnavailable(
          'No camera available. Use gallery instead.',
        );
      });
    }
  }

  void _onLabelsDetected(List<DetectedLabel> labels) {
    if (!mounted || _scanState.phase == ScanPhase.analyzing) return;

    final labelStrings = labels.map((l) => l.toDisplayString()).toList();
    setState(() {
      _liveLabels = labels;
      _scanState = _session.handleLiveLabels(labelStrings);
    });
  }

  Future<void> _capture() async {
    if (_scanState.phase == ScanPhase.analyzing) return;

    setState(() => _scanState = _session.beginAnalysis());

    final bytes = await _scanner.captureStillImage();
    if (bytes == null || !mounted) {
      setState(() => _scanState = _session.cameraReady());
      return;
    }

    setState(() => _previewBytes = bytes);

    // Use locked labels from ML Kit if available, otherwise fallback
    final labelsForGen = _session.labelsForGeneration();
    final imageBase64 = _base64ForGeneration(bytes);

    debugPrint(
      'Live scan captured: labels=$labelsForGen, bytes=${bytes.length}, '
      'imageAttached=${imageBase64 != null}',
    );

    await _generateFromLabels(
      labelsForGen,
      imageBase64: imageBase64,
      imageMimeType: 'image/jpeg',
    );
  }

  Future<void> _pickFromGallery() async {
    if (_scanState.phase == ScanPhase.analyzing) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 1280,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      _previewBytes = bytes;
      _scanState = _session.beginAnalysis();
    });

    final imageBase64 = _base64ForGeneration(bytes);
    await _generateFromLabels(
      ['gallery image 100%'],
      imageBase64: imageBase64,
      imageMimeType: picked.mimeType ?? 'image/jpeg',
    );
  }

  Future<void> _switchCamera() async {
    await _scanner.switchCamera();
    if (mounted) {
      setState(() {
        _liveLabels = [];
        _scanState = _session.switchCamera();
        // Re-mark camera as ready after switch
        _scanState = _session.cameraReady();
      });
    }
  }

  Future<void> _toggleTorch() async {
    await _scanner.toggleTorch();
    if (mounted) {
      setState(() {
        _scanState = _session.setTorch(on: _scanner.isTorchOn);
      });
    }
  }

  Future<void> _generateFromLabels(
    List<String> finalLabels, {
    String? imageBase64,
    String? imageMimeType,
  }) async {
    final user = ref.read(userProvider);
    final creature = await ref.read(geminiServiceProvider).generateCreature(
      labels: finalLabels,
      userId: user.uid,
      userLevel: user.level,
      streakMultiplier: user.currentStreak,
      imageBase64: imageBase64,
      imageMimeType: imageMimeType,
    );

    if (mounted) context.pushNamed('reveal', extra: creature);
  }

  String? _base64ForGeneration(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > _maxGenerationImageBytes) return null;
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final status = switch (_scanState.phase) {
      ScanPhase.analyzing => ('ANALYZING', AppColors.rewardGold),
      ScanPhase.locked => ('TARGET LOCKED', AppColors.rewardGold),
      ScanPhase.unavailable => ('CAMERA OFFLINE', AppColors.error),
      ScanPhase.initializing => ('INITIALIZING', AppColors.pearlMuted),
      ScanPhase.detecting => ('LIVE SCANNING', AppColors.scannerCyan),
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // === Camera Preview or Fallback ===
          Positioned.fill(child: _buildCameraPreview()),

          // === Scanner Frame Overlay ===
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanLineController,
              builder: (context, child) {
                return ScannerFrame(
                  progress: _scanLineController.value,
                  locked: _scanState.phase == ScanPhase.locked,
                  analyzing: _scanState.phase == ScanPhase.analyzing,
                );
              },
            ),
          ),

          // === Gradient Vignette ===
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.62),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // === Live Labels Overlay ===
          if (_liveLabels.isNotEmpty &&
              _scanState.phase != ScanPhase.analyzing)
            Positioned(
              left: 20,
              right: 20,
              top: MediaQuery.of(context).size.height * 0.32,
              child: _LiveLabelsOverlay(
                labels: _liveLabels,
                locked: _scanState.phase == ScanPhase.locked,
              ),
            ),

          // === Top Bar ===
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            right: 14,
            child: Row(
              children: [
                _RoundIconButton(
                  icon: Icons.close_rounded,
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('home');
                    }
                  },
                ),
                const SizedBox(width: 8),
                if (_scanner.isReady &&
                    _scanState.phase != ScanPhase.analyzing) ...[
                  _RoundIconButton(
                    icon: _scanner.isTorchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    onTap: _toggleTorch,
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(
                    icon: Icons.flip_camera_android_rounded,
                    onTap: _switchCamera,
                  ),
                ],
                const Spacer(),
                _StatusPill(label: status.$1, color: status.$2),
              ],
            ),
          ),

          // === Bottom Controls ===
          Positioned(
            left: 22,
            right: 22,
            bottom: MediaQuery.of(context).padding.bottom + 22,
            child: Column(
              children: [
                // Info panel
                GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  radius: 20,
                  color: AppColors.voidBlack.withValues(alpha: 0.58),
                  borderColor: status.$2.withValues(alpha: 0.22),
                  child: Row(
                    children: [
                      Icon(
                        _scanState.phase == ScanPhase.analyzing
                            ? Icons.auto_awesome_rounded
                            : _scanState.phase == ScanPhase.locked
                                ? Icons.lock_rounded
                                : Icons.center_focus_strong_rounded,
                        color: status.$2,
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _helperMessage,
                          style: const TextStyle(
                            color: AppColors.pearl,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: status.$2.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: status.$2.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PulsingDot(color: status.$2),
                            const SizedBox(width: 5),
                            Text(
                              'ML KIT',
                              style: TextStyle(
                                color: status.$2,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundIconButton(
                      icon: Icons.photo_library_rounded,
                      onTap: _pickFromGallery,
                    ),
                    const SizedBox(width: 30),
                    _CaptureButton(
                      analyzing: _scanState.phase == ScanPhase.analyzing,
                      locked: _scanState.phase == ScanPhase.locked,
                      onTap: _capture,
                    ),
                    const SizedBox(width: 30),
                    const SizedBox(width: 46, height: 46),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    // Show captured image during analysis
    if (_previewBytes != null && _scanState.phase == ScanPhase.analyzing) {
      return Image.memory(_previewBytes!, fit: BoxFit.cover);
    }

    // Show live camera preview
    if (_scanner.isReady && _scanner.cameraController != null) {
      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _scanner.cameraController!.value.previewSize?.height ?? 1,
              height: _scanner.cameraController!.value.previewSize?.width ?? 1,
              child: CameraPreview(_scanner.cameraController!),
            ),
          ),
        ),
      );
    }

    // Fallback: dark background with lens mark
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF03070B), Color(0xFF07151A), Color(0xFF010204)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LensMark(
              size: MediaQuery.of(context).size.shortestSide * 0.32,
              progress: 0.78,
            ),
            if (_cameraPermissionDenied) ...[
              const SizedBox(height: 24),
              const Text(
                'Camera access needed',
                style: TextStyle(
                  color: AppColors.pearl,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Grant camera permission or use gallery.',
                style: TextStyle(
                  color: AppColors.pearlMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings, size: 18),
                label: const Text('Open Settings'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.scannerCyan,
                ),
              ),
            ] else if (_scanState.phase == ScanPhase.initializing) ...[
              const SizedBox(height: 24),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.scannerCyan),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Starting camera…',
                style: TextStyle(
                  color: AppColors.pearlMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _helperMessage {
    if (_scanState.cameraError != null) return _scanState.cameraError!;
    return switch (_scanState.phase) {
      ScanPhase.analyzing => 'Photo captured. Synthesizing creature…',
      ScanPhase.locked =>
        'Target locked: ${_scanState.displayLabels.take(2).join(', ')}. Tap to capture!',
      ScanPhase.detecting =>
        _liveLabels.isEmpty
            ? 'Point camera at an object. ML Kit scanning…'
            : 'Detecting: ${_liveLabels.take(2).map((l) => l.text).join(', ')}',
      ScanPhase.unavailable =>
        'Camera is unavailable. Choose a gallery photo.',
      ScanPhase.initializing => 'Starting camera…',
    };
  }
}

// ─── Live Labels Overlay ─────────────────────────────────────────────────

class _LiveLabelsOverlay extends StatelessWidget {
  const _LiveLabelsOverlay({required this.labels, required this.locked});

  final List<DetectedLabel> labels;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: labels.take(5).map((label) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - value)),
                child: child,
              ),
            );
          },
          child: ConfidenceLabel(
            label: label.text,
            confidence: label.confidence,
            locked: locked,
          ),
        );
      }).toList(),
    );
  }
}

// ─── Pulsing Dot ─────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.5 + _controller.value * 0.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _controller.value),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Capture Button ──────────────────────────────────────────────────────

class _CaptureButton extends StatelessWidget {
  final bool analyzing;
  final bool locked;
  final VoidCallback onTap;

  const _CaptureButton({
    required this.analyzing,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = analyzing
        ? AppColors.rewardGold
        : locked
            ? AppColors.rewardGold
            : AppColors.scannerCyan;

    return PressableScale(
      onTap: analyzing ? null : onTap,
      pressedScale: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.pearl, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.36),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: analyzing ? 46 : locked ? 66 : 62,
            height: analyzing ? 46 : locked ? 66 : 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: analyzing || locked
                  ? AppColors.rewardGradient
                  : AppColors.scanGradient,
            ),
            child: analyzing
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.ink),
                    ),
                  )
                : locked
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.voidBlack,
                        size: 32,
                      )
                    : const Icon(
                        Icons.center_focus_strong_rounded,
                        color: AppColors.voidBlack,
                        size: 28,
                      ),
          ),
        ),
      ),
    );
  }
}

// ─── Round Icon Button ───────────────────────────────────────────────────

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.voidBlack.withValues(alpha: 0.54),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: AppColors.pearl, size: 22),
      ),
    );
  }
}

// ─── Status Pill ─────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.voidBlack.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.62),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
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
