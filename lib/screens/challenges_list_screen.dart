import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/challenge.dart';
import '../providers/challenges_provider.dart';
import 'challenge_detail_screen.dart';
import 'create_challenge_screen.dart';

class ChallengesListScreen extends StatefulWidget {
  const ChallengesListScreen({super.key});

  @override
  State<ChallengesListScreen> createState() => _ChallengesListScreenState();
}

class _ChallengesListScreenState extends State<ChallengesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  ChallengeType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengesProvider>(context, listen: false).loadChallenges();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Challenge> _getFilteredChallenges(List<Challenge> challenges) {
    return challenges.where((challenge) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!challenge.title.toLowerCase().contains(query) &&
            !challenge.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Type filter
      if (_filterType != null && challenge.type != _filterType) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final isParticipating = challenge.participants.contains('current_user_id'); // TODO: Get from auth
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getChallengeTypeColor(challenge.type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      challenge.type.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (challenge.visibility == ChallengeVisibility.private)
                    const Icon(Icons.lock, color: Colors.orange),
                  if (isParticipating)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'JOINED',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                challenge.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                challenge.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.duration} days',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.participants.length} participants',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (challenge.entryFee > 0) ...[
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Entry: \$${challenge.entryFee.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (challenge.prizePool > 0) ...[
                    Icon(Icons.emoji_events, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Prize: \$${challenge.prizePool.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Starts: ${DateFormat('MMM dd, yyyy').format(challenge.startDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  if (challenge.targetGoal != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TARGET SET',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getChallengeTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.steps:
        return Colors.blue;
      case ChallengeType.pushups:
        return Colors.red;
      case ChallengeType.yoga:
        return Colors.purple;
      case ChallengeType.running:
        return Colors.green;
      case ChallengeType.cycling:
        return Colors.orange;
      case ChallengeType.swimming:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Challenges'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Public'),
            Tab(text: 'My Challenges'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search challenges...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Types'),
                        selected: _filterType == null,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...ChallengeType.values.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(type.name.toUpperCase()),
                            selected: _filterType == type,
                            onSelected: (selected) {
                              setState(() {
                                _filterType = selected ? type : null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Challenges List
          Expanded(
            child: Consumer<ChallengesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Challenge> challenges;
                switch (_tabController.index) {
                  case 0: // All
                    challenges = provider.activeChallenges;
                    break;
                  case 1: // Public
                    challenges = provider.publicChallenges;
                    break;
                  case 2: // My Challenges
                    challenges = provider.getUserChallenges('current_user_id'); // TODO: Get from auth
                    break;
                  default:
                    challenges = [];
                }

                final filteredChallenges = _getFilteredChallenges(challenges);

                if (filteredChallenges.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No challenges found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // All Challenges
                    ListView.builder(
                      itemCount: filteredChallenges.length,
                      itemBuilder: (context, index) {
                        return _buildChallengeCard(filteredChallenges[index]);
                      },
                      scrollDirection: Axis.vertical,
                    ),
                    // Public Challenges
                    ListView.builder(
                      itemCount: filteredChallenges.length,
                      itemBuilder: (context, index) {
                        return _buildChallengeCard(filteredChallenges[index]);
                      },
                      scrollDirection: Axis.vertical,
                    ),
                    // My Challenges
                    ListView.builder(
                      itemCount: filteredChallenges.length,
                      itemBuilder: (context, index) {
                        return _buildChallengeCard(filteredChallenges[index]);
                      },
                      scrollDirection: Axis.vertical,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateChallengeScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
} 