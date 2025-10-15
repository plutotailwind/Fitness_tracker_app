import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/widgets/auth_desktop_layout.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({super.key});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthDesktopLayout(
      title: 'A few more details',
      subtitle: 'Personalize your experience for better insights.',
      side: const _InfoSideArt(),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Age',
                      icon: Icons.cake_outlined,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your age' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Height (cm)',
                      icon: Icons.height,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter height' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              decoration: buildFilledInputDecoration(
                context: context,
                label: 'Weight (kg)',
                icon: Icons.monitor_weight_outlined,
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter weight' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final auth = context.read<AuthProvider>();
                  final user = auth.currentUser;
                  if (user == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No user in session')),
                      );
                    }
                    return;
                  }
                  final age = int.tryParse(_ageController.text.trim());
                  final height = double.tryParse(_heightController.text.trim());
                  final weight = double.tryParse(_weightController.text.trim());
                  final ok = await auth.saveAdditionalInfo(
                    userId: user.id,
                    age: age,
                    heightCm: height,
                    weightKg: weight,
                  );
                  if (!ok) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save info')),
                      );
                    }
                    return;
                  }
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
                label: const Text('Finish setup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSideArt extends StatelessWidget {
  const _InfoSideArt();

  @override
  Widget build(BuildContext context) {
    final onContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    return Stack(
      children: [
        Positioned(
          right: -20,
          top: -10,
          child: Icon(Icons.insights_rounded, size: 160, color: onContainer.withOpacity(0.08)),
        ),
        Positioned(
          left: -20,
          bottom: -20,
          child: Icon(Icons.track_changes_rounded, size: 140, color: onContainer.withOpacity(0.08)),
        ),
      ],
    );
  }
}

