import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final _searchController = TextEditingController();
  List<Note> _notes = [];
  String _searchQuery = '';

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
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context, isScrollControlled: true, backgroundColor: const Color(0xFF1A1A20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _NoteBottomSheet(),
    );
    if (result == null) return;
    setState(() => _notes.insert(0, Note(id: const Uuid().v4(), title: result['title']!, body: result['body']!, createdAt: DateTime.now())));
    _save();
  }

  List<Note> get _filteredNotes => _notes.where((n) => n.title.contains(_searchQuery) || n.body.contains(_searchQuery)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أفكاري', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      floatingActionButton: FloatingActionButton(onPressed: _add, backgroundColor: const Color(0xFF6C63FF), child: const Icon(Icons.add)).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(hintText: 'ابحث في ملاحظاتك...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(child: Text('مفيش ملاحظات مطابقة..', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, i) {
                      final n = _filteredNotes[i];
                      return Dismissible(
                        key: Key(n.id),
                        confirmDismiss: (_) async => await showDialog(context: context, builder: (context) => AlertDialog(title: const Text('حذف'), content: const Text('متأكد من حذف الملاحظة؟'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف'))])),
                        onDismissed: (_) { setState(() => _notes.remove(n)); _save(); },
                        background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.redAccent, child: const Icon(Icons.delete, color: Colors.white)),
                        child: Card(
                          color: const Color(0xFF1A1A20),
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                if (n.body.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(n.body, style: const TextStyle(color: Colors.white70, height: 1.5)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideX(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoteBottomSheet extends StatefulWidget {
  const _NoteBottomSheet();
  @override
  State<_NoteBottomSheet> createState() => _NoteBottomSheetState();
}

class _NoteBottomSheetState extends State<_NoteBottomSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'العنوان'), autofocus: true),
          const SizedBox(height: 16),
          TextField(controller: _body, maxLines: 5, decoration: const InputDecoration(labelText: 'التفاصيل...')),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: () => Navigator.pop(context, {'title': _title.text.trim().isEmpty ? 'بدون عنوان' : _title.text.trim(), 'body': _body.text.trim()}), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)), child: const Text('حفظ'))),
        ],
      ),
    );
  }
}
