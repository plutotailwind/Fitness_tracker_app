import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackHistoryScreen extends StatefulWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  State<FeedbackHistoryScreen> createState() => _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends State<FeedbackHistoryScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('exercise_feedback_history') ?? [];
    final parsed = <Map<String, dynamic>>[];
    for (final s in raw) {
      try {
        parsed.add(Map<String, dynamic>.from(jsonDecode(s)));
      } catch (_) {}
    }
    setState(() {
      _entries = parsed;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exercise_feedback_history');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _entries.isEmpty || _loading ? null : _clearAll,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all',
          ),
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final e = _entries[index];
                    final tips = (e['tips'] as List?)?.cast<String>() ?? const [];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.fitness_center, size: 18),
                              const SizedBox(width: 6),
                              Text((e['exercise'] ?? '').toString()),
                              const Spacer(),
                              Text('Form ${(e['formScore'] ?? 0).toString()}%'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.timer, size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text('${e['durationSeconds'] ?? 0}s', style: const TextStyle(color: Colors.black54)),
                              const SizedBox(width: 12),
                              const Icon(Icons.repeat, size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text('${e['reps'] ?? 0}', style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (tips.isNotEmpty) const Text('Key tips:'),
                          for (final t in tips.take(5)) Text('• $t'),
                          const SizedBox(height: 6),
                          Text(
                            'Started: ${(e['startedAt'] ?? '').toString()}',
                            style: const TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                          Text(
                            'Saved: ${(e['savedAt'] ?? '').toString()}',
                            style: const TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.feedback, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text('No feedback yet'),
          SizedBox(height: 8),
          Text('Start a live session to collect feedback'),
        ],
      ),
    );
  }
}