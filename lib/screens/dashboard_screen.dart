import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db/app_database.dart';
import '../providers/theme_provider.dart';
import 'challenges_list_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'rewards_screen.dart';
import 'fitness_goals_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'live_exercise_screen.dart';
import 'feedback_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String? username;
  final int? age;
  final double? height;
  final double? weight;
  const DashboardScreen({
    super.key,
    this.username,
    this.age,
    this.height,
    this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = auth.currentUser?.username ?? username ?? "User";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProv, _) => IconButton(
              tooltip: themeProv.isDark ? 'Switch to light mode' : 'Switch to dark mode',
              onPressed: () => themeProv.toggle(),
              icon: Icon(themeProv.isDark ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
          IconButton(
            tooltip: 'Dump users to console',
            onPressed: () async {
              final db = context.read<AppDatabase>();
              final all = await db.getAllUsers();
              for (final u in all) {
                // ignore: avoid_print
                print('User(id=' + u.id.toString() + ', email=' + u.email + ', username=' + u.username + ', age=' + (u.age?.toString() ?? 'null') + ', height=' + (u.heightCm?.toString() ?? 'null') + ', weight=' + (u.weightKg?.toString() ?? 'null') + ')');
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dumped ' + all.length.toString() + ' users to console')),
                );
              }
            },
            icon: const Icon(Icons.storage_rounded),
          ),
          Tooltip(
            message: displayName,
            child: PopupMenuButton<String>(
              tooltip: 'Account',
              offset: const Offset(0, 40),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Log out'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CircleAvatar(
                  radius: 16,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Welcome Header
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            
            // Quick Stats
            _buildGoalsOrEmpty(context),
            const SizedBox(height: 24),
            
            // Leaderboard Preview
            _buildLeaderboardPreview(context),
            const SizedBox(height: 24),
            
            // Rewards Preview
            _buildRewardsPreview(context),
            const SizedBox(height: 24),
            
            // History Preview
            _buildHistoryPreview(context),
            const SizedBox(height: 24),
            
            // Main Options Grid
            _buildOptionsGrid(context),
            const SizedBox(height: 32), // Extra padding at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ready for your next fitness challenge?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return const SizedBox.shrink();
  }

  Widget _buildGoalsOrEmpty(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    return FutureBuilder<FitnessGoal?>(
      future: user == null
          ? Future.value(null)
          : context.read<AppDatabase>().getGoalsForUser(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final goals = snapshot.data;
        if (goals == null) {
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
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No goals set yet. Set your daily goals to get started!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FitnessGoalsScreen(),
                      ),
                    );
                  },
                  child: const Text('Set goals'),
                ),
              ],
            ),
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'Daily calories',
                value: goals.dailyCalories.toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer,
                title: 'Exercise minutes',
                value: goals.dailyMinutes.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.directions_walk,
                title: 'Steps',
                value: goals.dailySteps.toString(),
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboardPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🏆 Top Performers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              _buildLeaderboardRow(context, 1, '🥇', 'Fitness Master', '9,850', Colors.amber),
              const Divider(height: 16),
              _buildLeaderboardRow(context, 2, '🥈', 'Yoga Enthusiast', '8,750', Colors.grey),
              const Divider(height: 16),
              _buildLeaderboardRow(context, 3, '🥉', 'Cardio King', '8,200', Colors.brown),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(BuildContext context, int rank, String medal, String name, String score, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              medal,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          score,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🎖️ Your Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RewardsScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRewardCard(
                context,
                icon: Icons.workspace_premium,
                title: 'Badges',
                value: '12',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRewardCard(
                context,
                icon: Icons.monetization_on,
                title: 'Zen Coins',
                value: '2,450',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRewardCard(
                context,
                icon: Icons.local_offer,
                title: 'Coupons',
                value: '3',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📊 Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHistoryCard(
                context,
                icon: Icons.fitness_center,
                title: 'Workouts',
                value: '3',
                subtitle: 'This week',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHistoryCard(
                context,
                icon: Icons.local_fire_department,
                title: 'Calories',
                value: '950',
                subtitle: 'Burned today',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHistoryCard(
                context,
                icon: Icons.timer,
                title: 'Minutes',
                value: '135',
                subtitle: 'Active time',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What would you like to do?',
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildOptionCard(
              context,
              icon: Icons.fitness_center,
              title: 'Challenges',
              subtitle: 'Join fitness challenges',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChallengesListScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.camera_alt,
              title: 'Live Exercise',
              subtitle: 'AI motion detection',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveExerciseScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              subtitle: 'Manage your money',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.leaderboard,
              title: 'Leaderboard',
              subtitle: 'See rankings',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.emoji_events,
              title: 'Rewards',
              subtitle: 'Badges & coins',
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RewardsScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.fitness_center,
              title: 'Fitness Goals',
              subtitle: 'Set your targets',
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FitnessGoalsScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.history,
              title: 'Workout History',
              subtitle: 'Track your progress',
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.feedback,
              title: 'Feedback History',
              subtitle: 'Exercise feedback',
              color: Colors.pink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackHistoryScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.person,
              title: 'Profile',
              subtitle: 'Your account',
              color: Colors.cyan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences',
              color: Colors.grey,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 