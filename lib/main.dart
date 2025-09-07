import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/challenges_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChallengesProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MaterialApp(
        title: 'Fitness Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const FitnessTrackerHome(),
      ),
    );
  }
}

class FitnessTrackerHome extends StatefulWidget {
  const FitnessTrackerHome({super.key});

  @override
  State<FitnessTrackerHome> createState() => _FitnessTrackerHomeState();
}

class _FitnessTrackerHomeState extends State<FitnessTrackerHome> {
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
