import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _storage = StorageService();
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goals = await _storage.loadGoals();
    setState(() => _goals = goals);
  }

  Future<void> _save() => _storage.saveGoals(_goals);

  void _add(Goal goal) {
    HapticFeedback.mediumImpact();
    setState(() => _goals.insert(0, goal));
    _save();
  }

  void _delete(Goal goal) {
    HapticFeedback.heavyImpact();
    setState(() => _goals.remove(goal));
    _save();
  }

  void _updateProgress(Goal goal, double newProgress) {
    setState(() {
      goal.progress = newProgress;
      goal.isCompleted = newProgress >= 100;
    });
    _save();
  }

  void _showAddDialog() async {
    final result = await showModalBottomSheet<Goal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _GoalBottomSheet(),
    );
    if (result != null) _add(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أهدافي', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add),
      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
      body: _goals.isEmpty
          ? const Center(child: Text('مفيش أهداف لسه.. حدد حلمك وابدأ!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _goals.length,
              itemBuilder: (context, i) {
                final goal = _goals[i];
                return Dismissible(
                  key: Key(goal.id),
                  onDismissed: (_) => _delete(goal),
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.redAccent.withOpacity(0.8), child: const Icon(Icons.delete, color: Colors.white)),
                  child: Card(
                    color: const Color(0xFF1A1A20),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(goal.isCompleted ? Icons.emoji_events : Icons.flag, color: goal.isCompleted ? Colors.amber : Colors.cyanAccent),
                              const SizedBox(width: 8),
                              Expanded(child: Text(goal.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: goal.isCompleted ? TextDecoration.lineThrough : null))),
                              Text('${goal.progress.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: goal.isCompleted ? Colors.amber : Colors.cyanAccent)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: goal.progress,
                            min: 0, max: 100, divisions: 20,
                            activeColor: goal.isCompleted ? Colors.amber : const Color(0xFF6C63FF),
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              _updateProgress(goal, v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
                );
              },
            ),
    );
  }
}

class _GoalBottomSheet extends StatefulWidget {
  const _GoalBottomSheet();
  @override
  State<_GoalBottomSheet> createState() => _GoalBottomSheetState();
}

class _GoalBottomSheetState extends State<_GoalBottomSheet> {
  final _title = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'الهدف (مثلاً: أحفظ القرآن)', border: OutlineInputBorder()), autofocus: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton(
              onPressed: () {
                if (_title.text.trim().isEmpty) return;
                SystemSound.play(SystemSoundType.click);
                Navigator.pop(context, Goal(id: const Uuid().v4(), title: _title.text.trim()));
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              child: const Text('إضافة الهدف'),
            ),
          ),
        ],
      ),
    );
  }
}
