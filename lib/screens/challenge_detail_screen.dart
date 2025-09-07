import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/challenge.dart';
import '../models/participant_progress.dart';
import '../providers/challenges_provider.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _progressControllers = {};
  bool _isParticipating = false;
  ParticipantProgress? _userProgress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkParticipation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _progressControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _checkParticipation() {
    final provider = Provider.of<ChallengesProvider>(context, listen: false);
    _isParticipating = widget.challenge.participants.contains('current_user_id'); // TODO: Get from auth
    
    if (_isParticipating) {
      _userProgress = provider.getUserProgress(widget.challenge.id, 'current_user_id');
      _initializeProgressControllers();
    }
  }

  void _initializeProgressControllers() {
    if (widget.challenge.targetGoal != null) {
      widget.challenge.targetGoal!.forEach((key, value) {
        _progressControllers[key] = TextEditingController();
      });
    }
  }

  Future<void> _joinChallenge() async {
    final provider = Provider.of<ChallengesProvider>(context, listen: false);
    final success = await provider.joinChallenge(
      widget.challenge.id,
      'current_user_id', // TODO: Get from auth
      'Current User', // TODO: Get from auth
    );

    if (success && mounted) {
      setState(() {
        _isParticipating = true;
        _checkParticipation();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the challenge!')),
      );
    }
  }

  Future<void> _updateProgress() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ChallengesProvider>(context, listen: false);
    final newProgress = <String, dynamic>{};

    _progressControllers.forEach((key, controller) {
      final value = int.tryParse(controller.text);
      if (value != null && value > 0) {
        newProgress[key] = value;
      }
    });

    if (newProgress.isNotEmpty) {
      final success = await provider.updateProgress(
        widget.challenge.id,
        'current_user_id', // TODO: Get from auth
        newProgress,
      );

      if (success && mounted) {
        setState(() {
          _checkParticipation();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress updated successfully!')),
        );
        
        // Clear controllers
        _progressControllers.values.forEach((controller) => controller.clear());
      }
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Header
          Card(
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
                          color: _getChallengeTypeColor(widget.challenge.type),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.challenge.type.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.challenge.visibility == ChallengeVisibility.private)
                        const Icon(Icons.lock, color: Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.challenge.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.challenge.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Challenge Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Challenge Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Duration', '${widget.challenge.duration} days'),
                  _buildStatRow('Start Date', DateFormat('MMM dd, yyyy').format(widget.challenge.startDate)),
                  _buildStatRow('End Date', DateFormat('MMM dd, yyyy').format(widget.challenge.endDate)),
                  _buildStatRow('Participants', '${widget.challenge.participants.length}'),
                  if (widget.challenge.entryFee > 0)
                    _buildStatRow('Entry Fee', '\$${widget.challenge.entryFee.toStringAsFixed(2)}'),
                  if (widget.challenge.prizePool > 0)
                    _buildStatRow('Prize Pool', '\$${widget.challenge.prizePool.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Target Goals
          if (widget.challenge.targetGoal != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.challenge.targetGoal!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key.toUpperCase()}:',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            Text('${entry.value}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Join/Progress Section
          if (!_isParticipating)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Join Challenge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _joinChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Join Now'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (!_isParticipating) {
      return const Center(
        child: Text('Join the challenge to track your progress'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_userProgress != null) ...[
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Rank: #${_userProgress!.rank}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_userProgress!.percentageComplete.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _userProgress!.percentageComplete / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.challenge.targetGoal != null)
                      ...widget.challenge.targetGoal!.entries.map((entry) {
                        final current = _userProgress!.currentProgress[entry.key] ?? 0;
                        final target = entry.value;
                        final percentage = target > 0 ? (current / target) * 100 : 0.0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text('$current / $target'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  percentage >= 100 ? Colors.green : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Update Progress Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (widget.challenge.targetGoal != null)
                          ...widget.challenge.targetGoal!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: TextFormField(
                                controller: _progressControllers[entry.key],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Add ${entry.key}',
                                  border: const OutlineInputBorder(),
                                  suffixText: entry.key,
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final number = int.tryParse(value);
                                    if (number == null || number < 0) {
                                      return 'Please enter a valid number';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            );
                          }).toList(),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _updateProgress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Update Progress'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Consumer<ChallengesProvider>(
      builder: (context, provider, child) {
        final progressList = provider.getChallengeProgress(widget.challenge.id);

        if (progressList.isEmpty) {
          return const Center(
            child: Text('No participants yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: progressList.length,
          itemBuilder: (context, index) {
            final progress = progressList[index];
            final isCurrentUser = progress.userId == 'current_user_id'; // TODO: Get from auth

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: isCurrentUser ? Colors.blue[50] : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(progress.rank),
                  child: Text(
                    '${progress.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      progress.userName,
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isCurrentUser)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.person, size: 16, color: Colors.blue),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${progress.percentageComplete.toStringAsFixed(1)}% complete',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (progress.rank == 1)
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    if (progress.rank == 2)
                      const Icon(Icons.emoji_events, color: Colors.grey, size: 20),
                    if (progress.rank == 3)
                      const Icon(Icons.emoji_events, color: Colors.brown, size: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Progress'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildProgressTab(),
          _buildLeaderboardTab(),
        ],
      ),
    );
  }
} 