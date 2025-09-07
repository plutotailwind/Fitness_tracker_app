import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart' as leaderboard_models;

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late List<leaderboard_models.Badge> _mockBadges;
  late List<Map<String, dynamic>> _mockCoupons;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _mockBadges = [
      leaderboard_models.Badge(
        id: '1',
        name: '🏆',
        description: 'First place in global leaderboard',
        type: leaderboard_models.BadgeType.firstPlace,
        iconPath: '',
        earnedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      leaderboard_models.Badge(
        id: '2',
        name: '🥈',
        description: 'Second place in weekly challenge',
        type: leaderboard_models.BadgeType.secondPlace,
        iconPath: '',
        earnedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      leaderboard_models.Badge(
        id: '3',
        name: '🔥',
        description: '7-day workout streak',
        type: leaderboard_models.BadgeType.streakMaster,
        iconPath: '',
        earnedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      leaderboard_models.Badge(
        id: '4',
        name: '💪',
        description: 'Completed 10 challenges',
        type: leaderboard_models.BadgeType.challengeChampion,
        iconPath: '',
        earnedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _mockCoupons = [
      {
        'name': '20% Off Gym Membership',
        'description': 'Valid at participating fitness centers',
        'validUntil': DateTime.now().add(const Duration(days: 30)),
      },
      {
        'name': 'Free Protein Shake',
        'description': 'Redeem at any nutrition store',
        'validUntil': DateTime.now().add(const Duration(days: 14)),
      },
      {
        'name': '50% Off Yoga Class',
        'description': 'First-time customers only',
        'validUntil': DateTime.now().add(const Duration(days: 7)),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Badges'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Back to Wallet',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRewardsSummary(context),
            const SizedBox(height: 24),
            _buildBadgesSection(context),
            const SizedBox(height: 24),
            _buildZenCoinsSection(context),
            const SizedBox(height: 24),
            _buildCouponsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Badges', '12', Icons.workspace_premium),
              _buildStatItem('Zen Coins', '2,450', Icons.monetization_on),
              _buildStatItem('Coupons', '3', Icons.local_offer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏆 Badges Earned',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _mockBadges.length,
          itemBuilder: (context, index) {
            final badge = _mockBadges[index];
            return _buildBadgeCard(badge);
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard(leaderboard_models.Badge badge) {
    return Container(
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getBadgeColor(badge.type),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                badge.name,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Earned ${_formatDate(badge.earnedAt)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(leaderboard_models.BadgeType type) {
    switch (type) {
      case leaderboard_models.BadgeType.firstPlace:
        return Colors.amber;
      case leaderboard_models.BadgeType.secondPlace:
        return Colors.grey;
      case leaderboard_models.BadgeType.thirdPlace:
        return Colors.brown;
      case leaderboard_models.BadgeType.topTen:
        return Colors.blue;
      case leaderboard_models.BadgeType.topHundred:
        return Colors.green;
      case leaderboard_models.BadgeType.streakMaster:
        return Colors.orange;
      case leaderboard_models.BadgeType.challengeChampion:
        return Colors.purple;
      case leaderboard_models.BadgeType.fitnessGuru:
        return Colors.teal;
      case leaderboard_models.BadgeType.consistentPerformer:
        return Colors.indigo;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  Widget _buildZenCoinsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🪙 Zen Coins',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: Colors.amber[700],
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2,450 Zen Coins',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                    Text(
                      'Available for rewards and challenges',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to zen coins screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Use Coins'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCouponsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎫 Available Coupons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockCoupons.length,
          itemBuilder: (context, index) {
            final coupon = _mockCoupons[index];
            return _buildCouponCard(coupon);
          },
        ),
      ],
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
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
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.local_offer,
                  color: Colors.green[600],
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valid until ${_formatDate(coupon['validUntil'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Use coupon
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Use'),
            ),
          ],
        ),
      ),
    );
  }
}
