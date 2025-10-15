import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/challenges_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/auth_provider.dart';
import 'services/db/app_database.dart';

// Import your screens
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/additional_info_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart'; // You already had this

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
        Provider(create: (_) => AppDatabase()),
        ChangeNotifierProvider(create: (ctx) => AuthProvider(ctx.read<AppDatabase>())),
      ],
      child: MaterialApp(
        title: 'Fitness Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(fontSize: 14),
          ),
        ),

        // Start with signup page for now
        initialRoute: '/signup',

        // Define routes for the app
        routes: {
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          '/additional-info': (context) => const AdditionalInfoScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
