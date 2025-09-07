import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';
import '../models/participant_progress.dart';

class ChallengesProvider with ChangeNotifier {
  List<Challenge> _challenges = [];
  List<ParticipantProgress> _participantProgress = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Challenge> get challenges => _challenges;
  List<ParticipantProgress> get participantProgress => _participantProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active challenges
  List<Challenge> get activeChallenges => 
      _challenges.where((challenge) => challenge.isActive).toList();

  // Get public challenges
  List<Challenge> get publicChallenges => 
      _challenges.where((challenge) => 
          challenge.visibility == ChallengeVisibility.public && 
          challenge.isActive).toList();

  // Get user's challenges
  List<Challenge> getUserChallenges(String userId) {
    return _challenges.where((challenge) => 
        challenge.participants.contains(userId)).toList();
  }

  // Get challenge by ID
  Challenge? getChallengeById(String challengeId) {
    try {
      return _challenges.firstWhere((challenge) => challenge.id == challengeId);
    } catch (e) {
      return null;
    }
  }

  // Get participant progress for a specific challenge
  List<ParticipantProgress> getChallengeProgress(String challengeId) {
    return _participantProgress
        .where((progress) => progress.challengeId == challengeId)
        .toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
  }

  // Get user's progress for a specific challenge
  ParticipantProgress? getUserProgress(String challengeId, String userId) {
    try {
      return _participantProgress.firstWhere((progress) => 
          progress.challengeId == challengeId && progress.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Create a new challenge
  Future<bool> createChallenge(Challenge challenge) async {
    try {
      _setLoading(true);
      
      // Add to local list
      _challenges.add(challenge);
      
      // Save to local storage
      await _saveChallengesToStorage();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create challenge: $e');
      return false;
    }
  }

  // Join a challenge
  Future<bool> joinChallenge(String challengeId, String userId, String userName) async {
    try {
      _setLoading(true);
      
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex == -1) {
        _setError('Challenge not found');
        return false;
      }

      final challenge = _challenges[challengeIndex];
      
      // Check if user is already a participant
      if (challenge.participants.contains(userId)) {
        _setError('Already participating in this challenge');
        return false;
      }

      // Add user to participants
      final updatedChallenge = challenge.copyWith(
        participants: [...challenge.participants, userId],
      );
      
      _challenges[challengeIndex] = updatedChallenge;
      
      // Create initial progress for the user
      final initialProgress = ParticipantProgress(
        challengeId: challengeId,
        userId: userId,
        userName: userName,
        currentProgress: {},
        dailyProgress: {},
        rank: challenge.participants.length + 1,
        percentageComplete: 0.0,
        lastUpdated: DateTime.now(),
      );
      
      _participantProgress.add(initialProgress);
      
      // Save to local storage
      await _saveChallengesToStorage();
      await _saveProgressToStorage();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to join challenge: $e');
      return false;
    }
  }

  // Update participant progress
  Future<bool> updateProgress(String challengeId, String userId, Map<String, dynamic> newProgress) async {
    try {
      _setLoading(true);
      
      final progressIndex = _participantProgress.indexWhere((p) => 
          p.challengeId == challengeId && p.userId == userId);
      
      if (progressIndex == -1) {
        _setError('Progress not found');
        return false;
      }

      final currentProgress = _participantProgress[progressIndex];
      
      // Update current progress
      final updatedCurrentProgress = Map<String, dynamic>.from(currentProgress.currentProgress);
      newProgress.forEach((key, value) {
        updatedCurrentProgress[key] = (updatedCurrentProgress[key] ?? 0) + value;
      });

      // Update daily progress
      final today = DateTime.now().toIso8601String().split('T')[0];
      final updatedDailyProgress = Map<String, dynamic>.from(currentProgress.dailyProgress);
      if (updatedDailyProgress[today] == null) {
        updatedDailyProgress[today] = {};
      }
      newProgress.forEach((key, value) {
        updatedDailyProgress[today][key] = (updatedDailyProgress[today][key] ?? 0) + value;
      });

      // Calculate percentage complete
      final challenge = getChallengeById(challengeId);
      double percentageComplete = 0.0;
      if (challenge?.targetGoal != null) {
        double totalProgress = 0.0;
        double totalGoal = 0.0;
        challenge!.targetGoal!.forEach((key, goal) {
          totalProgress += (updatedCurrentProgress[key] ?? 0).toDouble();
          totalGoal += goal.toDouble();
        });
        percentageComplete = totalGoal > 0 ? (totalProgress / totalGoal) * 100 : 0.0;
      }

      // Update progress
      final updatedProgress = currentProgress.copyWith(
        currentProgress: updatedCurrentProgress,
        dailyProgress: updatedDailyProgress,
        percentageComplete: percentageComplete,
        lastUpdated: DateTime.now(),
      );
      
      _participantProgress[progressIndex] = updatedProgress;
      
      // Recalculate rankings
      await _recalculateRankings(challengeId);
      
      // Save to local storage
      await _saveProgressToStorage();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update progress: $e');
      return false;
    }
  }

  // Recalculate rankings for a challenge
  Future<void> _recalculateRankings(String challengeId) async {
    final challengeProgress = _participantProgress
        .where((p) => p.challengeId == challengeId)
        .toList();
    
    // Sort by percentage complete (descending)
    challengeProgress.sort((a, b) => b.percentageComplete.compareTo(a.percentageComplete));
    
    // Update rankings
    for (int i = 0; i < challengeProgress.length; i++) {
      final progressIndex = _participantProgress.indexWhere((p) => 
          p.challengeId == challengeId && p.userId == challengeProgress[i].userId);
      
      if (progressIndex != -1) {
        _participantProgress[progressIndex] = challengeProgress[i].copyWith(rank: i + 1);
      }
    }
  }

  // Load challenges from storage
  Future<void> loadChallenges() async {
    try {
      _setLoading(true);
      
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = prefs.getString('challenges');
      final progressJson = prefs.getString('participant_progress');
      
      if (challengesJson != null) {
        final List<dynamic> challengesList = json.decode(challengesJson);
        _challenges = challengesList
            .map((json) => Challenge.fromJson(json))
            .toList();
      }
      
      if (progressJson != null) {
        final List<dynamic> progressList = json.decode(progressJson);
        _participantProgress = progressList
            .map((json) => ParticipantProgress.fromJson(json))
            .toList();
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load challenges: $e');
    }
  }

  // Save challenges to storage
  Future<void> _saveChallengesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = json.encode(_challenges.map((c) => c.toJson()).toList());
      await prefs.setString('challenges', challengesJson);
    } catch (e) {
      _setError('Failed to save challenges: $e');
    }
  }

  // Save progress to storage
  Future<void> _saveProgressToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(_participantProgress.map((p) => p.toJson()).toList());
      await prefs.setString('participant_progress', progressJson);
    } catch (e) {
      _setError('Failed to save progress: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 