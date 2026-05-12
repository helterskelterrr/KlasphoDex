import 'scan_label_stabilizer.dart';

enum ScanPhase { initializing, detecting, locked, analyzing, unavailable }

class ScanSessionState {
  const ScanSessionState({
    this.phase = ScanPhase.initializing,
    this.rearCamera = true,
    this.torchOn = false,
    this.liveLabels = const [],
    this.lockedLabels = const [],
    this.cameraError,
  });

  final ScanPhase phase;
  final bool rearCamera;
  final bool torchOn;
  final List<String> liveLabels;
  final List<String> lockedLabels;
  final String? cameraError;

  List<String> get displayLabels {
    if (lockedLabels.isNotEmpty) return lockedLabels;
    return liveLabels;
  }

  ScanSessionState copyWith({
    ScanPhase? phase,
    bool? rearCamera,
    bool? torchOn,
    List<String>? liveLabels,
    List<String>? lockedLabels,
    Object? cameraError = _sentinel,
  }) {
    return ScanSessionState(
      phase: phase ?? this.phase,
      rearCamera: rearCamera ?? this.rearCamera,
      torchOn: torchOn ?? this.torchOn,
      liveLabels: liveLabels ?? this.liveLabels,
      lockedLabels: lockedLabels ?? this.lockedLabels,
      cameraError: identical(cameraError, _sentinel)
          ? this.cameraError
          : cameraError as String?,
    );
  }

  static const _sentinel = Object();
}

class ScanSessionController {
  ScanSessionController({int requiredStableSamples = 3})
    : _stabilizer = ScanLabelStabilizer(
        requiredStableSamples: requiredStableSamples,
      );

  final ScanLabelStabilizer _stabilizer;
  ScanSessionState _state = const ScanSessionState();

  ScanSessionState get state => _state;

  ScanSessionState initializing() {
    _state = _state.copyWith(phase: ScanPhase.initializing, cameraError: null);
    return _state;
  }

  ScanSessionState cameraReady() {
    _state = _state.copyWith(
      phase: ScanPhase.detecting,
      torchOn: false,
      cameraError: null,
    );
    return _state;
  }

  ScanSessionState cameraUnavailable(String message) {
    _state = _state.copyWith(
      phase: ScanPhase.unavailable,
      cameraError: message,
    );
    return _state;
  }

  ScanSessionState beginAnalysis() {
    if (_state.phase == ScanPhase.analyzing) return _state;
    _state = _state.copyWith(phase: ScanPhase.analyzing);
    return _state;
  }

  ScanSessionState handleLiveLabels(List<String> labels) {
    if (labels.isEmpty || _state.phase == ScanPhase.analyzing) return _state;

    final snapshot = _stabilizer.addSample(labels);
    _state = _state.copyWith(
      liveLabels: snapshot.latestLabels,
      lockedLabels: snapshot.lockedLabels,
      phase: snapshot.isLocked ? ScanPhase.locked : ScanPhase.detecting,
    );
    return _state;
  }

  List<String> labelsForGeneration([List<String> finalLabels = const []]) {
    final labels = _stabilizer.labelsForFinalCapture(finalLabels);
    if (labels.isEmpty) return const ['unknown object 50%'];
    return labels;
  }

  ScanSessionState switchCamera() {
    _stabilizer.reset();
    _state = _state.copyWith(
      phase: ScanPhase.initializing,
      rearCamera: !_state.rearCamera,
      torchOn: false,
      liveLabels: const [],
      lockedLabels: const [],
      cameraError: null,
    );
    return _state;
  }

  ScanSessionState setTorch({required bool on}) {
    _state = _state.copyWith(torchOn: on);
    return _state;
  }
}
