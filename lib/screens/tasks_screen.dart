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
  String _filter = 'all'; // all, active, done

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

  void _showAddDialog() async {
    final result = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _TaskBottomSheet(),
    );
    if (result != null) {
      HapticFeedback.mediumImpact();
      setState(() => _tasks.insert(0, result));
      _save();
    }
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

  List<Task> get _filteredTasks {
    if (_filter == 'active') return _tasks.where((t) => !t.done).toList();
    if (_filter == 'done') return _tasks.where((t) => t.done).toList();
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المهام اليومية', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add),
      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          // أزرار الفلترة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterChip('الكل', 'all'),
                _filterChip('المتبقي', 'active'),
                _filterChip('المكتمل', 'done'),
              ],
            ),
          ),
          Expanded(
            child: _filteredTasks.isEmpty
                ? _EmptyState(icon: Icons.task_alt, text: 'مفيش مهام هنا..')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, i) {
                      final t = _filteredTasks[i];
                      Color pColor = t.priority == 2 ? Colors.redAccent : (t.priority == 1 ? Colors.orangeAccent : Colors.greenAccent);
                      return Dismissible(
                        key: Key(t.id),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('تأكيد الحذف'),
                              content: const Text('هل أنت متأكد من حذف هذه المهمة؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => _delete(t),
                        background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.redAccent.withOpacity(0.8), child: const Icon(Icons.delete, color: Colors.white)),
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
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: t.done ? const Color(0xFF6C63FF) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                                ),
                                child: t.done ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                              ),
                            ),
                            title: Text(t.title, style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null, color: t.done ? Colors.grey : Colors.white)),
                            trailing: Container(width: 8, height: 8, decoration: BoxDecoration(color: pColor, shape: BoxShape.circle)),
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

  Widget _filterChip(String title, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF1A1A20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _TaskBottomSheet extends StatefulWidget {
  const _TaskBottomSheet();
  @override
  State<_TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<_TaskBottomSheet> {
  final _title = TextEditingController();
  int _priority = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'عنوان المهمة'), autofocus: true),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _prioBtn('منخفضة', 0, Colors.greenAccent),
              _prioBtn('متوسطة', 1, Colors.orangeAccent),
              _prioBtn('عالية', 2, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton(
              onPressed: () {
                if (_title.text.trim().isEmpty) return;
                Navigator.pop(context, Task(id: const Uuid().v4(), title: _title.text.trim(), priority: _priority, createdAt: DateTime.now()));
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              child: const Text('إضافة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prioBtn(String text, int val, Color color) {
    final selected = _priority == val;
    return GestureDetector(
      onTap: () => setState(() => _priority = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: selected ? color : Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(color: selected ? color : Colors.grey)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.withOpacity(0.5)).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 18)).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}
