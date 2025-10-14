import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/reference_video.dart';
import 'desktop_camera_service.dart';

/// Desktop-compatible video processor
class DesktopVideoProcessor {
  static const _uuid = Uuid();

  /// Request permissions (desktop doesn't need permissions)
  Future<bool> requestPermissions() async {
    // Desktop doesn't require permissions for file access
    return true;
  }

  /// Pick a video from file system
  Future<XFile?> pickVideo() async {
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
        return XFile(result.path);
      }
      return null;
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  /// Process video from host PC file path
  Future<ReferenceVideo?> processVideoFromPath({
    required String filePath,
    required String exerciseType,
    required String title,
    String? description,
  }) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist: $filePath');
        return null;
      }

      // Check file extension
      final extension = filePath.split('.').last.toLowerCase();
      final validExtensions = ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv'];
      if (!validExtensions.contains(extension)) {
        print('Invalid file type: $extension. Supported formats: ${validExtensions.join(', ')}');
        return null;
      }

      // Check file size (max 100MB)
      final fileSize = await file.length();
      if (fileSize > 100 * 1024 * 1024) {
        print('File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB. Max size: 100MB');
        return null;
      }

      print('Processing video: $filePath (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)');

      // Copy video to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${appDir.path}/reference_videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final videoId = _uuid.v4();
      final videoPath = '${videoDir.path}/$videoId.$extension';
      await file.copy(videoPath);

      print('Video copied to: $videoPath');

      // Extract frames and pose data
      final poseSequence = await _extractPoseSequence(filePath);
      if (poseSequence.isEmpty) {
        print('No pose data extracted from video');
        // Clean up if no poses detected
        await File(videoPath).delete();
        return null;
      }

      print('Extracted ${poseSequence.length} pose frames');

      return ReferenceVideo(
        id: videoId,
        exerciseType: exerciseType,
        title: title,
        description: description,
        videoPath: videoPath,
        createdAt: DateTime.now(),
        poseSequence: poseSequence,
        metadata: {
          'originalPath': filePath,
          'frameCount': poseSequence.length,
          'duration': poseSequence.last.timestamp,
          'fileSize': fileSize,
          'extension': extension,
        },
      );
    } catch (e) {
      print('Error processing video from path: $e');
      return null;
    }
  }

  /// Process video and extract pose data
  Future<ReferenceVideo?> processVideo({
    required String exerciseType,
    required String title,
    String? description,
  }) async {
    try {
      // Pick video
      final videoFile = await pickVideo();
      if (videoFile == null) return null;

      // Copy video to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${appDir.path}/reference_videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final videoId = _uuid.v4();
      final videoPath = '${videoDir.path}/$videoId.mp4';
      await File(videoFile.path).copy(videoPath);

      // Extract frames and pose data
      final poseSequence = await _extractPoseSequence(videoFile.path);
      if (poseSequence.isEmpty) {
        // Clean up if no poses detected
        await File(videoPath).delete();
        return null;
      }

      return ReferenceVideo(
        id: videoId,
        exerciseType: exerciseType,
        title: title,
        description: description,
        videoPath: videoPath,
        createdAt: DateTime.now(),
        poseSequence: poseSequence,
        metadata: {
          'originalPath': videoFile.path,
          'frameCount': poseSequence.length,
          'duration': poseSequence.last.timestamp,
        },
      );
    } catch (e) {
      print('Error processing video: $e');
      return null;
    }
  }

  /// Extract pose data from video frames (desktop mock implementation)
  Future<List<PoseFrame>> _extractPoseSequence(String videoPath) async {
    final List<PoseFrame> frames = [];
    int frameIndex = 0;
    
    try {
      // For desktop, we'll simulate frame extraction
      // In a real implementation, you'd use a video processing library
      
      // Simulate processing every 100ms (10 FPS)
      const frameInterval = Duration(milliseconds: 100);
      double currentTime = 0.0;
      
      while (currentTime < 30.0) { // Limit to 30 seconds for demo
        // Simulate pose detection
        final landmarks = _generateMockLandmarks();
        final angles = _computeAngles(landmarks);
        final features = _computeFeatures(landmarks);
        
        frames.add(PoseFrame(
          frameIndex: frameIndex++,
          timestamp: currentTime,
          landmarks: landmarks,
          computedAngles: angles,
          features: features,
        ));
        
        currentTime += frameInterval.inMilliseconds / 1000.0;
      }
      
      return frames;
    } catch (e) {
      print('Error extracting pose sequence: $e');
      return [];
    }
  }

  /// Generate mock landmarks for desktop demo purposes
  Map<String, Landmark> _generateMockLandmarks() {
    return {
      'nose': Landmark(x: 0.5, y: 0.2, z: 0.1),
      'leftShoulder': Landmark(x: 0.4, y: 0.3, z: 0.0),
      'rightShoulder': Landmark(x: 0.6, y: 0.3, z: 0.0),
      'leftElbow': Landmark(x: 0.3, y: 0.4, z: 0.0),
      'rightElbow': Landmark(x: 0.7, y: 0.4, z: 0.0),
      'leftWrist': Landmark(x: 0.2, y: 0.5, z: 0.0),
      'rightWrist': Landmark(x: 0.8, y: 0.5, z: 0.0),
      'leftHip': Landmark(x: 0.4, y: 0.6, z: 0.0),
      'rightHip': Landmark(x: 0.6, y: 0.6, z: 0.0),
      'leftKnee': Landmark(x: 0.4, y: 0.8, z: 0.0),
      'rightKnee': Landmark(x: 0.6, y: 0.8, z: 0.0),
      'leftAnkle': Landmark(x: 0.4, y: 0.95, z: 0.0),
      'rightAnkle': Landmark(x: 0.6, y: 0.95, z: 0.0),
    };
  }

  /// Compute joint angles from landmarks
  Map<String, double> _computeAngles(Map<String, Landmark> landmarks) {
    final angles = <String, double>{};
    
    // Knee angles
    if (landmarks.containsKey('leftHip') && 
        landmarks.containsKey('leftKnee') && 
        landmarks.containsKey('leftAnkle')) {
      angles['leftKnee'] = _computeAngle(
        landmarks['leftHip']!,
        landmarks['leftKnee']!,
        landmarks['leftAnkle']!,
      );
    }
    
    if (landmarks.containsKey('rightHip') && 
        landmarks.containsKey('rightKnee') && 
        landmarks.containsKey('rightAnkle')) {
      angles['rightKnee'] = _computeAngle(
        landmarks['rightHip']!,
        landmarks['rightKnee']!,
        landmarks['rightAnkle']!,
      );
    }
    
    // Elbow angles
    if (landmarks.containsKey('leftShoulder') && 
        landmarks.containsKey('leftElbow') && 
        landmarks.containsKey('leftWrist')) {
      angles['leftElbow'] = _computeAngle(
        landmarks['leftShoulder']!,
        landmarks['leftElbow']!,
        landmarks['leftWrist']!,
      );
    }
    
    if (landmarks.containsKey('rightShoulder') && 
        landmarks.containsKey('rightElbow') && 
        landmarks.containsKey('rightWrist')) {
      angles['rightElbow'] = _computeAngle(
        landmarks['rightShoulder']!,
        landmarks['rightElbow']!,
        landmarks['rightWrist']!,
      );
    }
    
    return angles;
  }

  /// Compute angle between three points
  double _computeAngle(Landmark a, Landmark b, Landmark c) {
    final ab = _distance(a, b);
    final bc = _distance(b, c);
    final ac = _distance(a, c);
    
    if (ab == 0 || bc == 0) return 0.0;
    
    final cosAngle = (ab * ab + bc * bc - ac * ac) / (2 * ab * bc);
    return (acos(cosAngle.clamp(-1.0, 1.0)) * 180 / 3.14159);
  }

  /// Compute distance between two landmarks
  double _distance(Landmark a, Landmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    final dz = a.z - b.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }

  /// Compute additional features
  Map<String, dynamic> _computeFeatures(Map<String, Landmark> landmarks) {
    final features = <String, dynamic>{};
    
    // Check if wrists are above head
    if (landmarks.containsKey('nose') && 
        landmarks.containsKey('leftWrist') && 
        landmarks.containsKey('rightWrist')) {
      final noseY = landmarks['nose']!.y;
      features['leftWristAboveHead'] = landmarks['leftWrist']!.y < noseY;
      features['rightWristAboveHead'] = landmarks['rightWrist']!.y < noseY;
    }
    
    // Ankle distance
    if (landmarks.containsKey('leftAnkle') && landmarks.containsKey('rightAnkle')) {
      features['ankleDistance'] = _distance(landmarks['leftAnkle']!, landmarks['rightAnkle']!);
    }
    
    return features;
  }
}

// Helper functions for math operations
double acos(double x) => x > 1.0 ? 0.0 : x < -1.0 ? 3.14159 : 3.14159 / 2 - atan(x / sqrt(1 - x * x));
double atan(double x) => x == 0.0 ? 0.0 : x > 0 ? 3.14159 / 4 : -3.14159 / 4; // Simplified
double sqrt(double x) => x < 0 ? 0.0 : x == 0 ? 0.0 : x; // Simplified for demo
