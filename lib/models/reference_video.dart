import 'dart:convert';

class ReferenceVideo {
  final String id;
  final String exerciseType;
  final String title;
  final String? description;
  final String videoPath;
  final DateTime createdAt;
  final List<PoseFrame> poseSequence;
  final Map<String, dynamic> metadata;

  ReferenceVideo({
    required this.id,
    required this.exerciseType,
    required this.title,
    this.description,
    required this.videoPath,
    required this.createdAt,
    required this.poseSequence,
    this.metadata = const {},
  });

  factory ReferenceVideo.fromJson(Map<String, dynamic> json) {
    return ReferenceVideo(
      id: json['id'],
      exerciseType: json['exerciseType'],
      title: json['title'],
      description: json['description'],
      videoPath: json['videoPath'],
      createdAt: DateTime.parse(json['createdAt']),
      poseSequence: (json['poseSequence'] as List)
          .map((frame) => PoseFrame.fromJson(frame))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseType': exerciseType,
      'title': title,
      'description': description,
      'videoPath': videoPath,
      'createdAt': createdAt.toIso8601String(),
      'poseSequence': poseSequence.map((frame) => frame.toJson()).toList(),
      'metadata': metadata,
    };
  }

  ReferenceVideo copyWith({
    String? id,
    String? exerciseType,
    String? title,
    String? description,
    String? videoPath,
    DateTime? createdAt,
    List<PoseFrame>? poseSequence,
    Map<String, dynamic>? metadata,
  }) {
    return ReferenceVideo(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      title: title ?? this.title,
      description: description ?? this.description,
      videoPath: videoPath ?? this.videoPath,
      createdAt: createdAt ?? this.createdAt,
      poseSequence: poseSequence ?? this.poseSequence,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PoseFrame {
  final int frameIndex;
  final double timestamp;
  final Map<String, Landmark> landmarks;
  final Map<String, double> computedAngles;
  final Map<String, dynamic> features;

  PoseFrame({
    required this.frameIndex,
    required this.timestamp,
    required this.landmarks,
    required this.computedAngles,
    required this.features,
  });

  factory PoseFrame.fromJson(Map<String, dynamic> json) {
    return PoseFrame(
      frameIndex: json['frameIndex'],
      timestamp: json['timestamp'].toDouble(),
      landmarks: (json['landmarks'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Landmark.fromJson(value)),
      ),
      computedAngles: Map<String, double>.from(json['computedAngles']),
      features: Map<String, dynamic>.from(json['features']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frameIndex': frameIndex,
      'timestamp': timestamp,
      'landmarks': landmarks.map((key, value) => MapEntry(key, value.toJson())),
      'computedAngles': computedAngles,
      'features': features,
    };
  }
}

class Landmark {
  final double x;
  final double y;
  final double z;
  final double confidence;

  Landmark({
    required this.x,
    required this.y,
    required this.z,
    this.confidence = 1.0,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      z: json['z'].toDouble(),
      confidence: json['confidence']?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'confidence': confidence,
    };
  }
}
