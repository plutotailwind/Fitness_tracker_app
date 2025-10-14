import 'exercise_feedback_service.dart';
import 'exercise_api_service.dart';

/// Example usage of the Exercise API Service
/// This file demonstrates how to integrate the API service with your Flutter app
class ExerciseApiUsageExample {
  final ExerciseFeedbackService _feedbackService = ExerciseFeedbackService();

  /// Example: Start an exercise session
  Future<void> startExerciseExample() async {
    // Check if API is available
    final isAvailable = await _feedbackService.isApiAvailable();
    if (!isAvailable) {
      print('API server is not running. Please start the server first.');
      return;
    }

    // Start a new exercise session
    final success = await _feedbackService.startExerciseSession(
      trainerVideoPath: 'path/to/trainer/video.mp4',
      priorityJoints: ['elbow', 'shoulder', 'hip'],
      priorityWeight: 1.8,
      nonpriorityWeight: 0.2,
      requireWeights: false,
      device: 'cpu',
    );

    if (success) {
      print('Exercise session started successfully');
      
      // Listen to status updates
      _feedbackService.statusStream.listen((status) {
        print('Session Status: ${status.status}');
        print('Total Reps: ${status.totalReps}');
        print('Average Score: ${status.averageScore}');
      });

      // Listen to analysis results
      _feedbackService.analysisStream.listen((result) {
        print('Analysis Score: ${result.score}');
        print('Feedback: ${result.feedback}');
        print('Rep Detected: ${result.repDetected}');
      });
    } else {
      print('Failed to start exercise session');
    }
  }

  /// Example: Analyze pose data
  Future<void> analyzePoseExample() async {
    // Mock landmark data (in real app, this would come from camera/MediaPipe)
    final userLandmarks = [
      [
        [0.5, 0.3, 0.1], // nose
        [0.4, 0.3, 0.0], // left shoulder
        [0.6, 0.3, 0.0], // right shoulder
        [0.3, 0.4, 0.0], // left elbow
        [0.7, 0.4, 0.0], // right elbow
        // ... more landmarks
      ]
    ];

    final trainerLandmarks = [
      [
        [0.5, 0.3, 0.1], // nose
        [0.4, 0.3, 0.0], // left shoulder
        [0.6, 0.3, 0.0], // right shoulder
        [0.3, 0.4, 0.0], // left elbow
        [0.7, 0.4, 0.0], // right elbow
        // ... more landmarks
      ]
    ];

    // Analyze pose
    final result = await _feedbackService.analyzeCurrentPose(
      userLandmarks: userLandmarks,
      trainerLandmarks: trainerLandmarks,
    );

    if (result != null) {
      print('Pose Analysis Result:');
      print('Score: ${result.score}');
      print('Feedback: ${result.feedback}');
      print('Motion Amplitude: ${result.motionAmplitude}');
      print('Rep Detected: ${result.repDetected}');
      
      // Print joint analysis
      result.jointAnalysis.forEach((joint, score) {
        print('$joint: $score');
      });
    }
  }

  /// Example: Complete a rep
  Future<void> completeRepExample() async {
    // Complete a rep with a score
    final success = await _feedbackService.completeRep(0.85);
    
    if (success) {
      print('Rep completed successfully');
    } else {
      print('Failed to complete rep');
    }
  }

  /// Example: Get session summary
  Future<void> getSessionSummaryExample() async {
    final summary = await _feedbackService.getSessionSummary();
    
    if (summary != null) {
      print('Session Summary:');
      print('Total Reps: ${summary.totalReps}');
      print('Average Score: ${summary.averageScore}');
      print('Excellent Reps: ${summary.excellentReps}');
      print('Good Reps: ${summary.goodReps}');
      print('Poor Reps: ${summary.poorReps}');
      print('Best Score: ${summary.bestScore}');
      print('Worst Score: ${summary.worstScore}');
      print('Improvement Trend: ${summary.improvementTrend}');
    }
  }

  /// Example: End exercise session
  Future<void> endExerciseExample() async {
    final endResponse = await _feedbackService.endExerciseSession();
    
    if (endResponse != null) {
      print('Session ended: ${endResponse.sessionId}');
      print('Final Status: ${endResponse.status}');
      print('Final Summary: ${endResponse.summary.totalReps} reps');
    }
  }

  /// Example: Standalone pose analysis (without session)
  Future<void> standaloneAnalysisExample() async {
    final userLandmarks = [
      [
        [0.5, 0.3, 0.1],
        [0.4, 0.3, 0.0],
        [0.6, 0.3, 0.0],
        // ... more landmarks
      ]
    ];

    final trainerLandmarks = [
      [
        [0.5, 0.3, 0.1],
        [0.4, 0.3, 0.0],
        [0.6, 0.3, 0.0],
        // ... more landmarks
      ]
    ];

    final result = await _feedbackService.analyzePoseStandalone(
      userLandmarks: userLandmarks,
      trainerLandmarks: trainerLandmarks,
    );

    if (result != null) {
      print('Standalone Analysis:');
      print('Score: ${result.score}');
      print('Feedback: ${result.feedback}');
    }
  }

  /// Example: Using the session manager for multiple sessions
  Future<void> multipleSessionsExample() async {
    final sessionManager = ExerciseSessionManager();
    
    // Create multiple services for different exercises
    final pushupService = sessionManager.getService('pushups');
    final squatService = sessionManager.getService('squats');
    
    // Start sessions
    await pushupService.startExerciseSession(
      trainerVideoPath: 'path/to/pushup_video.mp4',
      priorityJoints: ['elbow', 'shoulder'],
    );
    
    await squatService.startExerciseSession(
      trainerVideoPath: 'path/to/squat_video.mp4',
      priorityJoints: ['hip', 'knee'],
    );
    
    // Get active sessions
    final activeSessions = sessionManager.getActiveSessionIds();
    print('Active sessions: $activeSessions');
    
    // Clean up when done
    sessionManager.dispose();
  }

  /// Example: Convert MediaPipe landmarks to API format
  Future<void> convertLandmarksExample() async {
    // Mock MediaPipe landmarks data
    final mediaPipeLandmarks = {
      'nose': {'x': 0.5, 'y': 0.3, 'z': 0.1},
      'leftShoulder': {'x': 0.4, 'y': 0.3, 'z': 0.0},
      'rightShoulder': {'x': 0.6, 'y': 0.3, 'z': 0.0},
      'leftElbow': {'x': 0.3, 'y': 0.4, 'z': 0.0},
      'rightElbow': {'x': 0.7, 'y': 0.4, 'z': 0.0},
    };

    // Convert to API format
    final apiFormat = PoseDataConverter.convertSingleFrameLandmarks(mediaPipeLandmarks);
    print('Converted landmarks: $apiFormat');
    
    // Use in analysis
    final result = await _feedbackService.analyzePoseStandalone(
      userLandmarks: [apiFormat],
      trainerLandmarks: [apiFormat], // Using same data for demo
    );
    
    if (result != null) {
      print('Analysis result: ${result.score}');
    }
  }

  /// Clean up resources
  void dispose() {
    _feedbackService.dispose();
  }
}

/// Example integration with existing live exercise screen
class LiveExerciseIntegration {
  final ExerciseFeedbackService _feedbackService = ExerciseFeedbackService();

  /// Initialize exercise session when starting live exercise
  Future<bool> initializeExercise({
    required String exerciseType,
    required String trainerVideoPath,
  }) async {
    // Configure priority joints based on exercise type
    List<String> priorityJoints;
    switch (exerciseType.toLowerCase()) {
      case 'pushups':
        priorityJoints = ['elbow', 'shoulder'];
        break;
      case 'squats':
        priorityJoints = ['hip', 'knee'];
        break;
      case 'lateral_raises':
        priorityJoints = ['elbow', 'shoulder'];
        break;
      default:
        priorityJoints = ['elbow', 'shoulder', 'hip', 'knee'];
    }

    return await _feedbackService.startExerciseSession(
      trainerVideoPath: trainerVideoPath,
      priorityJoints: priorityJoints,
    );
  }

  /// Process pose data from camera
  Future<void> processPoseData({
    required Map<String, dynamic> userLandmarks,
    required Map<String, dynamic> trainerLandmarks,
  }) async {
    // Convert landmarks to API format
    final userApiFormat = [PoseDataConverter.convertSingleFrameLandmarks(userLandmarks)];
    final trainerApiFormat = [PoseDataConverter.convertSingleFrameLandmarks(trainerLandmarks)];

    // Analyze pose
    final result = await _feedbackService.analyzeCurrentPose(
      userLandmarks: userApiFormat,
      trainerLandmarks: trainerApiFormat,
    );

    if (result != null) {
      // Handle the analysis result
      _handleAnalysisResult(result);
    }
  }

  /// Handle analysis result
  void _handleAnalysisResult(AnalysisResult result) {
    // Update UI with feedback
    print('Score: ${result.score}');
    print('Feedback: ${result.feedback}');
    
    // Check if rep is detected
    if (result.repDetected) {
      print('Rep detected! Consider completing it.');
    }
    
    // Update joint-specific feedback
    result.jointAnalysis.forEach((joint, score) {
      if (score > 15.0) { // Threshold for poor performance
        print('Focus on $joint: ${score.toStringAsFixed(1)}° deviation');
      }
    });
  }

  /// Complete a rep when user indicates
  Future<void> completeCurrentRep() async {
    // Get current analysis score (you might want to store the last result)
    // For now, using a mock score
    final score = 0.85;
    
    final success = await _feedbackService.completeRep(score);
    if (success) {
      print('Rep completed with score: $score');
    }
  }

  /// End exercise session
  Future<void> endExercise() async {
    final endResponse = await _feedbackService.endExerciseSession();
    if (endResponse != null) {
      print('Exercise completed!');
      print('Total reps: ${endResponse.summary.totalReps}');
      print('Average score: ${endResponse.summary.averageScore}');
    }
  }

  void dispose() {
    _feedbackService.dispose();
  }
}
