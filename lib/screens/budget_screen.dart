import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _storage = StorageService();
  List<BudgetItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _storage.loadBudget();
    setState(() => _items = items);
  }

  Future<void> _save() => _storage.saveBudget(_items);

  double get _totalIncome => _items.where((i) => !i.isExpense).fold(0, (sum, item) => sum + item.amount);
  double get _totalExpense => _items.where((i) => i.isExpense).fold(0, (sum, item) => sum + item.amount);
  double get _balance => _totalIncome - _totalExpense;

  void _addItem(BudgetItem item) {
    HapticFeedback.mediumImpact();
    setState(() => _items.insert(0, item));
    _save();
  }

  void _delete(BudgetItem item) {
    HapticFeedback.heavyImpact();
    setState(() => _items.remove(item));
    _save();
  }

  Future<void> _showAddDialog() async {
    final result = await showModalBottomSheet<BudgetItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _BudgetBottomSheet(),
    );
    if (result != null) _addItem(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الميزانية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add),
      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          // ملخص الميزانية
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  const Text('الرصيد الحالي', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '${_balance.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryColumn(title: 'الدخل', amount: _totalIncome, icon: Icons.arrow_downward, color: Colors.greenAccent),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _SummaryColumn(title: 'المصاريف', amount: _totalExpense, icon: Icons.arrow_upward, color: Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          
          // قائمة العمليات
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('مفيش عمليات مسجلة لسه..'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      final isExpense = item.isExpense;
                      return Dismissible(
                        key: Key(item.id),
                        onDismissed: (_) => _delete(item),
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
                            leading: CircleAvatar(
                              backgroundColor: isExpense ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                              child: Icon(
                                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isExpense ? Colors.redAccent : Colors.greenAccent,
                              ),
                            ),
                            title: Text(item.title),
                            subtitle: Text('${item.date.day}/${item.date.month}/${item.date.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: Text(
                              '${isExpense ? "-" : "+"}${item.amount.toStringAsFixed(0)} ج.م',
                              style: TextStyle(
                                color: isExpense ? Colors.redAccent : Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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

class _SummaryColumn extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryColumn({required this.title, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text('${amount.toStringAsFixed(0)} ج.م', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BudgetBottomSheet extends StatefulWidget {
  const _BudgetBottomSheet();

  @override
  State<_BudgetBottomSheet> createState() => _BudgetBottomSheetState();
}

class _BudgetBottomSheetState extends State<_BudgetBottomSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          
          // زراير اختيار النوع (دخل / مصروف)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isExpense = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isExpense ? Colors.redAccent.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(color: _isExpense ? Colors.redAccent : Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text('مصروف', style: TextStyle(color: _isExpense ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isExpense = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isExpense ? Colors.greenAccent.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(color: !_isExpense ? Colors.greenAccent : Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text('دخل', style: TextStyle(color: !_isExpense ? Colors.greenAccent : Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'الوصف (مثلاً: قهوة، راتب)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'المبلغ (ج.م)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final amount = double.tryParse(_amountController.text.trim());
                if (title.isEmpty || amount == null || amount <= 0) return;
                
                SystemSound.play(SystemSoundType.click);
                Navigator.pop(context, BudgetItem(
                  id: const Uuid().v4(),
                  title: title,
                  amount: amount,
                  isExpense: _isExpense,
                  date: DateTime.now(),
                ));
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              child: const Text('حفظ العملية', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
