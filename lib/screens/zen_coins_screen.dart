import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';

class ZenCoinsScreen extends StatefulWidget {
  const ZenCoinsScreen({super.key});

  @override
  State<ZenCoinsScreen> createState() => _ZenCoinsScreenState();
}

class _ZenCoinsScreenState extends State<ZenCoinsScreen> {
  int _zenCoins = 4850;
  int _totalEarned = 5200;
  int _totalSpent = 350;

  // Mock activity rewards
  final List<ActivityReward> _activityRewards = [
    ActivityReward(
      id: '1',
      activityType: 'Daily Login',
      description: '7 day streak bonus',
      zenCoinsEarned: 100,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isClaimed: true,
    ),
    ActivityReward(
      id: '2',
      activityType: 'Challenge Completed',
      description: 'Completed 30-day fitness challenge',
      zenCoinsEarned: 500,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isClaimed: true,
    ),
    ActivityReward(
      id: '3',
      activityType: 'Workout Goal',
      description: 'Achieved weekly workout target',
      zenCoinsEarned: 200,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isClaimed: false,
    ),
    ActivityReward(
      id: '4',
      activityType: 'Referral',
      description: 'Friend joined using your code',
      zenCoinsEarned: 300,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      isClaimed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zen Coins'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zen Coins Balance Card
            _buildBalanceCard(),
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),
            
            // Available Rewards
            _buildAvailableRewards(),
            const SizedBox(height: 24),
            
            // How to Earn
            _buildHowToEarn(),
            const SizedBox(height: 24),
            
            // Purchase Options
            _buildPurchaseOptions(),
            const SizedBox(height: 32), // Extra padding at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zen Coins Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_zenCoins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Earned', '$_totalEarned'),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem('Total Spent', '$_totalSpent'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.shopping_cart,
                title: 'Buy Coins',
                subtitle: 'Purchase Zen Coins',
                color: Colors.blue,
                onTap: () => _showPurchaseDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.card_giftcard,
                title: 'Redeem',
                subtitle: 'Use coins for rewards',
                color: Colors.green,
                onTap: () => _showRedeemDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableRewards() {
    final unclaimedRewards = _activityRewards.where((reward) => !reward.isClaimed).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Rewards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unclaimedRewards.isNotEmpty)
              TextButton(
                onPressed: _claimAllRewards,
                child: const Text('Claim All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (unclaimedRewards.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No rewards available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete activities to earn Zen Coins',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...unclaimedRewards.map((reward) => _buildRewardCard(reward)),
      ],
    );
  }

  Widget _buildRewardCard(ActivityReward reward) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.card_giftcard,
            color: Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          reward.activityType,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reward.description),
            Text(
              DateFormat('MMM dd, yyyy').format(reward.timestamp),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+${reward.zenCoinsEarned}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            ElevatedButton(
              onPressed: () => _claimReward(reward),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 32),
              ),
              child: const Text('Claim'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToEarn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How to Earn Zen Coins',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildEarningMethod(
          icon: Icons.login,
          title: 'Daily Login',
          description: 'Earn 10 coins for daily login',
          coins: '10',
        ),
        _buildEarningMethod(
          icon: Icons.fitness_center,
          title: 'Complete Challenges',
          description: 'Earn 50-500 coins per challenge',
          coins: '50-500',
        ),
        _buildEarningMethod(
          icon: Icons.trending_up,
          title: 'Achieve Goals',
          description: 'Earn coins for reaching fitness goals',
          coins: '25-200',
        ),
        _buildEarningMethod(
          icon: Icons.share,
          title: 'Refer Friends',
          description: 'Earn 100 coins per referral',
          coins: '100',
        ),
        _buildEarningMethod(
          icon: Icons.star,
          title: 'Win Competitions',
          description: 'Earn bonus coins for winning',
          coins: '200-1000',
        ),
      ],
    );
  }

  Widget _buildEarningMethod({
    required IconData icon,
    required String title,
    required String description,
    required String coins,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+$coins',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buy Zen Coins',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildPurchaseOption('100', '₹10', '1.0x'),
            _buildPurchaseOption('500', '₹45', '1.1x'),
            _buildPurchaseOption('1000', '₹85', '1.2x'),
            _buildPurchaseOption('2500', '₹200', '1.3x'),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchaseOption(String coins, String price, String bonus) {
    return Card(
      child: InkWell(
        onTap: () => _purchaseCoins(coins, price),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                coins,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Zen Coins',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (bonus != '1.0x')
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$bonus Bonus',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _claimReward(ActivityReward reward) {
    setState(() {
      _zenCoins += reward.zenCoinsEarned;
      reward.isClaimed = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claimed ${reward.zenCoinsEarned} Zen Coins!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _claimAllRewards() {
    final unclaimedRewards = _activityRewards.where((reward) => !reward.isClaimed).toList();
    int totalCoins = 0;
    
    for (final reward in unclaimedRewards) {
      totalCoins += reward.zenCoinsEarned;
      reward.isClaimed = true;
    }
    
    setState(() {
      _zenCoins += totalCoins;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claimed $totalCoins Zen Coins!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _purchaseCoins(String coins, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Zen Coins'),
        content: Text('Buy $coins Zen Coins for $price?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully purchased $coins Zen Coins!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog() {
    // Show purchase options
    _purchaseCoins('100', '₹10');
  }

  void _showRedeemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Zen Coins'),
        content: const Text('What would you like to redeem your Zen Coins for?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redeem feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
} 