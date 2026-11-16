import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'tasks_screen.dart';
import 'notes_screen.dart';
import 'habits_screen.dart';
import 'budget_screen.dart';
import 'subscriptions_screen.dart';
import 'goals_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حياتي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _DashboardCard(title: 'المهام', icon: Icons.check_circle, color: Colors.blueAccent, onTap: () => _nav(context, const TasksScreen())),
            _DashboardCard(title: 'الملاحظات', icon: Icons.note, color: Colors.amber, onTap: () => _nav(context, const NotesScreen())),
            _DashboardCard(title: 'العادات', icon: Icons.local_fire_department, color: Colors.deepOrange, onTap: () => _nav(context, const HabitsScreen())),
            _DashboardCard(title: 'الميزانية', icon: Icons.account_balance_wallet, color: Colors.greenAccent, onTap: () => _nav(context, const BudgetScreen())),
            _DashboardCard(title: 'الاشتراكات', icon: Icons.subscriptions, color: Colors.purpleAccent, onTap: () => _nav(context, const SubscriptionsScreen())),
            _DashboardCard(title: 'الأهداف', icon: Icons.flag, color: Colors.cyanAccent, onTap: () => _nav(context, const GoalsScreen())),
          ].animate(interval: 50.ms).fadeIn(duration: 400.ms).scale(curve: Curves.easeOutBack),
        ),
      ),
    );
  }

  void _nav(BuildContext context, Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A20),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
