import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح البيانات'),
        content: const Text('هتتمسح كل المهام والملاحظات نهائياً. متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('مسح', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح كل البيانات ✅')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: isDark ? const Color(0xFF1A1A20) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF6C63FF)),
              title: const Text('الوضع الليلي (Dark Mode)'),
              value: isDark,
              activeColor: const Color(0xFF6C63FF),
              onChanged: (val) => ThemeService.toggleTheme(val),
            ),
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 16),
          Card(
            color: isDark ? const Color(0xFF1A1A20) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.greenAccent),
              title: const Text('تجربة الإشعارات'),
              subtitle: const Text('اضغط هنا عشان تجرب شكل الإشعار'),
              onTap: () {
                NotificationService().showInstantNotification('أهلاً بك في حياتي 👋', 'ده إشعار تجريبي عشان تشوف شكله!');
              },
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(),
          const SizedBox(height: 16),
          Card(
            color: isDark ? const Color(0xFF1A1A20) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('مسح كل البيانات'),
              subtitle: const Text('حذف المهام، العادات، الميزانية..'),
              onTap: () => _clearData(context),
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(),
        ],
      ),
    );
  }
}
