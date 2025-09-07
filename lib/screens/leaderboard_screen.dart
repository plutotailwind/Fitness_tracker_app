import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/challenges_provider.dart';
import '../models/leaderboard_entry.dart';
import '../models/challenge.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LeaderboardProvider _leaderboardProvider;
  late ChallengesProvider _challengesProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _leaderboardProvider.setLeaderboardType(
        LeaderboardType.values[_tabController.index],
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
    _challengesProvider = Provider.of<ChallengesProvider>(context, listen: false);
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
        title: const Text('Leaderboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Challenges'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGlobalLeaderboard(),
                _buildChallengesLeaderboard(),
                _buildFriendsLeaderboard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
                'Time Period',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: LeaderboardPeriod.values.map((period) {
                  final isSelected = provider.currentPeriod == period;
                  return FilterChip(
                    label: Text(_getPeriodLabel(period)),
                    selected: isSelected,
                    onSelected: (selected) {
                      provider.setLeaderboardPeriod(period);
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              if (provider.currentType == LeaderboardType.challenge) ...[
                const SizedBox(height: 16),
                Text(
                  'Select Challenge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<ChallengesProvider>(
                  builder: (context, challengesProvider, child) {
                    final challenges = challengesProvider.challenges;
                    return DropdownButtonFormField<String>(
                      value: provider.selectedChallengeId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('Choose a challenge'),
                      items: challenges.map((challenge) {
                        return DropdownMenuItem(
                          value: challenge.id,
                          child: Text(challenge.title),
                        );
                      }).toList(),
                      onChanged: (challengeId) {
                        provider.setSelectedChallenge(challengeId);
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlobalLeaderboard() {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        final leaderboard = provider.globalLeaderboard;
        return _buildLeaderboardList(leaderboard);
      },
    );
  }

  Widget _buildChallengesLeaderboard() {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        if (provider.selectedChallengeId == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Select a challenge to view its leaderboard',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        final leaderboard = provider.getLeaderboardForChallenge(provider.selectedChallengeId!);
        return _buildLeaderboardList(leaderboard);
      },
    );
  }

  Widget _buildFriendsLeaderboard() {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        final leaderboard = provider.friendsLeaderboard;
        return _buildLeaderboardList(leaderboard);
      },
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> leaderboard) {
    if (leaderboard.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No leaderboard data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        return _buildLeaderboardEntry(entry, index);
      },
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, int index) {
    final isTopThree = entry.rank <= 3;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            // Rank and medal
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getRankColor(entry.rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getRankDisplay(entry.rank),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // User info and score
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (entry.badges.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ...entry.badges.take(3).map((badge) => 
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: Text(
                              badge.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: ${entry.score.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.zenCoins} Zen Coins',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.metrics['workouts'] ?? 0} workouts',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Metrics
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.metrics['steps'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'steps',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${entry.metrics['calories'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'calories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getRankDisplay(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  String _getPeriodLabel(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.daily:
        return 'Daily';
      case LeaderboardPeriod.weekly:
        return 'Weekly';
      case LeaderboardPeriod.monthly:
        return 'Monthly';
      case LeaderboardPeriod.allTime:
        return 'All Time';
    }
  }
} 