import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Desktop-compatible camera service that uses file selection instead of live camera
class DesktopCameraService {
  static const Duration _processInterval = Duration(milliseconds: 120);
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isProcessingFrame = false;
  
  // Mock camera state for compatibility
  bool _isInitialized = false;
  bool _isStreaming = false;
  StreamController<DesktopCameraImage>? _imageStreamController;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = const [];
  
  /// Check if camera is available (always true for desktop)
  bool get isAvailable => true;
  
  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;
  
  /// Check if camera is streaming
  bool get isStreaming => _isStreaming;
  
  /// Get image stream
  Stream<DesktopCameraImage>? get imageStream => _imageStreamController?.stream;

  /// Expose camera controller for preview
  CameraController? get cameraController => _cameraController;
  
  /// Initialize the desktop camera service
  Future<bool> initialize() async {
    try {
      _imageStreamController = StreamController<DesktopCameraImage>.broadcast();
      try {
        _cameras = await availableCameras();
        if (_cameras.isNotEmpty) {
          _cameraController = CameraController(
            _cameras.first,
            ResolutionPreset.medium,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.bgra8888,
          );
          await _cameraController!.initialize();
          _isInitialized = true;
          print('Windows camera initialized: \'${_cameras.first.name}\'');
          return true;
        } else {
          print('No cameras found; falling back to simulation');
          _isInitialized = true; // allow simulation
          return true;
        }
      } catch (e) {
        print('Camera init failed, simulation only: $e');
        _isInitialized = true; // allow simulation UI
        return true;
      }
    } catch (e) {
      print('Failed to initialize desktop camera service: $e');
      return false;
    }
  }
  
  /// Start image stream (simulated for desktop)
  Future<void> startImageStream(Function(DesktopCameraImage) onImage) async {
    if (!_isInitialized) {
      throw StateError('Camera not initialized');
    }
    
    _isStreaming = true;
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.startImageStream((CameraImage img) {
          // Convert minimal metadata to DesktopCameraImage for compatibility
          // Note: For real processing, map planes properly
          final bytesPerRow = img.planes.isNotEmpty ? img.planes[0].bytesPerRow : 0;
          final bytes = img.planes.isNotEmpty ? img.planes[0].bytes : Uint8List(0);
          final desktopImage = DesktopCameraImage(
            width: img.width,
            height: img.height,
            format: ImageFormat.bgra8888,
            planes: [DesktopImagePlane(bytes: bytes, bytesPerRow: bytesPerRow)],
          );
          onImage(desktopImage);
        });
        print('Windows camera image stream started');
      } catch (e) {
        print('Failed to start camera image stream, using simulation: $e');
        _imageStreamController?.stream.listen(onImage);
      }
    } else {
      _imageStreamController?.stream.listen(onImage);
      print('Simulation image stream started');
    }
  }
  
  /// Stop image stream
  Future<void> stopImageStream() async {
    _isStreaming = false;
    try {
      if (_cameraController != null && _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (_) {}
    _imageStreamController?.close();
    _imageStreamController = null;
    print('Desktop image stream stopped');
  }
  
  /// Pick a video file for analysis
  Future<String?> pickVideoFile() async {
    try {
      final result = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'videos',
            extensions: ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv'],
          ),
        ],
      );
      
      if (result != null) {
        print('Selected video file: ${result.path}');
        return result.path;
      }
      return null;
    } catch (e) {
      print('Error picking video file: $e');
      return null;
    }
  }
  
  /// Pick an image file for analysis
  Future<String?> pickImageFile() async {
    try {
      final result = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'images',
            extensions: ['jpg', 'jpeg', 'png', 'bmp'],
          ),
        ],
      );
      
      if (result != null) {
        print('Selected image file: ${result.path}');
        return result.path;
      }
      return null;
    } catch (e) {
      print('Error picking image file: $e');
      return null;
    }
  }
  
  /// Simulate camera image processing for desktop
  void simulateImageProcessing() {
    if (!_isStreaming) return;
    if (DateTime.now().difference(_lastProcessed) < _processInterval) return;
    if (_isProcessingFrame) return;
    
    _isProcessingFrame = true;
    _lastProcessed = DateTime.now();
    
    // Create a mock camera image
    final mockImage = DesktopCameraImage(
      width: 640,
      height: 480,
      format: ImageFormat.bgra8888,
      planes: [
        DesktopImagePlane(
          bytes: Uint8List.fromList(List.generate(640 * 480 * 4, (i) => i % 256)),
          bytesPerRow: 640 * 4,
        ),
      ],
    );
    
    _imageStreamController?.add(mockImage);
    _isProcessingFrame = false;
  }
  
  /// Dispose resources
  void dispose() {
    _isStreaming = false;
    _imageStreamController?.close();
    _imageStreamController = null;
    _isInitialized = false;
    try { _cameraController?.dispose(); } catch (_) {}
    _cameraController = null;
  }
}

/// Desktop-compatible camera image
class DesktopCameraImage {
  final int width;
  final int height;
  final ImageFormat format;
  final List<DesktopImagePlane> planes;
  
  DesktopCameraImage({
    required this.width,
    required this.height,
    required this.format,
    required this.planes,
  });
}

/// Desktop-compatible image plane
class DesktopImagePlane {
  final Uint8List bytes;
  final int bytesPerRow;
  
  DesktopImagePlane({
    required this.bytes,
    required this.bytesPerRow,
  });
}

/// Image format enum
enum ImageFormat {
  bgra8888,
  yuv420,
  nv21,
}

/// Desktop-compatible pose detector service
class DesktopPoseDetector {
  bool _isReady = false;
  
  bool get isReady => _isReady;
  
  /// Initialize pose detector
  Future<void> initialize() async {
    _isReady = true;
    print('Desktop pose detector initialized (mock)');
  }
  
  /// Process image for pose detection (mock implementation)
  Future<List<DesktopPose>> processImage(DesktopCameraImage image) async {
    if (!_isReady) return [];
    
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Return mock pose data
    return [
      DesktopPose(
        landmarks: _generateMockLandmarks(),
      ),
    ];
  }
  
  /// Generate mock landmarks for desktop testing
  Map<String, DesktopLandmark> _generateMockLandmarks() {
    return {
      'nose': DesktopLandmark(x: 0.5, y: 0.2, z: 0.0),
      'leftShoulder': DesktopLandmark(x: 0.4, y: 0.3, z: 0.0),
      'rightShoulder': DesktopLandmark(x: 0.6, y: 0.3, z: 0.0),
      'leftElbow': DesktopLandmark(x: 0.3, y: 0.4, z: 0.0),
      'rightElbow': DesktopLandmark(x: 0.7, y: 0.4, z: 0.0),
      'leftWrist': DesktopLandmark(x: 0.2, y: 0.5, z: 0.0),
      'rightWrist': DesktopLandmark(x: 0.8, y: 0.5, z: 0.0),
      'leftHip': DesktopLandmark(x: 0.4, y: 0.6, z: 0.0),
      'rightHip': DesktopLandmark(x: 0.6, y: 0.6, z: 0.0),
      'leftKnee': DesktopLandmark(x: 0.4, y: 0.8, z: 0.0),
      'rightKnee': DesktopLandmark(x: 0.6, y: 0.8, z: 0.0),
      'leftAnkle': DesktopLandmark(x: 0.4, y: 0.95, z: 0.0),
      'rightAnkle': DesktopLandmark(x: 0.6, y: 0.95, z: 0.0),
    };
  }
  
  void dispose() {
    _isReady = false;
  }
}

/// Desktop-compatible pose
class DesktopPose {
  final Map<String, DesktopLandmark> landmarks;
  
  DesktopPose({required this.landmarks});
}

/// Desktop-compatible landmark
class DesktopLandmark {
  final double x;
  final double y;
  final double z;
  
  DesktopLandmark({required this.x, required this.y, required this.z});
}
