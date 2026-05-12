class ScanLabelSnapshot {
  final List<String> latestLabels;
  final List<String> lockedLabels;
  final String primaryLabel;
  final int stableSamples;
  final bool isLocked;

  const ScanLabelSnapshot({
    required this.latestLabels,
    required this.lockedLabels,
    required this.primaryLabel,
    required this.stableSamples,
    required this.isLocked,
  });

  static const empty = ScanLabelSnapshot(
    latestLabels: [],
    lockedLabels: [],
    primaryLabel: '',
    stableSamples: 0,
    isLocked: false,
  );
}

class ScanLabelStabilizer {
  final int requiredStableSamples;

  ScanLabelSnapshot _snapshot = ScanLabelSnapshot.empty;
  String _lastPrimaryLabel = '';
  int _stableSamples = 0;

  ScanLabelStabilizer({this.requiredStableSamples = 3})
    : assert(requiredStableSamples > 0);

  ScanLabelSnapshot get snapshot => _snapshot;

  ScanLabelSnapshot addSample(List<String> labels) {
    final cleanedLabels = labels
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);

    if (cleanedLabels.isEmpty) {
      _snapshot = ScanLabelSnapshot(
        latestLabels: const [],
        lockedLabels: _snapshot.lockedLabels,
        primaryLabel: _snapshot.primaryLabel,
        stableSamples: _stableSamples,
        isLocked: _snapshot.isLocked,
      );
      return _snapshot;
    }

    final primaryLabel = _normalizeLabel(cleanedLabels.first);
    if (primaryLabel == _lastPrimaryLabel) {
      _stableSamples += 1;
    } else {
      _lastPrimaryLabel = primaryLabel;
      _stableSamples = 1;
    }

    final shouldLock =
        _snapshot.isLocked || _stableSamples >= requiredStableSamples;
    final lockedLabels = _snapshot.isLocked
        ? _snapshot.lockedLabels
        : shouldLock
        ? cleanedLabels
        : const <String>[];

    _snapshot = ScanLabelSnapshot(
      latestLabels: cleanedLabels,
      lockedLabels: lockedLabels,
      primaryLabel: primaryLabel,
      stableSamples: _stableSamples,
      isLocked: shouldLock,
    );
    return _snapshot;
  }

  List<String> labelsForFinalCapture([List<String> finalLabels = const []]) {
    final cleanedFinalLabels = finalLabels
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);
    if (cleanedFinalLabels.isNotEmpty) return cleanedFinalLabels;
    if (_snapshot.lockedLabels.isNotEmpty) return _snapshot.lockedLabels;
    return _snapshot.latestLabels;
  }

  void reset() {
    _snapshot = ScanLabelSnapshot.empty;
    _lastPrimaryLabel = '';
    _stableSamples = 0;
  }

  String _normalizeLabel(String label) {
    return label.replaceFirst(RegExp(r'\s+\d+(?:\.\d+)?%$'), '').trim();
  }
}
