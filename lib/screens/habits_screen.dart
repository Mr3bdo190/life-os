import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _storage = StorageService();
  final _controller = TextEditingController();
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final habits = await _storage.loadHabits();
    setState(() => _habits = habits);
  }

  Future<void> _save() => _storage.saveHabits(_habits);

  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _habits.insert(0, Habit(id: const Uuid().v4(), title: text, createdAt: DateTime.now()));
    });
    _controller.clear();
    _save();
  }

  void _toggle(Habit h) {
    HapticFeedback.lightImpact();
    setState(() {
      if (h.completedDates.contains(_today)) {
        h.completedDates.remove(_today);
      } else {
        h.completedDates.add(_today);
      }
    });
    _save();
  }

  void _delete(Habit h) {
    HapticFeedback.heavyImpact();
    setState(() => _habits.remove(h));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عاداتي اليومية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'أضف عادة جديدة (مثلاً: قراءة 10 صفحات)',
                      filled: true,
                      fillColor: const Color(0xFF1A1A20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.star, color: Color(0xFF6C63FF)),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _habits.isEmpty
                ? const Center(child: Text('مفيش عادات لسه.. ابدأ تبني نفسك!'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _habits.length,
                    itemBuilder: (context, i) {
                      final h = _habits[i];
                      final isDoneToday = h.completedDates.contains(_today);
                      final streak = h.completedDates.length;

                      return Card(
                        color: const Color(0xFF1A1A20),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(h.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Text('سلسلة: $streak يوم 🔥', style: TextStyle(color: Colors.orange.shade300)),
                          trailing: IconButton(
                            icon: Icon(
                              isDoneToday ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isDoneToday ? const Color(0xFF6C63FF) : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () => _toggle(h),
                          ),
                          onLongPress: () => _delete(h),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
