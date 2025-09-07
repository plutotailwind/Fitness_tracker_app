import 'package:flutter/foundation.dart';

enum WorkoutType {
  cardio,
  strength,
  yoga,
  running,
  cycling,
  swimming,
  walking,
  other,
}

enum AchievementType {
  firstWorkout,
  weeklyStreak,
  monthlyStreak,
  distanceMilestone,
  calorieMilestone,
  timeMilestone,
  challengeCompletion,
  personalBest,
}

class WorkoutSession {
  final String id;
  final String userId;
  final WorkoutType type;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int steps;
  final int repetitions;
  final double caloriesBurned;
  final double distanceKm;
  final List<HeartRateData> heartRateData;
  final Map<String, dynamic> additionalMetrics;
  final List<String> achievements;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.steps,
    required this.repetitions,
    required this.caloriesBurned,
    required this.distanceKm,
    required this.heartRateData,
    required this.additionalMetrics,
    required this.achievements,
    this.notes,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      userId: json['userId'],
      type: WorkoutType.values.firstWhere(
        (e) => e.toString() == 'WorkoutType.${json['type']}',
      ),
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationMinutes: json['durationMinutes'],
      steps: json['steps'],
      repetitions: json['repetitions'],
      caloriesBurned: json['caloriesBurned'].toDouble(),
      distanceKm: json['distanceKm'].toDouble(),
      heartRateData: (json['heartRateData'] as List)
          .map((h) => HeartRateData.fromJson(h))
          .toList(),
      additionalMetrics: Map<String, dynamic>.from(json['additionalMetrics']),
      achievements: List<String>.from(json['achievements']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'steps': steps,
      'repetitions': repetitions,
      'caloriesBurned': caloriesBurned,
      'distanceKm': distanceKm,
      'heartRateData': heartRateData.map((h) => h.toJson()).toList(),
      'additionalMetrics': additionalMetrics,
      'achievements': achievements,
      'notes': notes,
    };
  }
}

class HeartRateData {
  final DateTime timestamp;
  final int heartRate;

  HeartRateData({
    required this.timestamp,
    required this.heartRate,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: json['heartRate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
    };
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final String iconPath;
  final DateTime earnedAt;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.iconPath,
    required this.earnedAt,
    this.metadata,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${json['type']}',
      ),
      iconPath: json['iconPath'],
      earnedAt: DateTime.parse(json['earnedAt']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'iconPath': iconPath,
      'earnedAt': earnedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class DailyStreak {
  final DateTime date;
  final int workoutCount;
  final int totalMinutes;
  final double totalCalories;
  final int totalSteps;
  final List<String> workoutTypes;
  final List<String> achievements;

  DailyStreak({
    required this.date,
    required this.workoutCount,
    required this.totalMinutes,
    required this.totalCalories,
    required this.totalSteps,
    required this.workoutTypes,
    required this.achievements,
  });

  factory DailyStreak.fromJson(Map<String, dynamic> json) {
    return DailyStreak(
      date: DateTime.parse(json['date']),
      workoutCount: json['workoutCount'],
      totalMinutes: json['totalMinutes'],
      totalCalories: json['totalCalories'].toDouble(),
      totalSteps: json['totalSteps'],
      workoutTypes: List<String>.from(json['workoutTypes']),
      achievements: List<String>.from(json['achievements']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'workoutCount': workoutCount,
      'totalMinutes': totalMinutes,
      'totalCalories': totalCalories,
      'totalSteps': totalSteps,
      'workoutTypes': workoutTypes,
      'achievements': achievements,
    };
  }
}

class ChallengeHistory {
  final String challengeId;
  final String challengeName;
  final DateTime startDate;
  final DateTime completionDate;
  final bool completed;
  final double progressPercentage;
  final Map<String, dynamic> finalMetrics;
  final List<String> achievements;

  ChallengeHistory({
    required this.challengeId,
    required this.challengeName,
    required this.startDate,
    required this.completionDate,
    required this.completed,
    required this.progressPercentage,
    required this.finalMetrics,
    required this.achievements,
  });

  factory ChallengeHistory.fromJson(Map<String, dynamic> json) {
    return ChallengeHistory(
      challengeId: json['challengeId'],
      challengeName: json['challengeName'],
      startDate: DateTime.parse(json['startDate']),
      completionDate: DateTime.parse(json['completionDate']),
      completed: json['completed'],
      progressPercentage: json['progressPercentage'].toDouble(),
      finalMetrics: Map<String, dynamic>.from(json['finalMetrics']),
      achievements: List<String>.from(json['achievements']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'challengeName': challengeName,
      'startDate': startDate.toIso8601String(),
      'completionDate': completionDate.toIso8601String(),
      'completed': completed,
      'progressPercentage': progressPercentage,
      'finalMetrics': finalMetrics,
      'achievements': achievements,
    };
  }
}
