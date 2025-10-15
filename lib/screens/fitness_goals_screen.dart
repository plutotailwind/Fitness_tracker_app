import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db/app_database.dart';
import '../widgets/auth_desktop_layout.dart';

class FitnessGoalsScreen extends StatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  State<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends State<FitnessGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesCtl = TextEditingController();
  final _minutesCtl = TextEditingController();
  final _stepsCtl = TextEditingController();
  final _notesCtl = TextEditingController();

  FitnessGoal? _existing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final db = context.read<AppDatabase>();
    final goals = await db.getGoalsForUser(user.id);
    setState(() {
      _existing = goals;
      _caloriesCtl.text = (goals?.dailyCalories ?? 0).toString();
      _minutesCtl.text = (goals?.dailyMinutes ?? 0).toString();
      _stepsCtl.text = (goals?.dailySteps ?? 0).toString();
      _notesCtl.text = goals?.notes ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _caloriesCtl.dispose();
    _minutesCtl.dispose();
    _stepsCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Goals'),
        actions: [
          IconButton(
            tooltip: 'Dump all users\' goals to console',
            icon: const Icon(Icons.storage_rounded),
            onPressed: () async {
              final db = context.read<AppDatabase>();
              final users = await db.getAllUsers();
              for (final u in users) {
                final g = await db.getGoalsForUser(u.id);
                // ignore: avoid_print
                print('[User ' + u.id.toString() + ' ' + u.username + '] '
                    'cal=' + (g?.dailyCalories.toString() ?? 'null') + ', '
                    'min=' + (g?.dailyMinutes.toString() ?? 'null') + ', '
                    'steps=' + (g?.dailySteps.toString() ?? 'null') + ', '
                    'notes=' + (g?.notes ?? ''));
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dumped ' + users.length.toString() + ' users\' goals to console')),
                );
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AuthDesktopLayout(
              title: 'Your daily goals',
              subtitle: 'Set achievable targets and track progress every day.',
              side: const _GoalsSideArt(),
              maxFormWidth: 560,
              form: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _GoalField(
                          controller: _caloriesCtl,
                          label: 'Daily calories to burn',
                          icon: Icons.local_fire_department,
                        ),
                        _GoalField(
                          controller: _minutesCtl,
                          label: 'Daily exercise minutes',
                          icon: Icons.timer,
                        ),
                        _GoalField(
                          controller: _stepsCtl,
                          label: 'Daily steps',
                          icon: Icons.directions_walk,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtl,
                      maxLines: 3,
                      decoration: buildFilledInputDecoration(
                        context: context,
                        label: 'Notes (optional)',
                        icon: Icons.note_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_existing != null) ...[
                          _InfoChip(icon: Icons.local_fire_department, label: 'Calories', value: _existing!.dailyCalories.toString(), color: Colors.orange),
                          const SizedBox(width: 8),
                          _InfoChip(icon: Icons.timer, label: 'Minutes', value: _existing!.dailyMinutes.toString(), color: Colors.blue),
                          const SizedBox(width: 8),
                          _InfoChip(icon: Icons.directions_walk, label: 'Steps', value: _existing!.dailySteps.toString(), color: Colors.green),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_existing == null ? 'Save goals' : 'Update goals'),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final auth = context.read<AuthProvider>();
                          final user = auth.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login again')),
                            );
                            return;
                          }
                          final db = context.read<AppDatabase>();
                          final calories = int.parse(_caloriesCtl.text);
                          final minutes = int.parse(_minutesCtl.text);
                          final steps = int.parse(_stepsCtl.text);
                          await db.upsertGoals(
                            userId: user.id,
                            dailyCalories: calories,
                            dailyMinutes: minutes,
                            dailySteps: steps,
                            notes: _notesCtl.text.trim().isEmpty ? null : _notesCtl.text.trim(),
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Goals saved')),
                          );
                          await _load();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 

class _GoalField extends StatelessWidget {
  const _GoalField({required this.controller, required this.label, required this.icon});

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: buildFilledInputDecoration(
          context: context,
          label: label,
          icon: icon,
        ),
        validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a number' : null,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label + ':'),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _GoalsSideArt extends StatelessWidget {
  const _GoalsSideArt();

  @override
  Widget build(BuildContext context) {
    final onContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    return Stack(
      children: [
        Positioned(
          left: -20,
          top: -20,
          child: Icon(Icons.flag_circle_outlined, size: 160, color: onContainer.withOpacity(0.08)),
        ),
        Positioned(
          right: -30,
          bottom: -10,
          child: Icon(Icons.checklist_rtl, size: 140, color: onContainer.withOpacity(0.08)),
        ),
      ],
    );
  }
}