import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/widgets/auth_desktop_layout.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthDesktopLayout(
      title: 'Welcome back',
      subtitle: 'Log in to track your workouts and stay on top of your goals.',
      side: const _LoginSideArt(),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: buildFilledInputDecoration(
                context: context,
                label: 'Username or Email',
                icon: Icons.person_outline,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your username or email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: buildFilledInputDecoration(
                context: context,
                label: 'Password',
                icon: Icons.lock_outline,
              ),
              obscureText: true,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your password' : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.login_rounded),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final auth = context.read<AuthProvider>();
                  final user = await auth.login(
                    identifier: _usernameController.text.trim(),
                    password: _passwordController.text,
                  );
                  if (user != null) {
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid credentials')),
                      );
                    }
                  }
                },
                label: const Text('Log in'),
              ),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?"),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signup');
            },
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }
}

class _LoginSideArt extends StatelessWidget {
  const _LoginSideArt();

  @override
  Widget build(BuildContext context) {
    final onContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    return Stack(
      children: [
        Positioned(
          right: -30,
          top: -30,
          child: Icon(Icons.timer_outlined, size: 160, color: onContainer.withOpacity(0.08)),
        ),
        Positioned(
          left: -10,
          bottom: -20,
          child: Icon(Icons.show_chart_rounded, size: 140, color: onContainer.withOpacity(0.08)),
        ),
      ],
    );
  }
}

