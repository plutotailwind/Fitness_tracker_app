import 'package:flutter/foundation.dart';

class ParticipantProgress {
  final String challengeId;
  final String userId;
  final String userName;
  final Map<String, dynamic> currentProgress; // e.g., {"steps": 5000, "pushups": 50}
  final Map<String, dynamic> dailyProgress; // daily tracking
  final int rank;
  final double percentageComplete;
  final DateTime lastUpdated;
  final bool isActive;

  ParticipantProgress({
    required this.challengeId,
    required this.userId,
    required this.userName,
    required this.currentProgress,
    required this.dailyProgress,
    required this.rank,
    required this.percentageComplete,
    required this.lastUpdated,
    this.isActive = true,
  });

  factory ParticipantProgress.fromJson(Map<String, dynamic> json) {
    return ParticipantProgress(
      challengeId: json['challengeId'],
      userId: json['userId'],
      userName: json['userName'],
      currentProgress: Map<String, dynamic>.from(json['currentProgress']),
      dailyProgress: Map<String, dynamic>.from(json['dailyProgress']),
      rank: json['rank'],
      percentageComplete: json['percentageComplete'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'userName': userName,
      'currentProgress': currentProgress,
      'dailyProgress': dailyProgress,
      'rank': rank,
      'percentageComplete': percentageComplete,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  ParticipantProgress copyWith({
    String? challengeId,
    String? userId,
    String? userName,
    Map<String, dynamic>? currentProgress,
    Map<String, dynamic>? dailyProgress,
    int? rank,
    double? percentageComplete,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return ParticipantProgress(
      challengeId: challengeId ?? this.challengeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      currentProgress: currentProgress ?? this.currentProgress,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      rank: rank ?? this.rank,
      percentageComplete: percentageComplete ?? this.percentageComplete,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticipantProgress &&
        other.challengeId == challengeId &&
        other.userId == userId;
  }

  @override
  int get hashCode => challengeId.hashCode ^ userId.hashCode;
} 