import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/widgets/auth_desktop_layout.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthDesktopLayout(
      title: 'Create your account',
      subtitle: 'Join the community and start your fitness journey.',
      side: const _SignupSideArt(),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your email';
                      } else if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mobileController,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Mobile number',
                      icon: Icons.phone_outlined,
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your mobile number';
                      } else if (value.length != 10) {
                        return 'Enter a 10-digit number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: buildFilledInputDecoration(
                context: context,
                label: 'Username',
                icon: Icons.person_outline,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Choose a username' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Password',
                      icon: Icons.lock_outline,
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value == null || value.length < 6
                            ? 'Use at least 6 characters'
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Confirm password',
                      icon: Icons.lock_reset_outlined,
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value != _passwordController.text
                            ? 'Passwords don\'t match'
                            : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final auth = context.read<AuthProvider>();
                  try {
                    await auth.signup(
                      email: _emailController.text.trim(),
                      mobile: _mobileController.text.trim(),
                      username: _usernameController.text.trim(),
                      password: _passwordController.text,
                    );
                    if (context.mounted) {
                      Navigator.pushNamed(context, '/additional-info');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign up failed: $e')),
                      );
                    }
                  }
                },
                label: const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?'),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Log in'),
          ),
        ],
      ),
    );
  }
}

class _SignupSideArt extends StatelessWidget {
  const _SignupSideArt();

  @override
  Widget build(BuildContext context) {
    final onContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    return Stack(
      children: [
        Positioned(
          left: -20,
          top: -20,
          child: Icon(Icons.directions_run_rounded, size: 160, color: onContainer.withOpacity(0.08)),
        ),
        Positioned(
          right: -30,
          bottom: -10,
          child: Icon(Icons.favorite_outline, size: 140, color: onContainer.withOpacity(0.08)),
        ),
      ],
    );
  }
}

