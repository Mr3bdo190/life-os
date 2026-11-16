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

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  String get _today => _formatDate(DateTime.now());

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _habits.insert(0, Habit(id: const Uuid().v4(), title: text, createdAt: DateTime.now())));
    _controller.clear();
    _save();
  }

  void _toggle(Habit h, String date) {
    HapticFeedback.lightImpact();
    setState(() {
      if (h.completedDates.contains(date)) {
        h.completedDates.remove(date);
      } else {
        h.completedDates.add(date);
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عاداتي اليومية', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'أضف عادة جديدة...', prefixIcon: Icon(Icons.star, color: Color(0xFF6C63FF))),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _add, icon: const Icon(Icons.add), style: IconButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.all(16))),
              ],
            ),
          ),
          Expanded(
            child: _habits.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, size: 80, color: Colors.grey).animate().scale(),
                      const SizedBox(height: 16),
                      const Text('مفيش عادات لسه.. ابدأ تبني نفسك!', style: TextStyle(color: Colors.grey)),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _habits.length,
                    itemBuilder: (context, i) {
                      final h = _habits[i];
                      final isDoneToday = h.completedDates.contains(_today);
                      return Card(
                        color: const Color(0xFF1A1A20),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(h.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                  Text('سلسلة: ${h.completedDates.length} 🔥', style: TextStyle(color: Colors.orange.shade300)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _toggle(h, _today),
                                    child: Icon(isDoneToday ? Icons.check_circle : Icons.radio_button_unchecked, color: isDoneToday ? const Color(0xFF6C63FF) : Colors.grey, size: 28),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // شبكة الـ 7 أيام
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  final date = DateTime.now().subtract(Duration(days: 6 - index));
                                  final dateStr = _formatDate(date);
                                  final isDone = h.completedDates.contains(dateStr);
                                  final isToday = dateStr == _today;
                                  return Column(
                                    children: [
                                      Text(['أحد','إثنين','ثلاثاء','أربعاء','خميس','جمعة','سبت'][date.weekday % 7], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => _toggle(h, dateStr),
                                        child: Container(
                                          width: 30, height: 30,
                                          decoration: BoxDecoration(
                                            color: isDone ? const Color(0xFF6C63FF) : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: isToday ? Colors.amber : (isDone ? const Color(0xFF6C63FF) : Colors.grey)),
                                          ),
                                          child: Center(child: Text('${date.day}', style: TextStyle(fontSize: 12, color: isDone ? Colors.white : Colors.grey))),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
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
