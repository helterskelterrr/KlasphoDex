import 'package:creature_lens/services/scan_session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScanSessionController', () {
    test('moves from detecting to locked after stable labels', () {
      final controller = ScanSessionController(requiredStableSamples: 2);

      controller.cameraReady();
      controller.handleLiveLabels(const ['ceramic mug 90%']);
      final locked = controller.handleLiveLabels(const ['ceramic mug 94%']);

      expect(locked.phase, ScanPhase.locked);
      expect(locked.liveLabels, const ['ceramic mug 94%']);
      expect(locked.lockedLabels, const ['ceramic mug 94%']);
      expect(locked.displayLabels, const ['ceramic mug 94%']);
    });

    test('ignores empty live labels without clearing current labels', () {
      final controller = ScanSessionController(requiredStableSamples: 2);

      controller.cameraReady();
      controller.handleLiveLabels(const ['plant 82%']);
      final state = controller.handleLiveLabels(const []);

      expect(state.phase, ScanPhase.detecting);
      expect(state.liveLabels, const ['plant 82%']);
    });

    test('uses final labels before locked or live labels for generation', () {
      final controller = ScanSessionController(requiredStableSamples: 2);

      controller.cameraReady();
      controller.handleLiveLabels(const ['plant 82%']);

      expect(controller.labelsForGeneration(const ['book 91%']), const [
        'book 91%',
      ]);
      expect(controller.labelsForGeneration(), const ['plant 82%']);
    });

    test('falls back to unknown object when no labels exist', () {
      final controller = ScanSessionController();

      expect(controller.labelsForGeneration(), const ['unknown object 50%']);
    });

    test('resets labels and torch state for camera switch', () {
      final controller = ScanSessionController(requiredStableSamples: 1);

      controller.cameraReady();
      controller.handleLiveLabels(const ['plant 82%']);
      controller.setTorch(on: true);
      final state = controller.switchCamera();

      expect(state.rearCamera, isFalse);
      expect(state.torchOn, isFalse);
      expect(state.liveLabels, isEmpty);
      expect(state.lockedLabels, isEmpty);
      expect(state.phase, ScanPhase.initializing);
    });

    test('stores camera errors as unavailable state', () {
      final controller = ScanSessionController();

      final state = controller.cameraUnavailable('Camera permission denied.');

      expect(state.phase, ScanPhase.unavailable);
      expect(state.cameraError, 'Camera permission denied.');
    });
  });
}
