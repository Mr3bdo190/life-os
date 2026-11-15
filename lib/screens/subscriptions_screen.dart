import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});
  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _storage = StorageService();
  List<Subscription> _subs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final subs = await _storage.loadSubscriptions();
    setState(() => _subs = subs);
  }

  Future<void> _save() => _storage.saveSubscriptions(_subs);

  double get _totalMonthly => _subs.where((s) => s.isActive).fold(0, (sum, s) => sum + s.amount);

  void _add(Subscription sub) {
    HapticFeedback.mediumImpact();
    setState(() => _subs.insert(0, sub));
    _save();
  }

  void _delete(Subscription sub) {
    HapticFeedback.heavyImpact();
    setState(() => _subs.remove(sub));
    _save();
  }

  void _showAddDialog() async {
    final result = await showModalBottomSheet<Subscription>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _SubBottomSheet(),
    );
    if (result != null) _add(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اشتراكاتي', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add),
      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي الاشتراكات الشهرية', style: TextStyle(fontSize: 16)),
                  Text('${_totalMonthly.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                ],
              ),
            ),
          ).animate().fadeIn(),
          Expanded(
            child: _subs.isEmpty
                ? const Center(child: Text('مفيش اشتراكات مسجلة..'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _subs.length,
                    itemBuilder: (context, i) {
                      final sub = _subs[i];
                      final daysLeft = sub.nextBillingDate.difference(DateTime.now()).inDays;
                      final isNear = daysLeft <= 3 && daysLeft >= 0;

                      return Dismissible(
                        key: Key(sub.id),
                        onDismissed: (_) => _delete(sub),
                        background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.redAccent.withOpacity(0.8), child: const Icon(Icons.delete, color: Colors.white)),
                        child: Card(
                          color: const Color(0xFF1A1A20),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(backgroundColor: Colors.purpleAccent.withOpacity(0.2), child: const Icon(Icons.subscriptions, color: Colors.purpleAccent)),
                            title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('التجديد بعد $daysLeft يوم', style: TextStyle(color: isNear ? Colors.orangeAccent : Colors.grey)),
                            trailing: Text('${sub.amount.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

class _SubBottomSheet extends StatefulWidget {
  const _SubBottomSheet();
  @override
  State<_SubBottomSheet> createState() => _SubBottomSheetState();
}

class _SubBottomSheetState extends State<_SubBottomSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  int _daysUntilRenewal = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'اسم الاشتراك (مثلاً: نتفليكس)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ (ج.م)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('التجديد بعد: '),
              Expanded(
                child: Slider(
                  value: _daysUntilRenewal.toDouble(),
                  min: 1, max: 30, divisions: 29,
                  label: '$_daysUntilRenewal يوم',
                  onChanged: (v) => setState(() => _daysUntilRenewal = v.toInt()),
                ),
              ),
              Text('$_daysUntilRenewal يوم', style: const TextStyle(color: Colors.purpleAccent)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton(
              onPressed: () {
                if (_name.text.trim().isEmpty || _amount.text.trim().isEmpty) return;
                SystemSound.play(SystemSoundType.click);
                Navigator.pop(context, Subscription(
                  id: const Uuid().v4(),
                  name: _name.text.trim(),
                  amount: double.tryParse(_amount.text.trim()) ?? 0,
                  nextBillingDate: DateTime.now().add(Duration(days: _daysUntilRenewal)),
                ));
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              child: const Text('حفظ الاشتراك'),
            ),
          ),
        ],
      ),
    );
  }
}
