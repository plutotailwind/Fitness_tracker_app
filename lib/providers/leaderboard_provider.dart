import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../models/challenge.dart';
import '../utils/id_generator.dart';

class LeaderboardProvider with ChangeNotifier {
  List<LeaderboardEntry> _globalLeaderboard = [];
  Map<String, List<LeaderboardEntry>> _challengeLeaderboards = {};
  List<LeaderboardEntry> _friendsLeaderboard = [];
  LeaderboardType _currentType = LeaderboardType.global;
  LeaderboardPeriod _currentPeriod = LeaderboardPeriod.weekly;
  String? _selectedChallengeId;

  // Getters
  List<LeaderboardEntry> get globalLeaderboard => _globalLeaderboard;
  Map<String, List<LeaderboardEntry>> get challengeLeaderboards => _challengeLeaderboards;
  List<LeaderboardEntry> get friendsLeaderboard => _friendsLeaderboard;
  LeaderboardType get currentType => _currentType;
  LeaderboardPeriod get currentPeriod => _currentPeriod;
  String? get selectedChallengeId => _selectedChallengeId;

  List<LeaderboardEntry> get currentLeaderboard {
    switch (_currentType) {
      case LeaderboardType.global:
        return _globalLeaderboard;
      case LeaderboardType.challenge:
        if (_selectedChallengeId != null) {
          return _challengeLeaderboards[_selectedChallengeId!] ?? [];
        }
        return [];
      case LeaderboardType.friends:
        return _friendsLeaderboard;
    }
  }

  LeaderboardProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock global leaderboard data
    _globalLeaderboard = [
      LeaderboardEntry(
        id: IdGenerator.generateId(),
        userId: 'user1',
        userName: 'Fitness Master',
        userAvatar: null,
        rank: 1,
        score: 9850.0,
        zenCoins: 2500,
        badges: [
          Badge(
            id: IdGenerator.generateId(),
            name: '🏆 Champion',
            description: 'First place in global leaderboard',
            type: BadgeType.firstPlace,
            iconPath: 'assets/icons/first_place.png',
            earnedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        metrics: {'steps': 15000, 'calories': 850, 'workouts': 12},
        lastUpdated: DateTime.now(),
        leaderboardType: LeaderboardType.global,
        period: LeaderboardPeriod.weekly,
      ),
      LeaderboardEntry(
        id: IdGenerator.generateId(),
        userId: 'user2',
        userName: 'Yoga Enthusiast',
        userAvatar: null,
        rank: 2,
        score: 8750.0,
        zenCoins: 1800,
        badges: [
          Badge(
            id: IdGenerator.generateId(),
            name: '🥈 Runner Up',
            description: 'Second place in global leaderboard',
            type: BadgeType.secondPlace,
            iconPath: 'assets/icons/second_place.png',
            earnedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        metrics: {'steps': 12000, 'calories': 720, 'workouts': 10},
        lastUpdated: DateTime.now(),
        leaderboardType: LeaderboardType.global,
        period: LeaderboardPeriod.weekly,
      ),
      LeaderboardEntry(
        id: IdGenerator.generateId(),
        userId: 'user3',
        userName: 'Cardio King',
        userAvatar: null,
        rank: 3,
        score: 8200.0,
        zenCoins: 1500,
        badges: [
          Badge(
            id: IdGenerator.generateId(),
            name: '🥉 Bronze',
            description: 'Third place in global leaderboard',
            type: BadgeType.thirdPlace,
            iconPath: 'assets/icons/third_place.png',
            earnedAt: DateTime.now(),
          ),
        ],
        metrics: {'steps': 11000, 'calories': 680, 'workouts': 8},
        lastUpdated: DateTime.now(),
        leaderboardType: LeaderboardType.global,
        period: LeaderboardPeriod.weekly,
      ),
      LeaderboardEntry(
        id: IdGenerator.generateId(),
        userId: 'user4',
        userName: 'Strength Builder',
        userAvatar: null,
        rank: 4,
        score: 7800.0,
        zenCoins: 1200,
        badges: [],
        metrics: {'steps': 9500, 'calories': 620, 'workouts': 9},
        lastUpdated: DateTime.now(),
        leaderboardType: LeaderboardType.global,
        period: LeaderboardPeriod.weekly,
      ),
      LeaderboardEntry(
        id: IdGenerator.generateId(),
        userId: 'user5',
        userName: 'Flexibility Pro',
        userAvatar: null,
        rank: 5,
        score: 7450.0,
        zenCoins: 1000,
        badges: [],
        metrics: {'steps': 8800, 'calories': 580, 'workouts': 7},
        lastUpdated: DateTime.now(),
        leaderboardType: LeaderboardType.global,
        period: LeaderboardPeriod.weekly,
      ),
    ];

    // Mock challenge leaderboard data
    _challengeLeaderboards = {
      'challenge1': [
        LeaderboardEntry(
          id: IdGenerator.generateId(),
          userId: 'user1',
          userName: 'Fitness Master',
          userAvatar: null,
          rank: 1,
          score: 9850.0,
          zenCoins: 2500,
          badges: [
            Badge(
              id: IdGenerator.generateId(),
              name: '🏆 Challenge Champion',
              description: 'First place in 30-Day Fitness Challenge',
              type: BadgeType.challengeChampion,
              iconPath: 'assets/icons/challenge_champion.png',
              earnedAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          metrics: {'steps': 15000, 'calories': 850, 'workouts': 12},
          lastUpdated: DateTime.now(),
          challengeId: 'challenge1',
          leaderboardType: LeaderboardType.challenge,
          period: LeaderboardPeriod.weekly,
        ),
        LeaderboardEntry(
          id: IdGenerator.generateId(),
          userId: 'user2',
          userName: 'Yoga Enthusiast',
          userAvatar: null,
          rank: 2,
          score: 8750.0,
          zenCoins: 1800,
          badges: [],
          metrics: {'steps': 12000, 'calories': 720, 'workouts': 10},
          lastUpdated: DateTime.now(),
          challengeId: 'challenge1',
          leaderboardType: LeaderboardType.challenge,
          period: LeaderboardPeriod.weekly,
        ),
      ],
    };

    // Mock friends leaderboard data
    _friendsLeaderboard = [
      LeaderboardEntry(
        id: IdGenerator.generateId(),
        userId: 'friend1',
        userName: 'Best Friend',
        userAvatar: null,
        rank: 1,
        score: 9200.0,
        zenCoins: 2000,
        badges: [
          Badge(
            id: IdGenerator.generateId(),
            name: '👥 Friend Leader',
            description: 'Top among friends',
            type: BadgeType.topTen,
            iconPath: 'assets/icons/friend_leader.png',
            earnedAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
        metrics: {'steps': 14000, 'calories': 800, 'workouts': 11},
        lastUpdated: DateTime.now(),
        leaderboardType: LeaderboardType.friends,
        period: LeaderboardPeriod.weekly,
      ),
      LeaderboardEntry(
        id: IdGenerator.generateId(),
        userId: 'friend2',
        userName: 'Workout Buddy',
        userAvatar: null,
        rank: 2,
        score: 8500.0,
        zenCoins: 1600,
        badges: [],
        metrics: {'steps': 13000, 'calories': 750, 'workouts': 9},
        lastUpdated: DateTime.now(),
        leaderboardType: LeaderboardType.friends,
        period: LeaderboardPeriod.weekly,
      ),
    ];

    notifyListeners();
  }

  void setLeaderboardType(LeaderboardType type) {
    _currentType = type;
    notifyListeners();
  }

  void setLeaderboardPeriod(LeaderboardPeriod period) {
    _currentPeriod = period;
    // In a real app, you would fetch data for the new period
    notifyListeners();
  }

  void setSelectedChallenge(String? challengeId) {
    _selectedChallengeId = challengeId;
    notifyListeners();
  }

  void refreshLeaderboard() {
    // In a real app, this would fetch fresh data from the backend
    notifyListeners();
  }

  List<LeaderboardEntry> getLeaderboardForChallenge(String challengeId) {
    return _challengeLeaderboards[challengeId] ?? [];
  }

  void addEntryToChallengeLeaderboard(String challengeId, LeaderboardEntry entry) {
    if (!_challengeLeaderboards.containsKey(challengeId)) {
      _challengeLeaderboards[challengeId] = [];
    }
    
    // Remove existing entry for this user if exists
    _challengeLeaderboards[challengeId]!.removeWhere((e) => e.userId == entry.userId);
    
    // Add new entry
    _challengeLeaderboards[challengeId]!.add(entry);
    
    // Sort by score
    _challengeLeaderboards[challengeId]!.sort((a, b) => b.score.compareTo(a.score));
    
    // Update ranks
    for (int i = 0; i < _challengeLeaderboards[challengeId]!.length; i++) {
      _challengeLeaderboards[challengeId]![i] = _challengeLeaderboards[challengeId]![i].copyWith(rank: i + 1);
    }
    
    notifyListeners();
  }
}
