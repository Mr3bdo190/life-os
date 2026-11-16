import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const LockScreen({super.key, required this.onUnlock});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      setState(() => _canCheckBiometrics = canCheck);
      if (canCheck) _authenticate();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _authenticate() async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'التطبيق مقفول. يرجى تأكيد هويتك للدخول.',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) widget.onUnlock();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 100, color: Color(0xFF6C63FF)),
            const SizedBox(height: 24),
            const Text('التطبيق مقفول', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 40),
            if (_canCheckBiometrics)
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint, size: 30),
                label: const Text('فتح ببصمة الإصبع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              )
            else
              const Text('البصمة غير متاحة', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
