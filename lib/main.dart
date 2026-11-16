import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await ThemeService.loadTheme();
  runApp(const LifeOsApp());
}

class LifeOsApp extends StatefulWidget {
  const LifeOsApp({super.key});
  @override
  State<LifeOsApp> createState() => _LifeOsAppState();
}

class _LifeOsAppState extends State<LifeOsApp> {
  bool _isLocked = true;

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LockScreen(onUnlock: () => setState(() => _isLocked = false)),
      );
    }

    final baseTheme = ThemeData(useMaterial3: true);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'حياتي',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: baseTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF), brightness: Brightness.light),
            textTheme: GoogleFonts.cairoTextTheme(baseTheme.textTheme),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
          ),
          darkTheme: baseTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF), brightness: Brightness.dark),
            textTheme: GoogleFonts.cairoTextTheme(baseTheme.textTheme).apply(bodyColor: Colors.white, displayColor: Colors.white),
            scaffoldBackgroundColor: const Color(0xFF0F0F13),
            inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFF1A1A20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
          ),
          locale: const Locale('ar', 'EG'),
          home: const HomeScreen(),
        );
      }
    );
  }
}
