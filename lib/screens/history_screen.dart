import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<WorkoutSession> _workoutSessions;
  late List<Achievement> _achievements;
  late List<DailyStreak> _dailyStreaks;
  late List<ChallengeHistory> _challengeHistory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock workout sessions
    _workoutSessions = [
      WorkoutSession(
        id: '1',
        userId: 'user1',
        type: WorkoutType.cardio,
        title: 'Morning Cardio',
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        durationMinutes: 60,
        steps: 8500,
        repetitions: 0,
        caloriesBurned: 450.0,
        distanceKm: 5.2,
        heartRateData: [
          HeartRateData(timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5, minutes: 30)), heartRate: 140),
          HeartRateData(timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5, minutes: 15)), heartRate: 155),
          HeartRateData(timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)), heartRate: 160),
        ],
        additionalMetrics: {'avgSpeed': 8.7, 'maxSpeed': 12.3},
        achievements: ['First Cardio Session', '5K Distance'],
        notes: 'Great morning workout!',
      ),
      WorkoutSession(
        id: '2',
        userId: 'user1',
        type: WorkoutType.strength,
        title: 'Upper Body Strength',
        startTime: DateTime.now().subtract(const Duration(days: 2, hours: 18)),
        endTime: DateTime.now().subtract(const Duration(days: 2, hours: 17)),
        durationMinutes: 45,
        steps: 1200,
        repetitions: 120,
        caloriesBurned: 320.0,
        distanceKm: 0.0,
        heartRateData: [
          HeartRateData(timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 17, minutes: 30)), heartRate: 125),
          HeartRateData(timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 17, minutes: 15)), heartRate: 135),
        ],
        additionalMetrics: {'weightLifted': 85.5, 'sets': 4},
        achievements: ['Strength Milestone'],
        notes: 'Increased weights this session',
      ),
      WorkoutSession(
        id: '3',
        userId: 'user1',
        type: WorkoutType.yoga,
        title: 'Evening Yoga Flow',
        startTime: DateTime.now().subtract(const Duration(days: 3, hours: 20)),
        endTime: DateTime.now().subtract(const Duration(days: 3, hours: 19)),
        durationMinutes: 30,
        steps: 800,
        repetitions: 0,
        caloriesBurned: 180.0,
        distanceKm: 0.0,
        heartRateData: [
          HeartRateData(timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 19, minutes: 30)), heartRate: 95),
        ],
        additionalMetrics: {'poses': 12, 'flexibility': 8.5},
        achievements: ['Yoga Beginner'],
        notes: 'Felt very relaxed after',
      ),
    ];

    // Mock achievements
    _achievements = [
      Achievement(
        id: '1',
        name: '🏃‍♂️ First Cardio Session',
        description: 'Completed your first cardio workout',
        type: AchievementType.firstWorkout,
        iconPath: 'assets/icons/first_workout.png',
        earnedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Achievement(
        id: '2',
        name: '💪 Strength Milestone',
        description: 'Lifted 85kg in strength training',
        type: AchievementType.personalBest,
        iconPath: 'assets/icons/strength.png',
        earnedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Achievement(
        id: '3',
        name: '🧘‍♀️ Yoga Beginner',
        description: 'Completed 5 yoga sessions',
        type: AchievementType.personalBest,
        iconPath: 'assets/icons/yoga.png',
        earnedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Achievement(
        id: '4',
        name: '🔥 Weekly Streak',
        description: 'Worked out for 7 consecutive days',
        type: AchievementType.weeklyStreak,
        iconPath: 'assets/icons/streak.png',
        earnedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    // Mock daily streaks
    _dailyStreaks = [
      DailyStreak(
        date: DateTime.now().subtract(const Duration(days: 1)),
        workoutCount: 2,
        totalMinutes: 105,
        totalCalories: 770.0,
        totalSteps: 9700,
        workoutTypes: ['cardio', 'yoga'],
        achievements: ['First Cardio Session', '5K Distance'],
      ),
      DailyStreak(
        date: DateTime.now().subtract(const Duration(days: 2)),
        workoutCount: 1,
        totalMinutes: 45,
        totalCalories: 320.0,
        totalSteps: 1200,
        workoutTypes: ['strength'],
        achievements: ['Strength Milestone'],
      ),
      DailyStreak(
        date: DateTime.now().subtract(const Duration(days: 3)),
        workoutCount: 1,
        totalMinutes: 30,
        totalCalories: 180.0,
        totalSteps: 800,
        workoutTypes: ['yoga'],
        achievements: ['Yoga Beginner'],
      ),
    ];

    // Mock challenge history
    _challengeHistory = [
      ChallengeHistory(
        challengeId: '1',
        challengeName: '30-Day Fitness Challenge',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        completionDate: DateTime.now().subtract(const Duration(days: 2)),
        completed: true,
        progressPercentage: 100.0,
        finalMetrics: {'totalWorkouts': 28, 'totalCalories': 12500, 'totalSteps': 180000},
        achievements: ['Challenge Champion', 'Consistency Master'],
      ),
      ChallengeHistory(
        challengeId: '2',
        challengeName: 'Summer Body Challenge',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        completionDate: DateTime.now().subtract(const Duration(days: 15)),
        completed: true,
        progressPercentage: 100.0,
        finalMetrics: {'weightLost': 5.2, 'muscleGained': 2.1, 'endurance': 8.5},
        achievements: ['Summer Ready', 'Transformation Complete'],
      ),
      ChallengeHistory(
        challengeId: '3',
        challengeName: 'Marathon Training',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        completionDate: DateTime.now().add(const Duration(days: 30)),
        completed: false,
        progressPercentage: 75.0,
        finalMetrics: {'longestRun': 25.0, 'avgPace': 5.2, 'totalDistance': 180.5},
        achievements: ['Half Marathon', 'Distance Runner'],
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sessions'),
            Tab(text: 'Achievements'),
            Tab(text: 'Challenges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSessionsTab(),
          _buildAchievementsTab(),
          _buildChallengesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildWeeklyProgress(),
          const SizedBox(height: 24),
          _buildRecentAchievements(),
          const SizedBox(height: 24),
          _buildDailyStreaks(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalWorkouts = _workoutSessions.length;
    final totalMinutes = _workoutSessions.fold(0, (sum, session) => sum + session.durationMinutes);
    final totalCalories = _workoutSessions.fold(0.0, (sum, session) => sum + session.caloriesBurned);
    final totalSteps = _workoutSessions.fold(0, (sum, session) => sum + session.steps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Your Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('Total Workouts', '$totalWorkouts', Icons.fitness_center, Colors.blue),
            _buildStatCard('Total Minutes', '$totalMinutes', Icons.timer, Colors.green),
            _buildStatCard('Calories Burned', '${totalCalories.toStringAsFixed(0)}', Icons.local_fire_department, Colors.orange),
            _buildStatCard('Total Steps', '${NumberFormat('#,###').format(totalSteps)}', Icons.directions_walk, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 Weekly Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressBar('Workout Days', 5, 7, Colors.blue),
          const SizedBox(height: 12),
          _buildProgressBar('Calories Goal', 1250, 1500, Colors.orange),
          const SizedBox(height: 12),
          _buildProgressBar('Steps Goal', 45000, 50000, Colors.green),
          const SizedBox(height: 12),
          _buildProgressBar('Minutes Goal', 300, 350, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int target, Color color) {
    final percentage = current / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('$current/$target', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage.clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildRecentAchievements() {
    final recentAchievements = _achievements.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 Recent Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...recentAchievements.map((achievement) => _buildAchievementItem(achievement)),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🏆',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Earned ${DateFormat('MMM dd').format(achievement.earnedAt)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStreaks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔥 Daily Streaks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ..._dailyStreaks.take(3).map((streak) => _buildStreakItem(streak)),
        ],
      ),
    );
  }

  Widget _buildStreakItem(DailyStreak streak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd').format(streak.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${streak.workoutCount} workouts • ${streak.totalMinutes} min • ${streak.totalCalories.toStringAsFixed(0)} cal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${streak.totalSteps} steps',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _workoutSessions.length,
      itemBuilder: (context, index) {
        final session = _workoutSessions[index];
        return _buildWorkoutSessionCard(session);
      },
    );
  }

  Widget _buildWorkoutSessionCard(WorkoutSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getWorkoutTypeColor(session.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getWorkoutTypeIcon(session.type),
                    color: _getWorkoutTypeColor(session.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy - HH:mm').format(session.startTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getWorkoutTypeColor(session.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.type.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getWorkoutTypeColor(session.type),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('Duration', '${session.durationMinutes} min', Icons.timer),
                ),
                Expanded(
                  child: _buildMetricItem('Calories', '${session.caloriesBurned.toStringAsFixed(0)}', Icons.local_fire_department),
                ),
                Expanded(
                  child: _buildMetricItem('Steps', '${NumberFormat('#,###').format(session.steps)}', Icons.directions_walk),
                ),
              ],
            ),
            if (session.repetitions > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem('Reps', '${session.repetitions}', Icons.repeat),
                  ),
                  if (session.distanceKm > 0)
                    Expanded(
                      child: _buildMetricItem('Distance', '${session.distanceKm.toStringAsFixed(1)} km', Icons.straighten),
                    ),
                ],
              ),
            ],
            if (session.heartRateData.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildHeartRateChart(session.heartRateData),
            ],
            if (session.achievements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: session.achievements.map((achievement) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      achievement,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
            if (session.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHeartRateChart(List<HeartRateData> heartRateData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heart Rate',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: heartRateData.map((data) => 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${data.heartRate}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '🏆',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Earned ${DateFormat('MMM dd, yyyy').format(achievement.earnedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _challengeHistory.length,
      itemBuilder: (context, index) {
        final challenge = _challengeHistory[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildChallengeCard(ChallengeHistory challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: challenge.completed ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    challenge.completed ? Icons.check_circle : Icons.pending,
                    color: challenge.completed ? Colors.green[700] : Colors.orange[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.challengeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM dd').format(challenge.startDate)} - ${DateFormat('MMM dd').format(challenge.completionDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: challenge.completed ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    challenge.completed ? 'COMPLETED' : 'IN PROGRESS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: challenge.completed ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar('Progress', challenge.progressPercentage.toInt(), 100, Colors.blue),
            const SizedBox(height: 16),
            if (challenge.achievements.isNotEmpty) ...[
              Text(
                'Achievements Earned:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: challenge.achievements.map((achievement) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      achievement,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getWorkoutTypeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.cardio:
        return Colors.red;
      case WorkoutType.strength:
        return Colors.blue;
      case WorkoutType.yoga:
        return Colors.purple;
      case WorkoutType.running:
        return Colors.green;
      case WorkoutType.cycling:
        return Colors.orange;
      case WorkoutType.swimming:
        return Colors.cyan;
      case WorkoutType.walking:
        return Colors.teal;
      case WorkoutType.other:
        return Colors.grey;
    }
  }

  IconData _getWorkoutTypeIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.cardio:
        return Icons.favorite;
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.yoga:
        return Icons.self_improvement;
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.cycling:
        return Icons.directions_bike;
      case WorkoutType.swimming:
        return Icons.pool;
      case WorkoutType.walking:
        return Icons.directions_walk;
      case WorkoutType.other:
        return Icons.sports;
    }
  }
}
