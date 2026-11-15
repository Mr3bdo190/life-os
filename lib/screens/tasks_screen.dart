import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _storage = StorageService();
  final _controller = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await _storage.loadTasks();
    setState(() => _tasks = tasks);
  }

  Future<void> _save() => _storage.saveTasks(_tasks);

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact(); // اهتزاز خفيف
    setState(() {
      _tasks.insert(0, Task(
        id: const Uuid().v4(),
        title: text,
        createdAt: DateTime.now(),
      ));
    });
    _controller.clear();
    _save();
  }

  void _toggle(Task t) {
    HapticFeedback.lightImpact();
    setState(() => t.done = !t.done);
    _save();
  }

  void _delete(Task t) {
    HapticFeedback.heavyImpact();
    setState(() => _tasks.remove(t));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام اليومية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'أضف مهمة جديدة...',
                      filled: true,
                      fillColor: const Color(0xFF1A1A20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.add_task, color: Color(0xFF6C63FF)),
                    ),
                    onSubmitted: (_) => _add(),
                  ).animate().fadeIn().slideX(),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click); // صوت ضغطة
                    _add();
                  },
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.all(16),
                  ),
                ).animate().fadeIn().scale(),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('مفيش مهام لسه.. ابدأ يومك!')).animate().fadeIn(delay: 300.ms)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, i) {
                      final t = _tasks[i];
                      return Dismissible(
                        key: Key(t.id),
                        onDismissed: (_) => _delete(t),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.redAccent.withOpacity(0.8),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          color: const Color(0xFF1A1A20),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: GestureDetector(
                              onTap: () => _toggle(t),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: t.done ? const Color(0xFF6C63FF) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                                ),
                                child: t.done ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                              ),
                            ),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                decoration: t.done ? TextDecoration.lineThrough : null,
                                color: t.done ? Colors.grey : Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _delete(t),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
