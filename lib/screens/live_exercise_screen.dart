import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show WriteBuffer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math.dart' as vmath;
// Camera
import 'package:camera/camera.dart';
// MediaPipe via ML Kit
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// Video processing and pose comparison
import '../models/reference_video.dart';
import '../services/video_processor.dart';
import '../services/pose_comparator.dart';
import '../widgets/split_view.dart';

enum ExerciseType { squats, pushups, jumpingJacks, yoga }

enum SessionState { idle, running, paused, finished }

// Minimal landmark representation (top-level to satisfy Dart constraints)
class _Landmark {
  final double x;
  final double y;
  final double z;
  _Landmark(this.x, this.y, this.z);
}

class LiveExerciseScreen extends StatefulWidget {
  const LiveExerciseScreen({super.key});

  @override
  State<LiveExerciseScreen> createState() => _LiveExerciseScreenState();
}

class _LiveExerciseScreenState extends State<LiveExerciseScreen> {
  // Camera
  CameraController? _cameraController;
  bool _isCameraInitializing = false;
  List<CameraDescription> _availableCameras = [];
  CameraLensDirection _currentLens = CameraLensDirection.front;

  // ML Kit Pose Detector (MediaPipe under the hood)
  PoseDetector? _poseDetector;
  bool _isDetectorReady = false;

  // Session state
  SessionState _sessionState = SessionState.idle;
  ExerciseType _selectedExercise = ExerciseType.squats;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  // Metrics
  int _repCount = 0;
  double _formScoreAccum = 0.0;
  int _formScoreSamples = 0;
  final List<String> _realtimeFeedback = [];

  // Rep detection toggles
  bool _isInDownPhase = false;

  // Frame throttling
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration _processInterval = const Duration(milliseconds: 120);
  DateTime _lastMotionAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isProcessingFrame = false;

  // Reference capture
  bool _isRecordingReference = false;
  final List<Map<String, dynamic>> _referenceFrames = [];
  bool _hasReference = false;

  // Guided session
  bool _isGuided = false;
  List<Map<String, dynamic>> _loadedReferenceFrames = [];
  Map<String, double> _referenceSummary = {};
  // Reference capture stats and watchdog
  int _refFramesCount = 0;
  int _refValidFramesCount = 0;
  Timer? _refWatchdog;

  // Video processing and reference management
  VideoProcessor? _videoProcessor;
  ReferenceVideo? _selectedReferenceVideo;
  List<ReferenceVideo> _availableReferences = [];
  bool _isProcessingVideo = false;
  static const String _prefsKeyLastRefId = 'last_selected_reference_id';

  Future<void> _persistLastSelectedReference(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_prefsKeyLastRefId);
    } else {
      await prefs.setString(_prefsKeyLastRefId, id);
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Initialize camera
    setState(() => _isCameraInitializing = true);
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      print('Available cameras: ${_availableCameras.length}');
      
      final selected = _selectCamera(_currentLens);
      print('Selected camera: ${selected.name} (${selected.lensDirection})');
      
      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      print('Initializing camera controller...');
      await controller.initialize();
      print('Camera controller initialized successfully');
      
      if (mounted) {
        print('Starting image stream...');
        await controller.startImageStream(_onCameraImage);
        print('Image stream started successfully');
        setState(() => _cameraController = controller);
      }
    } catch (e) {
      print('Camera initialization error: $e');
      // Camera not available; UI will show a warning
    } finally {
      if (mounted) {
        setState(() => _isCameraInitializing = false);
      }
    }

    // Initialize ML Kit PoseDetector
    try {
      print('Initializing pose detector...');
      final options = PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      );
      _poseDetector = PoseDetector(options: options);
      setState(() => _isDetectorReady = true);
      print('Pose detector initialized successfully');
      
      // Initialize video processor
      _videoProcessor = VideoProcessor(poseDetector: _poseDetector!);
      print('Video processor initialized successfully');
    } catch (e) {
      print('Pose detector initialization error: $e');
      setState(() => _isDetectorReady = false);
    }
  }

  CameraDescription _selectCamera(CameraLensDirection preferred) {
    if (_availableCameras.isEmpty) {
      throw StateError('No cameras available');
    }
    final match = _availableCameras.where((c) => c.lensDirection == preferred);
    if (match.isNotEmpty) return match.first;
    return _availableCameras.first;
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.isEmpty) return;
    final newLens = _currentLens == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    _currentLens = newLens;
    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}
    await _cameraController?.dispose();
    setState(() => _cameraController = null);
    setState(() => _isCameraInitializing = true);
    try {
      final selected = _selectCamera(_currentLens);
      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      await controller.startImageStream(_onCameraImage);
      setState(() => _cameraController = controller);
    } catch (_) {
      // ignore
    } finally {
      setState(() => _isCameraInitializing = false);
    }
  }

  Map<String, dynamic>? _buildFeatureSnapshot(Map<String, _Landmark> lms) {
    final kneeL = _jointAngle(lms, 'hipLeft', 'kneeLeft', 'ankleLeft');
    final kneeR = _jointAngle(lms, 'hipRight', 'kneeRight', 'ankleRight');
    final elbowL = _jointAngle(lms, 'shoulderLeft', 'elbowLeft', 'wristLeft');
    final elbowR = _jointAngle(lms, 'shoulderRight', 'elbowRight', 'wristRight');
    final hipL = _jointAngle(lms, 'shoulderLeft', 'hipLeft', 'kneeLeft');
    final hipR = _jointAngle(lms, 'shoulderRight', 'hipRight', 'kneeRight');
    final headY = _verticalPosition(lms, 'head');
    final wristLY = _verticalPosition(lms, 'wristLeft');
    final wristRY = _verticalPosition(lms, 'wristRight');
    final ankleDist = _horizontalDistance(lms, 'ankleLeft', 'ankleRight');
    if ([kneeL, kneeR, elbowL, elbowR, hipL, hipR].every((v) => v == null)) return null;
    return {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'angles': {
        if (kneeL != null) 'kneeL': kneeL,
        if (kneeR != null) 'kneeR': kneeR,
        if (elbowL != null) 'elbowL': elbowL,
        if (elbowR != null) 'elbowR': elbowR,
        if (hipL != null) 'hipL': hipL,
        if (hipR != null) 'hipR': hipR,
      },
      'features': {
        'wristAboveHeadL': wristLY < headY,
        'wristAboveHeadR': wristRY < headY,
        'ankleDist': ankleDist,
      }
    };
  }

  Future<void> _startReferenceRecording() async {
    if (!_isDetectorReady || _poseDetector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pose detector not ready. Please wait...')),
      );
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not ready. Please wait...')),
      );
      return;
    }

    setState(() {
      _isRecordingReference = true;
      _referenceFrames.clear();
      _refFramesCount = 0;
      _refValidFramesCount = 0;
      _lastMotionAt = DateTime.now();
    });

    print('Started reference recording...');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recording reference... Perform clean reps')),
    );
    
    _refWatchdog?.cancel();
    _refWatchdog = Timer.periodic(const Duration(seconds: 1), (_) {
      // Auto-stop if no motion (no new valid frames) for 5s
      if (!_isRecordingReference) return;
      final timeSinceMotion = DateTime.now().difference(_lastMotionAt);
      print('Time since last motion: ${timeSinceMotion.inSeconds}s');
      
      if (timeSinceMotion > const Duration(seconds: 5)) {
        print('Auto-stopping reference recording due to no motion');
        _stopReferenceRecording();
      }
    });
  }

  Future<void> _stopReferenceRecording() async {
    setState(() => _isRecordingReference = false);
    _refWatchdog?.cancel();
    if (_referenceFrames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reference captured')),
      );
      return;
    }
    final data = jsonEncode({
      'exercise': _selectedExercise.name,
      'capturedAt': DateTime.now().toIso8601String(),
      'frames': _referenceFrames,
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exercise_ref_${_selectedExercise.name}', data);
    setState(() => _hasReference = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reference saved (${_referenceFrames.length} frames, valid $_refValidFramesCount)')),
    );
  }

  /// Show dialog for choosing reference method
  Future<void> _showReferenceOptions() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reference'),
        content: const Text('Choose how to add a reference:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startReferenceRecording();
            },
            child: const Text('Record Reference'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadReferenceVideo();
            },
            child: const Text('Upload Video'),
          ),
        ],
      ),
    );
  }

  /// Upload reference video from gallery
  Future<void> _uploadReferenceVideo() async {
    if (_videoProcessor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video processor not ready')),
      );
      return;
    }

    setState(() => _isProcessingVideo = true);

    try {
      // Request permissions
      final hasPermissions = await _videoProcessor!.requestPermissions();
      if (!hasPermissions) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera and storage permissions required')),
        );
        return;
      }

      // Show dialog for video details
      final result = await _showVideoUploadDialog();
      if (result == null) return;

      // Validate file path
      final filePath = result['filePath']!;
      if (!_isValidVideoFile(filePath)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid video file. Please check the file path and format.')),
        );
        return;
      }

      final referenceVideo = await _videoProcessor!.processVideoFromPath(
        filePath: result['filePath']!,
        exerciseType: result['exerciseType']!,
        title: result['title']!,
        description: result['description']!.isEmpty ? null : result['description'],
      );

      if (referenceVideo != null) {
        // Save reference video
        final prefs = await SharedPreferences.getInstance();
        final key = 'reference_video_${referenceVideo.id}';
        await prefs.setString(key, jsonEncode(referenceVideo.toJson()));
        
        // Update state
        setState(() {
          _selectedReferenceVideo = referenceVideo;
          _hasReference = true;
        });
        // Persist selection
        await _persistLastSelectedReference(referenceVideo.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reference video uploaded: ${referenceVideo.title}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process video')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading video: $e')),
      );
    } finally {
      setState(() => _isProcessingVideo = false);
    }
  }

  /// Show dialog for video upload details
  Future<Map<String, String>?> _showVideoUploadDialog() async {
    ExerciseType selectedExerciseType = _selectedExercise;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final filePathController = TextEditingController(
      text: 'C:\\Users\\YourUsername\\Videos\\exercise_video.mp4', // Default path for Windows
    );

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Reference Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ExerciseType>(
              value: selectedExerciseType,
              decoration: const InputDecoration(labelText: 'Exercise Type'),
              items: ExerciseType.values.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedExerciseType = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                hintText: 'e.g., Perfect Squat Form',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: filePathController,
              decoration: const InputDecoration(
                labelText: 'Video File Path (Host PC)',
                hintText: 'C:\\Users\\Username\\Videos\\video.mp4',
                helperText: 'Enter the full path to your video file on your computer. Supported formats: MP4, AVI, MOV, MKV, WMV, FLV. Max size: 100MB',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Professional trainer demonstration',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty && 
                  filePathController.text.trim().isNotEmpty) {
                Navigator.of(context).pop({
                  'exerciseType': selectedExerciseType.name,
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'filePath': filePathController.text.trim(),
                });
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReference();
    _loadAvailableReferences();
  }

  void _onCameraImage(CameraImage image) {
    if (_sessionState != SessionState.running && !_isRecordingReference) return;
    if (DateTime.now().difference(_lastProcessed) < _processInterval) return;
    if (_isProcessingFrame) return; // Drop frame if still processing
    _isProcessingFrame = true;
    _lastProcessed = DateTime.now();

    if (!_isDetectorReady || _poseDetector == null || _cameraController == null) {
      print('Camera image processing skipped: detector=${_isDetectorReady}, poseDetector=${_poseDetector != null}, controller=${_cameraController != null}');
      _isProcessingFrame = false;
      return;
    }

    try {
      // Validate image dimensions
      if (image.width <= 0 || image.height <= 0) {
        print('Invalid image dimensions: ${image.width}x${image.height}');
        _isProcessingFrame = false;
        return;
      }

      // Validate image planes
      if (image.planes.isEmpty) {
        print('No image planes available');
        _isProcessingFrame = false;
        return;
      }

      print('Processing camera image: ${image.width}x${image.height}, format: ${image.format.raw}');

      // Convert CameraImage to InputImage for ML Kit
      final bytes = _concatenatePlanes(image.planes);
      if (bytes.isEmpty) {
        print('Failed to concatenate image planes');
        _isProcessingFrame = false;
        return;
      }

      final InputImageRotation rotation = _cameraRotationToInputRotation(_cameraController!.description.sensorOrientation);
      final InputImageFormat format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.isNotEmpty ? image.planes.first.bytesPerRow : 0,
        ),
      );

      print('InputImage created successfully, processing poses...');
      _detectPoses(inputImage).whenComplete(() {
        _isProcessingFrame = false;
      });
    } catch (e) {
      print('Error processing camera image: $e');
      _isProcessingFrame = false;
      // Don't crash the app, just log the error
    }
  }

  Future<void> _detectPoses(InputImage inputImage) async {
    if (_poseDetector == null) return;
    try {
      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isEmpty) return;
      final pose = poses.first;
      final landmarkMap = <String, _Landmark>{};
      for (final type in PoseLandmarkType.values) {
        final lm = pose.landmarks[type];
        if (lm != null) {
          landmarkMap[_mapTypeToKey(type)] = _Landmark(lm.x, lm.y, lm.z);
        }
      }
      if (_isRecordingReference) {
        final snapshot = _buildFeatureSnapshot(landmarkMap);
        if (snapshot != null) {
          _referenceFrames.add(snapshot);
          _refValidFramesCount++;
          _lastMotionAt = DateTime.now();
          print('Reference frame captured: $_refValidFramesCount valid frames');
        }
        _refFramesCount++;
      }
      if (_isGuided && _hasReference) {
        _guidedFeedback(landmarkMap);
      }
      _processPose(landmarkMap);
    } catch (_) {
      // ignore frame errors
    }
  }

  void _guidedFeedback(Map<String, _Landmark> lms) {
    // Compare current angles to reference summary and push tips
    // Simple rule-based comparison for now
    String? tip;
    switch (_selectedExercise) {
      case ExerciseType.squats:
        final knee = _jointAngle(lms, 'hipLeft', 'kneeLeft', 'ankleLeft')
            ?? _jointAngle(lms, 'hipRight', 'kneeRight', 'ankleRight');
        if (knee != null) {
          final minRef = _referenceSummary['kneeL_min'] ?? _referenceSummary['kneeR_min'] ?? 100.0;
          final maxRef = _referenceSummary['kneeL_max'] ?? _referenceSummary['kneeR_max'] ?? 160.0;
          if (knee > maxRef + 10) tip = 'Go deeper on the squat';
          if (knee < minRef - 10) tip = 'Don\'t go too deep; protect your knees';
        }
        break;
      case ExerciseType.pushups:
        final elbow = _jointAngle(lms, 'shoulderLeft', 'elbowLeft', 'wristLeft')
            ?? _jointAngle(lms, 'shoulderRight', 'elbowRight', 'wristRight');
        if (elbow != null) {
          final minRef = _referenceSummary['elbowL_min'] ?? _referenceSummary['elbowR_min'] ?? 70.0;
          final maxRef = _referenceSummary['elbowL_max'] ?? _referenceSummary['elbowR_max'] ?? 160.0;
          if (elbow > maxRef + 10) tip = 'Lower further for full range';
          if (elbow < minRef - 10) tip = 'Don\'t over-bend elbows';
        }
        break;
      case ExerciseType.jumpingJacks:
        final handsUp = _verticalPosition(lms, 'wristLeft') < _verticalPosition(lms, 'head') &&
            _verticalPosition(lms, 'wristRight') < _verticalPosition(lms, 'head');
        final ankleDist = _horizontalDistance(lms, 'ankleLeft', 'ankleRight');
        final refAnk = _referenceSummary['ankleDist_avg'] ?? 0.3;
        if (!handsUp) tip = 'Raise arms fully overhead';
        if (ankleDist < refAnk * 0.8) tip = 'Spread feet wider';
        break;
      case ExerciseType.yoga:
        final hip = _jointAngle(lms, 'shoulderLeft', 'hipLeft', 'kneeLeft')
            ?? _jointAngle(lms, 'shoulderRight', 'hipRight', 'kneeRight');
        final refHip = _referenceSummary['hipL_avg'] ?? _referenceSummary['hipR_avg'] ?? 180.0;
        if (hip != null && hip < refHip - 10) tip = 'Lengthen your spine and open chest';
        break;
    }
    if (tip != null) _pushRealtimeFeedback(tip);
  }

  String _mapTypeToKey(PoseLandmarkType type) {
    switch (type) {
      case PoseLandmarkType.leftShoulder:
        return 'shoulderLeft';
      case PoseLandmarkType.rightShoulder:
        return 'shoulderRight';
      case PoseLandmarkType.leftElbow:
        return 'elbowLeft';
      case PoseLandmarkType.rightElbow:
        return 'elbowRight';
      case PoseLandmarkType.leftWrist:
        return 'wristLeft';
      case PoseLandmarkType.rightWrist:
        return 'wristRight';
      case PoseLandmarkType.leftHip:
        return 'hipLeft';
      case PoseLandmarkType.rightHip:
        return 'hipRight';
      case PoseLandmarkType.leftKnee:
        return 'kneeLeft';
      case PoseLandmarkType.rightKnee:
        return 'kneeRight';
      case PoseLandmarkType.leftAnkle:
        return 'ankleLeft';
      case PoseLandmarkType.rightAnkle:
        return 'ankleRight';
      case PoseLandmarkType.nose:
        return 'head';
      default:
        return type.toString();
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  InputImageRotation _cameraRotationToInputRotation(int sensorOrientation) {
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
        return InputImageRotation.rotation0deg;
    }
  }

  void _processPose(Map<String, _Landmark> landmarks) {
    // Compute relevant angles/distances
    double? primaryAngle;
    String? formTip;

    bool motionDetected = false;
    switch (_selectedExercise) {
      case ExerciseType.squats:
        // Use left side by default; fall back to right if missing
        primaryAngle = _jointAngle(landmarks, 'hipLeft', 'kneeLeft', 'ankleLeft')
            ?? _jointAngle(landmarks, 'hipRight', 'kneeRight', 'ankleRight');
        if (primaryAngle != null) {
          // Down when knee angle < 90, up when > 160
          if (!_isInDownPhase && primaryAngle < 100) {
            _isInDownPhase = true;
            motionDetected = true;
          }
          if (_isInDownPhase && primaryAngle > 160) {
            _repCount += 1;
            _isInDownPhase = false;
            motionDetected = true;
          }
          if (primaryAngle < 70) formTip = 'Don\'t go too deep. Keep knees safe.';
          if (primaryAngle > 180) formTip = 'Locking knees; keep a slight bend.';
          _accumulateFormScore(_scoreFromAngle(primaryAngle, target: 120, tolerance: 30));
        }
        break;
      case ExerciseType.pushups:
        primaryAngle = _jointAngle(landmarks, 'shoulderLeft', 'elbowLeft', 'wristLeft')
            ?? _jointAngle(landmarks, 'shoulderRight', 'elbowRight', 'wristRight');
        if (primaryAngle != null) {
          // Down when elbow angle < 70, up when > 160
          if (!_isInDownPhase && primaryAngle < 80) {
            _isInDownPhase = true;
            motionDetected = true;
          }
          if (_isInDownPhase && primaryAngle > 160) {
            _repCount += 1;
            _isInDownPhase = false;
            motionDetected = true;
          }
          if (primaryAngle > 170) formTip = 'Don\'t hyperextend elbows at top.';
          _accumulateFormScore(_scoreFromAngle(primaryAngle, target: 100, tolerance: 40));
        }
        break;
      case ExerciseType.jumpingJacks:
        final handsUp = _verticalPosition(landmarks, 'wristLeft') < _verticalPosition(landmarks, 'head') &&
            _verticalPosition(landmarks, 'wristRight') < _verticalPosition(landmarks, 'head');
        final feetApart = _horizontalDistance(landmarks, 'ankleLeft', 'ankleRight') >
            _horizontalDistance(landmarks, 'hipLeft', 'hipRight') * 1.4;
        if (!_isInDownPhase && handsUp && feetApart) {
          _isInDownPhase = true;
          motionDetected = true;
        }
        if (_isInDownPhase && !handsUp && !feetApart) {
          _repCount += 1;
          _isInDownPhase = false;
          motionDetected = true;
        }
        if (!handsUp) formTip = 'Raise arms fully overhead.';
        if (!feetApart) formTip = 'Spread feet wider.';
        _accumulateFormScore((handsUp ? 0.5 : 0.0) + (feetApart ? 0.5 : 0.0));
        break;
      case ExerciseType.yoga:
        primaryAngle = _jointAngle(landmarks, 'shoulderLeft', 'hipLeft', 'kneeLeft')
            ?? _jointAngle(landmarks, 'shoulderRight', 'hipRight', 'kneeRight');
        if (primaryAngle != null) {
          _accumulateFormScore(_scoreFromAngle(primaryAngle, target: 180, tolerance: 20));
          if (primaryAngle < 160) formTip = 'Lengthen your spine; open the chest.';
          motionDetected = true;
        }
        break;
    }

    if (formTip != null) {
      _pushRealtimeFeedback(formTip);
    }
    if (motionDetected) {
      _lastMotionAt = DateTime.now();
    }
    setState(() {});
  }

  // Helpers for scoring and angles
  void _accumulateFormScore(double score) {
    _formScoreAccum += score.clamp(0.0, 1.0);
    _formScoreSamples += 1;
  }

  double _scoreFromAngle(double angle, {required double target, required double tolerance}) {
    final diff = (angle - target).abs();
    if (diff >= tolerance) return 0.0;
    return 1.0 - (diff / tolerance);
  }

  double? _jointAngle(Map<String, _Landmark> lms, String a, String b, String c) {
    final A = lms[a];
    final B = lms[b];
    final C = lms[c];
    if (A == null || B == null || C == null) return null;
    final ba = vmath.Vector2(A.x - B.x, A.y - B.y);
    final bc = vmath.Vector2(C.x - B.x, C.y - B.y);
    final dot = ba.dot(bc);
    final mag = ba.length * bc.length;
    if (mag == 0) return null;
    final cos = (dot / mag).clamp(-1.0, 1.0);
    return vmath.degrees(math.acos(cos));
  }

  double _verticalPosition(Map<String, _Landmark> lms, String key) => lms[key]?.y ?? double.infinity;
  double _horizontalDistance(Map<String, _Landmark> lms, String k1, String k2) {
    final a = lms[k1];
    final b = lms[k2];
    if (a == null || b == null) return 0.0;
    return (a.x - b.x).abs();
  }

  Future<bool> _loadReference() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exercise_ref_${_selectedExercise.name}');
    if (raw == null) {
      setState(() {
        _hasReference = false;
        _loadedReferenceFrames = [];
        _referenceSummary = {};
      });
      return false;
    }
    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      final List frames = data['frames'] as List? ?? [];
      final parsed = frames.cast<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final summary = _computeReferenceSummary(parsed);
      setState(() {
        _loadedReferenceFrames = parsed;
        _referenceSummary = summary;
        _hasReference = parsed.isNotEmpty;
      });
      return _hasReference;
    } catch (_) {
      setState(() {
        _hasReference = false;
        _loadedReferenceFrames = [];
        _referenceSummary = {};
      });
      return false;
    }
  }

  /// Load available reference videos from storage
  Future<void> _loadAvailableReferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final referenceKeys = keys.where((key) => key.startsWith('reference_video_'));
      
      final Map<String, ReferenceVideo> byId = {};
      for (final key in referenceKeys) {
        try {
          final raw = prefs.getString(key);
          if (raw != null) {
            final data = jsonDecode(raw) as Map<String, dynamic>;
            final video = ReferenceVideo.fromJson(data);
            byId[video.id] = video; // de-duplicate by id
          }
        } catch (e) {
          print('Error loading reference video $key: $e');
        }
      }
      
      final lastRefId = prefs.getString(_prefsKeyLastRefId);

      setState(() {
        _availableReferences = byId.values.toList();
        // if currently selected is no longer in list, clear selection
        if (_selectedReferenceVideo != null &&
            !_availableReferences.any((v) => v.id == _selectedReferenceVideo!.id)) {
          _selectedReferenceVideo = null;
          _hasReference = false;
        }
        // Restore last selection if available
        if (_selectedReferenceVideo == null && lastRefId != null) {
          final restored = _availableReferences.where((v) => v.id == lastRefId).toList();
          if (restored.isNotEmpty) {
            _selectedReferenceVideo = restored.first;
            _hasReference = true;
          }
        }
      });
    } catch (e) {
      print('Error loading available references: $e');
    }
  }

  Map<String, double> _computeReferenceSummary(List<Map<String, dynamic>> frames) {
    final Map<String, List<double>> buckets = {};
    for (final f in frames) {
      final angles = (f['angles'] as Map?)?.cast<String, dynamic>() ?? {};
      angles.forEach((k, v) {
        final d = (v as num).toDouble();
        (buckets[k] ??= []).add(d);
      });
      final feats = (f['features'] as Map?)?.cast<String, dynamic>() ?? {};
      if (feats.containsKey('ankleDist')) {
        (buckets['ankleDist'] ??= []).add((feats['ankleDist'] as num).toDouble());
      }
    }
    final Map<String, double> summary = {};
    buckets.forEach((k, vals) {
      if (vals.isEmpty) return;
      vals.sort();
      final avg = vals.reduce((a, b) => a + b) / vals.length;
      summary['${k}_avg'] = avg;
      summary['${k}_min'] = vals.first;
      summary['${k}_max'] = vals.last;
    });
    return summary;
  }

  Future<void> _startGuidedSession() async {
    // Prefer selected reference video, else try recorded reference frames
    if (_selectedReferenceVideo != null) {
      // Build summary from selected video poseSequence
      final frames = _selectedReferenceVideo!.poseSequence.map((pf) => {
            'angles': pf.computedAngles,
            'features': pf.features,
          }).toList();
      final summary = _computeReferenceSummary(frames);
      setState(() {
        _referenceSummary = summary;
        _hasReference = true;
        _isGuided = true;
      });
      _startSession();
      return;
    }

    final ok = await _loadReference();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No reference found. Add a reference first.')),
        );
      }
      return;
    }
    setState(() => _isGuided = true);
    _startSession();
  }

  // Session controls
  void _startSession() {
    setState(() {
      _sessionState = SessionState.running;
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
      _repCount = 0;
      _formScoreAccum = 0.0;
      _formScoreSamples = 0;
      _realtimeFeedback.clear();
      _isInDownPhase = false;
      _lastMotionAt = DateTime.now();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
        // Auto-pause if no motion detected for 10s
        if (_sessionState == SessionState.running && DateTime.now().difference(_lastMotionAt) > const Duration(seconds: 10)) {
          _sessionState = SessionState.paused;
        }
      });
    });
  }

  void _pauseSession() {
    if (_sessionState != SessionState.running) return;
    setState(() => _sessionState = SessionState.paused);
    _timer?.cancel();
  }

  void _resumeSession() {
    if (_sessionState != SessionState.paused) return;
    setState(() => _sessionState = SessionState.running);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  Future<void> _stopSession() async {
    if (_sessionState == SessionState.idle) return;
    _timer?.cancel();
    setState(() {
      _sessionState = SessionState.finished;
      _isGuided = false; // exit guided mode to pause reference video and toggle UI
    });
    final avgFormScore = _formScoreSamples == 0 ? 0.0 : _formScoreAccum / _formScoreSamples;
    await _saveFeedback(
      exercise: _selectedExercise.name,
      reps: _repCount,
      durationSeconds: _elapsed.inSeconds,
      formScore: (avgFormScore * 100).round(),
      tips: _realtimeFeedback.take(5).toList(),
      startedAtIso: _startTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session saved to feedback history')),
      );
    }
  }

  void _pushRealtimeFeedback(String message) {
    if (_realtimeFeedback.isEmpty || _realtimeFeedback.last != message) {
      _realtimeFeedback.add(message);
      if (_realtimeFeedback.length > 30) {
        _realtimeFeedback.removeAt(0);
      }
    }
  }

  Future<void> _saveFeedback({
    required String exercise,
    required int reps,
    required int durationSeconds,
    required int formScore,
    required List<String> tips,
    required String startedAtIso,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'exercise_feedback_history';
    final List<String> items = prefs.getStringList(key) ?? [];
    final entry = {
      'exercise': exercise,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'formScore': formScore,
      'tips': tips,
      'startedAt': startedAtIso,
      'savedAt': DateTime.now().toIso8601String(),
    };
    items.insert(0, jsonEncode(entry));
    // Keep only recent 100
    while (items.length > 100) {
      items.removeLast();
    }
    await prefs.setStringList(key, items);
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  /// Validate if the file path points to a valid video file
  bool _isValidVideoFile(String filePath) {
    final extensions = ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv'];
    final lowerCasePath = filePath.toLowerCase();
    return extensions.any((ext) => lowerCasePath.endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Exercise'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Switch camera',
            onPressed: _switchCamera,
            icon: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview area
          Expanded(
            flex: 3,
            child: SplitView(
              cameraController: _cameraController,
              referenceVideo: _selectedReferenceVideo,
              isRecording: _sessionState == SessionState.running,
              isGuided: _isGuided,
              onReferenceTap: _uploadReferenceVideo,
              autoPlayReference: true,
            ),
          ),
          const SizedBox(height: 8),
          // Exercise selector and controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Exercise:'),
                DropdownButton<ExerciseType>(
                  value: _selectedExercise,
                  items: const [
                    DropdownMenuItem(value: ExerciseType.squats, child: Text('Squats')),
                    DropdownMenuItem(value: ExerciseType.pushups, child: Text('Push-ups')),
                    DropdownMenuItem(value: ExerciseType.jumpingJacks, child: Text('Jumping Jacks')),
                    DropdownMenuItem(value: ExerciseType.yoga, child: Text('Yoga')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _selectedExercise = v;
                      _repCount = 0;
                      _isInDownPhase = false;
                      _formScoreAccum = 0.0;
                      _formScoreSamples = 0;
                      _realtimeFeedback.clear();
                    });
                  },
                ),
                const SizedBox(width: 16),
                const Text('Reference:'),
                DropdownButton<String?>(
                  value: _availableReferences.any((v) => v.id == _selectedReferenceVideo?.id)
                      ? _selectedReferenceVideo?.id
                      : null,
                  hint: const Text('Select Reference'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ..._availableReferences.map((video) => DropdownMenuItem<String?>(
                      value: video.id,
                      child: Text(video.title, overflow: TextOverflow.ellipsis),
                    )),
                  ],
                  onChanged: (videoId) {
                    if (videoId == null) {
                      setState(() {
                        _selectedReferenceVideo = null;
                        _hasReference = false;
                      });
                      _persistLastSelectedReference(null);
                    } else {
                      final video = _availableReferences.firstWhere((v) => v.id == videoId, orElse: () => _availableReferences.first);
                      setState(() {
                        _selectedReferenceVideo = video;
                        _hasReference = true;
                      });
                      _persistLastSelectedReference(video.id);
                    }
                  },
                ),
                
                // Reference capture/upload button
                if (!_isRecordingReference)
                  OutlinedButton.icon(
                    onPressed: _showReferenceOptions,
                    icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                    label: const Text('Add Reference'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _stopReferenceRecording,
                    icon: const Icon(Icons.stop, color: Colors.red),
                    label: const Text('Stop Recording'),
                  ),
                
                // Start/Stop Guided Workout button
                if (_sessionState == SessionState.idle || _sessionState == SessionState.finished)
                  ElevatedButton.icon(
                    onPressed: (_selectedReferenceVideo != null || _hasReference) ? _startGuidedSession : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Guided Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_selectedReferenceVideo != null || _hasReference) ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _stopSession,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                
                // Loading indicator
                if (_isProcessingVideo)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          
          // Status indicators
          if (_isRecordingReference || _hasReference || _sessionState != SessionState.idle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 16,
                children: [
                  if (_isRecordingReference)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text('Recording: $_refValidFramesCount valid frames'),
                      ],
                    ),
                  if (_hasReference && _selectedReferenceVideo != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text('Reference: ${_selectedReferenceVideo!.title}'),
                      ],
                    ),
                  if (_sessionState == SessionState.running)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text('Workout: ${_formatDuration(_elapsed)} | Reps: $_repCount'),
                      ],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          // Real-time feedback panel
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(12),
        child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
          children: [
                        const Icon(Icons.feedback, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        const Text('Real-time feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Builder(builder: (context) {
                          final avg = _formScoreSamples == 0 ? 0.0 : (_formScoreAccum / _formScoreSamples * 100);
                          return Text('Form score: ${avg.toStringAsFixed(0)}%');
                        }),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _realtimeFeedback.length,
                        itemBuilder: (context, index) {
                          final tip = _realtimeFeedback[_realtimeFeedback.length - 1 - index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0),
                            child: Text('• $tip'),
                          );
                        },
                      ),
                    ),
                    if (!_isDetectorReady)
                      const Text(
                        'Note: Pose detector not ready. Ensure google_mlkit_pose_detection is configured.',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                  ],
                ),
              ),
              ),
            ),
          ],
      ),
    );
  }
} 