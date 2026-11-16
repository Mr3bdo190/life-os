import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/countdown.dart';
import '../services/storage_service.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});
  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final _storage = StorageService();
  List<CountdownEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await _storage.loadCountdowns();
    setState(() => _events = events);
  }

  Future<void> _save() => _storage.saveCountdowns(_events);

  void _addEvent() async {
    final titleCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حدث جديد'),
        content: TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'اسم الحدث (مثلاً: عيد ميلادي)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true) {
      // نضيف الحدث ونخلي التاريخ بعد 30 يوم كمثال، تقدر تعدله بعدين
      setState(() {
        _events.insert(0, CountdownEvent(
          id: const Uuid().v4(),
          title: titleCtrl.text,
          targetDate: DateTime.now().add(const Duration(days: 30)),
        ));
      });
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العد التنازلي', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      floatingActionButton: FloatingActionButton(onPressed: _addEvent, backgroundColor: const Color(0xFF6C63FF), child: const Icon(Icons.add)),
      body: _events.isEmpty
          ? const Center(child: Text('مفيش أحداث قادمة.. أضف حدث!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, i) {
                final e = _events[i];
                final daysLeft = e.targetDate.difference(DateTime.now()).inDays;
                return Card(
                  color: const Color(0xFF1A1A20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.timer, color: Colors.amberAccent),
                    title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text('$daysLeft يوم', style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}
