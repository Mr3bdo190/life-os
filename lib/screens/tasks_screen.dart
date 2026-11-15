import 'package:flutter/material.dart';
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
    setState(() => t.done = !t.done);
    _save();
  }

  void _delete(Task t) {
    setState(() => _tasks.remove(t));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المهام'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'أضف مهمة جديدة...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _add, icon: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('مفيش مهام لسه'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, i) {
                      final t = _tasks[i];
                      return ListTile(
                        leading: Checkbox(
                          value: t.done,
                          onChanged: (_) => _toggle(t),
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(
                            decoration:
                                t.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(t),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
