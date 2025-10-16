import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/db/app_database.dart';
import '../widgets/auth_desktop_layout.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repsController = TextEditingController();
  
  String _selectedType = 'squat';
  int _entryCoins = 0;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final db = context.read<AppDatabase>();
    final user = auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again')),
        );
      }
      return;
    }

    try {
      final reps = int.tryParse(_repsController.text.trim()) ?? 0;
      final targetJson = jsonEncode({'reps': reps});
      await db.createChallengeWithEntry(
        userId: user.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        entryCoins: _entryCoins,
        targetJson: targetJson,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge created and entry coins deducted')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ' + e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthDesktopLayout(
      title: 'Create a personal challenge',
      subtitle: 'Set a goal, put down Zen coins, and earn rewards on success.',
      side: const _ChallengeSideArt(),
      maxFormWidth: 720,
      onBack: () => Navigator.pop(context),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Challenge type',
                      icon: Icons.fitness_center,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'squat', child: Text('SQUAT')),
                      DropdownMenuItem(value: 'pushup', child: Text('PUSHUP')),
                      DropdownMenuItem(value: 'lateral_raise', child: Text('LATERAL RAISE')),
                    ],
                    onChanged: (v) => setState(() => _selectedType = v ?? 'squat'),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Challenge title',
                      icon: Icons.title,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                  ),
                ),
                SizedBox(
                  width: 720,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Description',
                      icon: Icons.description_outlined,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: buildFilledInputDecoration(
                      context: context,
                      label: 'Entry coins (Zen)',
                      icon: Icons.monetization_on_outlined,
                    ),
                    onChanged: (v) => _entryCoins = int.tryParse(v) ?? 0,
                    validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a number' : null,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start date'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _selectStartDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End date'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _selectEndDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: TextFormField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                decoration: buildFilledInputDecoration(
                  context: context,
                  label: 'Target reps',
                  icon: Icons.sports_gymnastics,
                ),
                validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a number' : null,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _createChallenge,
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Create challenge'),
              ),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ],
      ),
    );
  }
} 

class _ChallengeSideArt extends StatelessWidget {
  const _ChallengeSideArt();

  @override
  Widget build(BuildContext context) {
    final onContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    return Stack(
      children: [
        Positioned(
          left: -20,
          top: -20,
          child: Icon(Icons.sports_kabaddi, size: 160, color: onContainer.withOpacity(0.08)),
        ),
        Positioned(
          right: -30,
          bottom: -10,
          child: Icon(Icons.track_changes, size: 140, color: onContainer.withOpacity(0.08)),
        ),
      ],
    );
  }
}