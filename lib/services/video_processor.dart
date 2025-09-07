import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/reference_video.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;

class VideoProcessor {
  static const _uuid = Uuid();
  final ImagePicker _picker = ImagePicker();
  final PoseDetector _poseDetector;

  VideoProcessor({required PoseDetector poseDetector}) : _poseDetector = poseDetector;

  /// Request necessary permissions for video access
  Future<bool> requestPermissions() async {
    try {
      // Android 13+: READ_MEDIA_VIDEO; Older: READ_EXTERNAL_STORAGE
      final statuses = await [
        Permission.videos, // maps to READ_MEDIA_VIDEO on Android 13+
        Permission.storage, // for older Androids
      ].request();

      final granted = (statuses[Permission.videos]?.isGranted ?? false) ||
          (statuses[Permission.storage]?.isGranted ?? false);

      if (!granted) {
        print('Media/storage permission not granted');
      }
      return granted;
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  /// Pick a video from gallery or file system
  Future<XFile?> pickVideo() async {
    try {
      // For host PC, we'll simulate file selection
      // In a real implementation, you'd use a file picker that works with host PC
      print('Note: For host PC access, you may need to manually specify the video path');
      
      // For now, return null to indicate no file selected
      // You can modify this to accept a file path from your host PC
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
      await videoFile.saveTo(videoPath);

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

  /// Extract pose data from video frames
  Future<List<PoseFrame>> _extractPoseSequence(String videoPath) async {
    final List<PoseFrame> frames = [];
    int frameIndex = 0;
    
    try {
      // For now, we'll simulate frame extraction
      // In a real implementation, you'd use video_player to extract frames
      // and process them with the pose detector
      
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

  /// Generate mock landmarks for demo purposes
  Map<String, Landmark> _generateMockLandmarks() {
    return {
      'nose': Landmark(x: 0.5, y: 0.2, z: 0.0),
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
    return (math.acos(cosAngle.clamp(-1.0, 1.0)) * 180 / 3.14159);
  }

  /// Compute distance between two landmarks
  double _distance(Landmark a, Landmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    final dz = a.z - b.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
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

// Helper function for acos
double acos(double x) => math.acos(x);
double sqrt(double x) => math.sqrt(x);
