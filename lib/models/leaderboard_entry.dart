import 'package:flutter/foundation.dart';

enum LeaderboardType {
  global,
  challenge,
  friends,
}

enum LeaderboardPeriod {
  daily,
  weekly,
  monthly,
  allTime,
}

enum BadgeType {
  firstPlace,
  secondPlace,
  thirdPlace,
  topTen,
  topHundred,
  streakMaster,
  challengeChampion,
  fitnessGuru,
  consistentPerformer,
}

class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeType type;
  final String iconPath;
  final DateTime earnedAt;
  final bool isActive;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.iconPath,
    required this.earnedAt,
    this.isActive = true,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == 'BadgeType.${json['type']}',
      ),
      iconPath: json['iconPath'],
      earnedAt: DateTime.parse(json['earnedAt']),
      isActive: json['isActive'] ?? true,
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
      'isActive': isActive,
    };
  }
}

class LeaderboardEntry {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rank;
  final double score;
  final int zenCoins;
  final List<Badge> badges;
  final Map<String, dynamic> metrics; // e.g., {"steps": 15000, "calories": 800}
  final DateTime lastUpdated;
  final String? challengeId; // null for global leaderboard
  final LeaderboardType leaderboardType;
  final LeaderboardPeriod period;

  LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rank,
    required this.score,
    required this.zenCoins,
    required this.badges,
    required this.metrics,
    required this.lastUpdated,
    this.challengeId,
    required this.leaderboardType,
    required this.period,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      rank: json['rank'],
      score: json['score'].toDouble(),
      zenCoins: json['zenCoins'],
      badges: (json['badges'] as List)
          .map((b) => Badge.fromJson(b))
          .toList(),
      metrics: Map<String, dynamic>.from(json['metrics']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      challengeId: json['challengeId'],
      leaderboardType: LeaderboardType.values.firstWhere(
        (e) => e.toString() == 'LeaderboardType.${json['leaderboardType']}',
      ),
      period: LeaderboardPeriod.values.firstWhere(
        (e) => e.toString() == 'LeaderboardPeriod.${json['period']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rank': rank,
      'score': score,
      'zenCoins': zenCoins,
      'badges': badges.map((b) => b.toJson()).toList(),
      'metrics': metrics,
      'lastUpdated': lastUpdated.toIso8601String(),
      'challengeId': challengeId,
      'leaderboardType': leaderboardType.toString().split('.').last,
      'period': period.toString().split('.').last,
    };
  }

  LeaderboardEntry copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rank,
    double? score,
    int? zenCoins,
    List<Badge>? badges,
    Map<String, dynamic>? metrics,
    DateTime? lastUpdated,
    String? challengeId,
    LeaderboardType? leaderboardType,
    LeaderboardPeriod? period,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      zenCoins: zenCoins ?? this.zenCoins,
      badges: badges ?? this.badges,
      metrics: metrics ?? this.metrics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      challengeId: challengeId ?? this.challengeId,
      leaderboardType: leaderboardType ?? this.leaderboardType,
      period: period ?? this.period,
    );
  }
}

class Reward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final double value;
  final String? couponCode;
  final DateTime validUntil;
  final bool isClaimed;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.couponCode,
    required this.validUntil,
    this.isClaimed = false,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: RewardType.values.firstWhere(
        (e) => e.toString() == 'RewardType.${json['type']}',
      ),
      value: json['value'].toDouble(),
      couponCode: json['couponCode'],
      validUntil: DateTime.parse(json['validUntil']),
      isClaimed: json['isClaimed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'couponCode': couponCode,
      'validUntil': validUntil.toIso8601String(),
      'isClaimed': isClaimed,
    };
  }
}

enum RewardType {
  zenCoins,
  cashReward,
  coupon,
  badge,
}
