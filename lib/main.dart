import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LifeOsApp());
}

class LifeOsApp extends StatelessWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حياتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // لون بنفسجي عصري
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFF0F0F13), // خلفية داكنة أنيقة
      ),
      locale: const Locale('ar', 'EG'),
      home: const HomeScreen(),
    );
  }
}
