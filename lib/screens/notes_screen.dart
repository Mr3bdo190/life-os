import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _storage = StorageService();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await _storage.loadNotes();
    setState(() => _notes = notes);
  }

  Future<void> _save() => _storage.saveNotes(_notes);

  Future<void> _add() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _NoteDialog(),
    );
    if (result == null) return;
    setState(() {
      _notes.insert(0, Note(
        id: const Uuid().v4(),
        title: result['title']!,
        body: result['body']!,
        createdAt: DateTime.now(),
      ));
    });
    _save();
  }

  void _delete(Note n) {
    setState(() => _notes.remove(n));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملاحظات'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: _notes.isEmpty
          ? const Center(child: Text('مفيش ملاحظات لسه'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notes.length,
              itemBuilder: (context, i) {
                final n = _notes[i];
                return Card(
                  child: ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(n),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog();

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ملاحظة جديدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'العنوان')),
          const SizedBox(height: 8),
          TextField(controller: _body, maxLines: 4, decoration: const InputDecoration(labelText: 'المحتوى')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'title': _title.text.trim(),
            'body': _body.text.trim(),
          }),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
