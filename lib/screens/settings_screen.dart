import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData() async {
    final data = await StorageService().exportAllData();
    await Share.share(data, subject: 'Life OS Backup');
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
            child: SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF6C63FF)),
              title: const Text('الوضع الليلي'),
              value: isDark,
              activeColor: const Color(0xFF6C63FF),
              onChanged: (val) => ThemeService.toggleTheme(val),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: isDark ? const Color(0xFF1A1A20) : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.greenAccent),
              title: const Text('تجربة الإشعارات'),
              onTap: () => NotificationService().showInstantNotification('أهلاً بك 👋', 'الإشعارات شغالة تمام!'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: isDark ? const Color(0xFF1A1A20) : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blueAccent),
              title: const Text('نسخ احتياطي (تصدير)'),
              onTap: _exportData,
            ),
          ),
        ],
      ),
    );
  }
}
