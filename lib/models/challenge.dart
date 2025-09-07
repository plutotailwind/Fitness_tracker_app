import 'package:flutter/foundation.dart';

enum ChallengeType {
  steps,
  pushups,
  yoga,
  running,
  cycling,
  swimming,
}

enum ChallengeVisibility {
  public,
  private,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int duration; // in days
  final double entryFee;
  final double prizePool;
  final ChallengeVisibility visibility;
  final String createdBy;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participants;
  final Map<String, dynamic>? targetGoal; // e.g., {"steps": 10000, "pushups": 100}
  final bool isActive;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    required this.entryFee,
    required this.prizePool,
    required this.visibility,
    required this.createdBy,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.participants,
    this.targetGoal,
    this.isActive = true,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == 'ChallengeType.${json['type']}',
      ),
      duration: json['duration'],
      entryFee: json['entryFee'].toDouble(),
      prizePool: json['prizePool'].toDouble(),
      visibility: ChallengeVisibility.values.firstWhere(
        (e) => e.toString() == 'ChallengeVisibility.${json['visibility']}',
      ),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      participants: List<String>.from(json['participants']),
      targetGoal: json['targetGoal'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'duration': duration,
      'entryFee': entryFee,
      'prizePool': prizePool,
      'visibility': visibility.toString().split('.').last,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participants': participants,
      'targetGoal': targetGoal,
      'isActive': isActive,
    };
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    int? duration,
    double? entryFee,
    double? prizePool,
    ChallengeVisibility? visibility,
    String? createdBy,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? participants,
    Map<String, dynamic>? targetGoal,
    bool? isActive,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participants: participants ?? this.participants,
      targetGoal: targetGoal ?? this.targetGoal,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 