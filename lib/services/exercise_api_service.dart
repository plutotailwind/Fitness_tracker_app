import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

/// Service class for interacting with the Fitness Tracker REST API
class ExerciseApiService {
  static const String _baseUrl = 'http://localhost:8000';
  static const Duration _timeout = Duration(seconds: 30);
  static const String _wsBase = 'ws://localhost:8000';
  static WebSocketChannel? _frameChannel;

  /// Check if the s is running
  static Future<ApiResponse<HealthStatus>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(HealthStatus.fromJson(data));
      } else {
        return ApiResponse.error('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Health check error: $e');
    }
  }

  /// Start a new exercise session
  static Future<ApiResponse<SessionStartResponse>> startSession({
    required String trainerVideoPath,
    required ExerciseConfig config,
  }) async {
    try {
      final requestBody = {
        'trainer_video_path': trainerVideoPath,
        'config': config.toJson(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/start'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(SessionStartResponse.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Failed to start session: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Session start error: $e');
    }
  }

  /// Open a WebSocket to stream JPEG frames for the current session
  static Future<bool> openFrameStream(String sessionId) async {
    try {
      closeFrameStream();
      final uri = Uri.parse('$_wsBase/stream/$sessionId');
      _frameChannel = IOWebSocketChannel.connect(uri);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send a single JPEG frame as binary over the WebSocket
  static void sendJpegFrame(Uint8List jpegBytes) {
    if (_frameChannel == null) return;
    try {
      _frameChannel!.sink.add(jpegBytes);
    } catch (_) {}
  }

  /// Close the frame stream
  static void closeFrameStream() {
    try { _frameChannel?.sink.close(); } catch (_) {}
    _frameChannel = null;
  }

  /// Get the current status of a session
  static Future<ApiResponse<SessionStatus>> getSessionStatus(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sessions/$sessionId/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(SessionStatus.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Failed to get session status: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Session status error: $e');
    }
  }

  /// Analyze user pose and provide feedback
  static Future<ApiResponse<AnalysisResult>> analyzePose({
    required String sessionId,
    required List<List<List<double>>> userLandmarks,
    required List<List<List<double>>> trainerLandmarks,
  }) async {
    try {
      final requestBody = {
        'session_id': sessionId,
        'user_landmarks': userLandmarks,
        'trainer_landmarks': trainerLandmarks,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(AnalysisResult.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Pose analysis failed: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Pose analysis error: $e');
    }
  }

  /// Mark a rep as completed with its score
  static Future<ApiResponse<RepCompletionResponse>> completeRep({
    required String sessionId,
    required double score,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/complete_rep'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'score=$score',
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(RepCompletionResponse.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Failed to complete rep: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Complete rep error: $e');
    }
  }

  /// Get session summary statistics
  static Future<ApiResponse<SummaryStats>> getSessionSummary(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sessions/$sessionId/summary'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(SummaryStats.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Failed to get session summary: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Session summary error: $e');
    }
  }

  /// End a session and get final summary
  static Future<ApiResponse<SessionEndResponse>> endSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/end'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(SessionEndResponse.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Failed to end session: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('End session error: $e');
    }
  }

  /// Analyze pose without a session (standalone analysis)
  static Future<ApiResponse<AnalysisResult>> analyzePoseStandalone({
    required List<List<List<double>>> userLandmarks,
    required List<List<List<double>>> trainerLandmarks,
  }) async {
    try {
      final requestBody = {
        'user_landmarks': userLandmarks,
        'trainer_landmarks': trainerLandmarks,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/analysis/pose'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(AnalysisResult.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Standalone analysis failed: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Standalone analysis error: $e');
    }
  }

  /// List all active sessions
  static Future<ApiResponse<ActiveSessionsResponse>> getActiveSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sessions'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(ActiveSessionsResponse.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Failed to get active sessions: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Active sessions error: $e');
    }
  }

  /// Delete a session
  static Future<ApiResponse<String>> deleteSession(String sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/sessions/$sessionId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data['message'] ?? 'Session deleted successfully');
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error('Failed to delete session: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Delete session error: $e');
    }
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResponse._(this.isSuccess, this.data, this.error);

  factory ApiResponse.success(T data) => ApiResponse._(true, data, null);
  factory ApiResponse.error(String error) => ApiResponse._(false, null, error);
}

/// Health check response
class HealthStatus {
  final String status;
  final String timestamp;

  HealthStatus({required this.status, required this.timestamp});

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

/// Exercise configuration
class ExerciseConfig {
  final List<String> priorityJoints;
  final double priorityWeight;
  final double nonpriorityWeight;
  final bool requireWeights;
  final String device;

  ExerciseConfig({
    required this.priorityJoints,
    required this.priorityWeight,
    required this.nonpriorityWeight,
    required this.requireWeights,
    required this.device,
  });

  Map<String, dynamic> toJson() {
    return {
      'priority_joints': priorityJoints,
      'priority_weight': priorityWeight,
      'nonpriority_weight': nonpriorityWeight,
      'require_weights': requireWeights,
      'device': device,
    };
  }

  factory ExerciseConfig.fromJson(Map<String, dynamic> json) {
    return ExerciseConfig(
      priorityJoints: List<String>.from(json['priority_joints'] ?? []),
      priorityWeight: (json['priority_weight'] ?? 1.8).toDouble(),
      nonpriorityWeight: (json['nonpriority_weight'] ?? 0.2).toDouble(),
      requireWeights: json['require_weights'] ?? false,
      device: json['device'] ?? 'cpu',
    );
  }
}

/// Session start response
class SessionStartResponse {
  final String sessionId;
  final String status;

  SessionStartResponse({required this.sessionId, required this.status});

  factory SessionStartResponse.fromJson(Map<String, dynamic> json) {
    return SessionStartResponse(
      sessionId: json['session_id'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

/// Session status
class SessionStatus {
  final String sessionId;
  final String status;
  final int totalReps;
  final List<double> currentRepScores;
  final double averageScore;
  final String startTime;
  final String lastActivity;

  SessionStatus({
    required this.sessionId,
    required this.status,
    required this.totalReps,
    required this.currentRepScores,
    required this.averageScore,
    required this.startTime,
    required this.lastActivity,
  });

  factory SessionStatus.fromJson(Map<String, dynamic> json) {
    return SessionStatus(
      sessionId: json['session_id'] ?? '',
      status: json['status'] ?? '',
      totalReps: json['total_reps'] ?? 0,
      currentRepScores: List<double>.from(json['current_rep_scores'] ?? []),
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      startTime: json['start_time'] ?? '',
      lastActivity: json['last_activity'] ?? '',
    );
  }
}

/// Analysis result
class AnalysisResult {
  final double score;
  final String feedback;
  final Map<String, double> jointAnalysis;
  final double motionAmplitude;
  final bool repDetected;

  AnalysisResult({
    required this.score,
    required this.feedback,
    required this.jointAnalysis,
    required this.motionAmplitude,
    required this.repDetected,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      score: (json['score'] ?? 0.0).toDouble(),
      feedback: json['feedback'] ?? '',
      jointAnalysis: Map<String, double>.from(json['joint_analysis'] ?? {}),
      motionAmplitude: (json['motion_amplitude'] ?? 0.0).toDouble(),
      repDetected: json['rep_detected'] ?? false,
    );
  }
}

/// Rep completion response
class RepCompletionResponse {
  final int repNumber;
  final double score;
  final int totalReps;
  final double averageScore;

  RepCompletionResponse({
    required this.repNumber,
    required this.score,
    required this.totalReps,
    required this.averageScore,
  });

  factory RepCompletionResponse.fromJson(Map<String, dynamic> json) {
    return RepCompletionResponse(
      repNumber: json['rep_number'] ?? 0,
      score: (json['score'] ?? 0.0).toDouble(),
      totalReps: json['total_reps'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
    );
  }
}

/// Summary statistics
class SummaryStats {
  final int totalReps;
  final double averageScore;
  final int excellentReps;
  final int goodReps;
  final int poorReps;
  final double bestScore;
  final double worstScore;
  final String improvementTrend;

  SummaryStats({
    required this.totalReps,
    required this.averageScore,
    required this.excellentReps,
    required this.goodReps,
    required this.poorReps,
    required this.bestScore,
    required this.worstScore,
    required this.improvementTrend,
  });

  factory SummaryStats.fromJson(Map<String, dynamic> json) {
    return SummaryStats(
      totalReps: json['total_reps'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      excellentReps: json['excellent_reps'] ?? 0,
      goodReps: json['good_reps'] ?? 0,
      poorReps: json['poor_reps'] ?? 0,
      bestScore: (json['best_score'] ?? 0.0).toDouble(),
      worstScore: (json['worst_score'] ?? 0.0).toDouble(),
      improvementTrend: json['improvement_trend'] ?? '',
    );
  }
}

/// Session end response
class SessionEndResponse {
  final String sessionId;
  final String status;
  final SummaryStats summary;

  SessionEndResponse({
    required this.sessionId,
    required this.status,
    required this.summary,
  });

  factory SessionEndResponse.fromJson(Map<String, dynamic> json) {
    return SessionEndResponse(
      sessionId: json['session_id'] ?? '',
      status: json['status'] ?? '',
      summary: SummaryStats.fromJson(json['summary'] ?? {}),
    );
  }
}

/// Active sessions response
class ActiveSessionsResponse {
  final List<String> activeSessions;
  final int totalSessions;

  ActiveSessionsResponse({
    required this.activeSessions,
    required this.totalSessions,
  });

  factory ActiveSessionsResponse.fromJson(Map<String, dynamic> json) {
    return ActiveSessionsResponse(
      activeSessions: List<String>.from(json['active_sessions'] ?? []),
      totalSessions: json['total_sessions'] ?? 0,
    );
  }
}
