import 'package:creature_lens/services/scan_label_stabilizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScanLabelStabilizer', () {
    test('locks after the same primary label appears in enough samples', () {
      final stabilizer = ScanLabelStabilizer(requiredStableSamples: 3);

      final first = stabilizer.addSample(const [
        'ceramic mug 91%',
        'plant 73%',
      ]);
      final second = stabilizer.addSample(const [
        'ceramic mug 89%',
        'tableware 76%',
      ]);
      final third = stabilizer.addSample(const ['ceramic mug 94%', 'cup 82%']);

      expect(first.isLocked, isFalse);
      expect(second.isLocked, isFalse);
      expect(third.isLocked, isTrue);
      expect(third.primaryLabel, 'ceramic mug');
      expect(third.lockedLabels, const ['ceramic mug 94%', 'cup 82%']);
    });

    test('resets stability when the primary label changes', () {
      final stabilizer = ScanLabelStabilizer(requiredStableSamples: 2);

      expect(stabilizer.addSample(const ['ceramic mug 91%']).isLocked, isFalse);
      expect(stabilizer.addSample(const ['plant 88%']).isLocked, isFalse);
      expect(stabilizer.addSample(const ['plant 86%']).isLocked, isTrue);
      expect(stabilizer.snapshot.primaryLabel, 'plant');
    });

    test('uses locked labels for final generation when available', () {
      final stabilizer = ScanLabelStabilizer(requiredStableSamples: 2);

      stabilizer.addSample(const ['glasses 82%', 'portrait 73%']);
      stabilizer.addSample(const ['glasses 91%', 'face profile 80%']);
      stabilizer.addSample(const ['book 90%', 'paper 79%']);

      expect(stabilizer.labelsForFinalCapture(), const [
        'glasses 91%',
        'face profile 80%',
      ]);
    });

    test('falls back to the latest labels when no lock exists', () {
      final stabilizer = ScanLabelStabilizer(requiredStableSamples: 3);

      stabilizer.addSample(const ['plant leaf 81%', 'flowerpot 72%']);

      expect(stabilizer.labelsForFinalCapture(), const [
        'plant leaf 81%',
        'flowerpot 72%',
      ]);
    });
  });
}
