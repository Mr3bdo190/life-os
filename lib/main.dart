import 'package:flutter/material.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D6F)),
        useMaterial3: true,
      ),
      locale: const Locale('ar', 'EG'),
      home: const HomeScreen(),
    );
  }
}
