import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Represents a single detected label from ML Kit.
class DetectedLabel {
  const DetectedLabel({required this.text, required this.confidence});

  final String text;
  final double confidence;

  /// Returns "Label XX%" format used by the rest of the app.
  String toDisplayString() => '$text ${(confidence * 100).round()}%';

  @override
  String toString() => toDisplayString();
}

/// Manages the camera lifecycle and ML Kit image labeling for live scanning.
///
/// Usage:
///   1. Call [initialize] to set up camera + ML Kit.
///   2. Listen to [labelStream] for real-time detected labels.
///   3. Call [captureStillImage] to grab the final photo bytes.
///   4. Call [dispose] when done.
class LiveScannerService {
  LiveScannerService({this.confidenceThreshold = 0.55});

  /// Labels below this confidence are filtered out.
  final double confidenceThreshold;

  CameraController? _cameraController;
  ImageLabeler? _imageLabeler;
  bool _isProcessing = false;
  bool _disposed = false;

  final _labelController = StreamController<List<DetectedLabel>>.broadcast();

  /// Stream of detected labels, updated in real-time from the camera feed.
  Stream<List<DetectedLabel>> get labelStream => _labelController.stream;

  /// The active camera controller (for displaying the preview widget).
  CameraController? get cameraController => _cameraController;

  /// Whether the camera has been initialized and is ready.
  bool get isReady => _cameraController?.value.isInitialized == true;

  /// Whether the torch (flashlight) is currently on.
  bool get isTorchOn => _torchOn;
  bool _torchOn = false;

  /// Whether the rear camera is active.
  bool get isRearCamera => _rearCamera;
  bool _rearCamera = true;

  List<CameraDescription> _cameras = [];

  /// Initialize the camera and ML Kit labeler.
  ///
  /// Returns `true` on success, `false` if no cameras are available.
  Future<bool> initialize() async {
    if (_disposed) return false;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return false;

      _imageLabeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: confidenceThreshold),
      );

      await _initCamera(_findCamera());
      return true;
    } catch (e) {
      debugPrint('LiveScannerService.initialize error: $e');
      return false;
    }
  }

  /// Switch between front and rear cameras.
  Future<void> switchCamera() async {
    _rearCamera = !_rearCamera;
    _torchOn = false;
    await _stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
    await _initCamera(_findCamera());
  }

  /// Toggle the torch on/off.
  Future<void> toggleTorch() async {
    if (_cameraController == null || !isReady) return;
    try {
      _torchOn = !_torchOn;
      await _cameraController!.setFlashMode(
        _torchOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Torch toggle failed: $e');
      _torchOn = false;
    }
  }

  /// Capture a still image and return its bytes.
  Future<Uint8List?> captureStillImage() async {
    if (_cameraController == null || !isReady) return null;
    try {
      // Pause the image stream before taking a picture
      await _stopImageStream();
      final xFile = await _cameraController!.takePicture();
      return await xFile.readAsBytes();
    } catch (e) {
      debugPrint('captureStillImage error: $e');
      return null;
    }
  }

  /// Pause the live label detection stream (call before navigating away).
  Future<void> pauseDetection() async {
    await _stopImageStream();
  }

  /// Resume the live label detection stream.
  Future<void> resumeDetection() async {
    _startImageStream();
  }

  /// Clean up all resources.
  Future<void> dispose() async {
    _disposed = true;
    await _stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
    _imageLabeler?.close();
    _imageLabeler = null;
    await _labelController.close();
  }

  // ── Private ──

  CameraDescription _findCamera() {
    final direction =
        _rearCamera ? CameraLensDirection.back : CameraLensDirection.front;
    return _cameras.firstWhere(
      (cam) => cam.lensDirection == direction,
      orElse: () => _cameras.first,
    );
  }

  Future<void> _initCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _cameraController!.initialize();
      if (_disposed) return;
      _startImageStream();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _startImageStream() {
    if (_cameraController == null ||
        !isReady ||
        _disposed ||
        _imageLabeler == null) {
      return;
    }

    try {
      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint('startImageStream error: $e');
    }
  }

  Future<void> _stopImageStream() async {
    try {
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('stopImageStream error: $e');
    }
  }

  void _processCameraImage(CameraImage image) {
    if (_isProcessing || _disposed || _imageLabeler == null) return;
    _isProcessing = true;

    _runLabeling(image).then((labels) {
      if (!_disposed && !_labelController.isClosed) {
        _labelController.add(labels);
      }
      _isProcessing = false;
    }).catchError((Object error) {
      debugPrint('ML Kit labeling error: $error');
      _isProcessing = false;
    });
  }

  Future<List<DetectedLabel>> _runLabeling(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
    if (inputImage == null) return const [];

    final labels = await _imageLabeler!.processImage(inputImage);
    return labels
        .where((label) => label.confidence >= confidenceThreshold)
        .map(
          (label) => DetectedLabel(
            text: label.label,
            confidence: label.confidence,
          ),
        )
        .toList(growable: false);
  }

  InputImage? _convertCameraImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    // Build InputImageMetadata
    final sensorOrientation = camera.sensorOrientation;
    final rotation = _rotationFromSensor(sensorOrientation);
    if (rotation == null) return null;

    final format = _mapImageFormat(image.format.group);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImageRotation? _rotationFromSensor(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return null;
    }
  }

  InputImageFormat? _mapImageFormat(ImageFormatGroup group) {
    switch (group) {
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv_420_888;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      default:
        return null;
    }
  }
}
