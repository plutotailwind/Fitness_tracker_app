import 'dart:async';
import 'exercise_api_service.dart';

/// High-level service for exercise feedback that provides a simplified interface
/// for the existing fitness tracker app to interact with the API
class ExerciseFeedbackService {
  static const Duration _sessionTimeout = Duration(hours: 1);
  static const Duration _pollingInterval = Duration(seconds: 2);
  
  String? _currentSessionId;
  Timer? _sessionTimer;
  Timer? _pollingTimer;
  StreamController<SessionStatus>? _statusController;
  StreamController<AnalysisResult>? _analysisController;

  /// Stream of session status updates
  Stream<SessionStatus> get statusStream => _statusController?.stream ?? const Stream.empty();

  /// Stream of analysis results
  Stream<AnalysisResult> get analysisStream => _analysisController?.stream ?? const Stream.empty();

  /// Check if API server is available
  Future<bool> isApiAvailable() async {
    final response = await ExerciseApiService.checkHealth();
    return response.isSuccess;
  }

  /// Start a new exercise session with automatic status polling
  Future<bool> startExerciseSession({
    required String trainerVideoPath,
    List<String> priorityJoints = const ['elbow', 'shoulder'],
    double priorityWeight = 1.8,
    double nonpriorityWeight = 0.2,
    bool requireWeights = false,
    String device = 'cpu',
  }) async {
    try {
      // Check API availability first
      if (!await isApiAvailable()) {
        print('API server is not available');
        return false;
      }

      // Create exercise configuration
      final config = ExerciseConfig(
        priorityJoints: priorityJoints,
        priorityWeight: priorityWeight,
        nonpriorityWeight: nonpriorityWeight,
        requireWeights: requireWeights,
        device: device,
      );

      // Start session
      final response = await ExerciseApiService.startSession(
        trainerVideoPath: trainerVideoPath,
        config: config,
      );

      if (response.isSuccess && response.data != null) {
        _currentSessionId = response.data!.sessionId;
        
        // Initialize streams
        _statusController = StreamController<SessionStatus>.broadcast();
        _analysisController = StreamController<AnalysisResult>.broadcast();
        
        // Start session timeout timer
        _sessionTimer = Timer(_sessionTimeout, () {
          endExerciseSession();
        });
        
        // Start status polling
        _startStatusPolling();
        
        print('Exercise session started: $_currentSessionId');
        return true;
      } else {
        print('Failed to start session: ${response.error}');
        return false;
      }
    } catch (e) {
      print('Error starting exercise session: $e');
      return false;
    }
  }

  /// Analyze current pose and get feedback
  Future<AnalysisResult?> analyzeCurrentPose({
    required List<List<List<double>>> userLandmarks,
    required List<List<List<double>>> trainerLandmarks,
  }) async {
    if (_currentSessionId == null) {
      print('No active session');
      return null;
    }

    try {
      final response = await ExerciseApiService.analyzePose(
        sessionId: _currentSessionId!,
        userLandmarks: userLandmarks,
        trainerLandmarks: trainerLandmarks,
      );

      if (response.isSuccess && response.data != null) {
        // Emit analysis result to stream
        _analysisController?.add(response.data!);
        return response.data;
      } else {
        print('Pose analysis failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error analyzing pose: $e');
      return null;
    }
  }

  /// Complete a rep with the given score
  Future<bool> completeRep(double score) async {
    if (_currentSessionId == null) {
      print('No active session');
      return false;
    }

    try {
      final response = await ExerciseApiService.completeRep(
        sessionId: _currentSessionId!,
        score: score,
      );

      if (response.isSuccess) {
        print('Rep completed: ${response.data?.repNumber} with score ${response.data?.score}');
        return true;
      } else {
        print('Failed to complete rep: ${response.error}');
        return false;
      }
    } catch (e) {
      print('Error completing rep: $e');
      return false;
    }
  }

  /// Get current session status
  Future<SessionStatus?> getCurrentSessionStatus() async {
    if (_currentSessionId == null) {
      return null;
    }

    try {
      final response = await ExerciseApiService.getSessionStatus(_currentSessionId!);
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      print('Error getting session status: $e');
    }
    return null;
  }

  /// Get session summary
  Future<SummaryStats?> getSessionSummary() async {
    if (_currentSessionId == null) {
      return null;
    }

    try {
      final response = await ExerciseApiService.getSessionSummary(_currentSessionId!);
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      print('Error getting session summary: $e');
    }
    return null;
  }

  /// End the current exercise session
  Future<SessionEndResponse?> endExerciseSession() async {
    if (_currentSessionId == null) {
      return null;
    }

    try {
      final response = await ExerciseApiService.endSession(_currentSessionId!);
      
      // Clean up
      _cleanupSession();
      
      if (response.isSuccess && response.data != null) {
        print('Exercise session ended: ${response.data!.sessionId}');
        return response.data;
      } else {
        print('Failed to end session: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error ending session: $e');
      _cleanupSession();
      return null;
    }
  }

  /// Perform standalone pose analysis (without session)
  Future<AnalysisResult?> analyzePoseStandalone({
    required List<List<List<double>>> userLandmarks,
    required List<List<List<double>>> trainerLandmarks,
  }) async {
    try {
      final response = await ExerciseApiService.analyzePoseStandalone(
        userLandmarks: userLandmarks,
        trainerLandmarks: trainerLandmarks,
      );

      if (response.isSuccess && response.data != null) {
        return response.data;
      } else {
        print('Standalone analysis failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error in standalone analysis: $e');
      return null;
    }
  }

  /// Check if there's an active session
  bool get hasActiveSession => _currentSessionId != null;

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Start automatic status polling
  void _startStatusPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      if (_currentSessionId != null) {
        final status = await getCurrentSessionStatus();
        if (status != null) {
          _statusController?.add(status);
        }
      }
    });
  }

  /// Clean up session resources
  void _cleanupSession() {
    _currentSessionId = null;
    _sessionTimer?.cancel();
    _pollingTimer?.cancel();
    _statusController?.close();
    _analysisController?.close();
    _statusController = null;
    _analysisController = null;
  }

  /// Dispose of the service
  void dispose() {
    _cleanupSession();
  }
}

/// Helper class for converting pose data from MediaPipe format to API format
class PoseDataConverter {
  /// Convert MediaPipe landmarks to API format
  static List<List<List<double>>> convertLandmarksToApiFormat(
    dynamic landmarks,
  ) {
    final List<List<List<double>>> result = [];
    
    // Handle different input types
    if (landmarks is List) {
      // If landmarks is a list of frames
      for (final frame in landmarks) {
        if (frame is Map<String, dynamic>) {
          final frameData = <List<double>>[];
          
          // Convert each landmark to [x, y, z] format
          frame.forEach((key, value) {
            if (value is Map && value.containsKey('x') && value.containsKey('y')) {
              frameData.add([
                (value['x'] ?? 0.0).toDouble(),
                (value['y'] ?? 0.0).toDouble(),
                (value['z'] ?? 0.0).toDouble(),
              ]);
            }
          });
          
          result.add(frameData);
        }
      }
    } else if (landmarks is Map<String, dynamic>) {
      // If landmarks is a single frame map
      final frameData = <List<double>>[];
      
      landmarks.forEach((key, value) {
        if (value is Map && value.containsKey('x') && value.containsKey('y')) {
          frameData.add([
            (value['x'] ?? 0.0).toDouble(),
            (value['y'] ?? 0.0).toDouble(),
            (value['z'] ?? 0.0).toDouble(),
          ]);
        }
      });
      
      result.add(frameData);
    }
    
    return result;
  }

  /// Convert single frame landmarks to API format
  static List<List<double>> convertSingleFrameLandmarks(
    Map<String, dynamic> frameLandmarks,
  ) {
    final List<List<double>> result = [];
    
    frameLandmarks.forEach((key, value) {
      if (value is Map && value.containsKey('x') && value.containsKey('y')) {
        result.add([
          (value['x'] ?? 0.0).toDouble(),
          (value['y'] ?? 0.0).toDouble(),
          (value['z'] ?? 0.0).toDouble(),
        ]);
      }
    });
    
    return result;
  }
}

/// Exercise session manager for handling multiple sessions
class ExerciseSessionManager {
  static final ExerciseSessionManager _instance = ExerciseSessionManager._internal();
  factory ExerciseSessionManager() => _instance;
  ExerciseSessionManager._internal();

  final Map<String, ExerciseFeedbackService> _sessions = {};
  final ExerciseFeedbackService _defaultService = ExerciseFeedbackService();

  /// Get or create a service for a specific session
  ExerciseFeedbackService getService([String? sessionId]) {
    if (sessionId == null) {
      return _defaultService;
    }
    
    if (!_sessions.containsKey(sessionId)) {
      _sessions[sessionId] = ExerciseFeedbackService();
    }
    
    return _sessions[sessionId]!;
  }

  /// Get all active sessions
  List<String> getActiveSessionIds() {
    return _sessions.keys.where((id) {
      final service = _sessions[id];
      return service?.hasActiveSession ?? false;
    }).toList();
  }

  /// Clean up inactive sessions
  void cleanupInactiveSessions() {
    final inactiveSessions = _sessions.keys.where((id) {
      final service = _sessions[id];
      return service?.hasActiveSession != true;
    }).toList();
    
    for (final id in inactiveSessions) {
      _sessions[id]?.dispose();
      _sessions.remove(id);
    }
  }

  /// Dispose all sessions
  void dispose() {
    for (final service in _sessions.values) {
      service.dispose();
    }
    _sessions.clear();
    _defaultService.dispose();
  }
}
