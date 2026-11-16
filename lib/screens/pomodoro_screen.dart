import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});
  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int focusTime = 25 * 60;
  static const int breakTime = 5 * 60;
  
  int _secondsRemaining = focusTime;
  bool _isRunning = false;
  bool _isFocus = true;
  Timer? _timer;

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            _isFocus = !_isFocus;
            _secondsRemaining = _isFocus ? focusTime : breakTime;
          });
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isFocus ? 'وقت التركيز!' : 'وقت الراحة!')));
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFocus = true;
      _secondsRemaining = focusTime;
    });
  }

  String get _timeString {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مؤقت التركيز (Pomodoro)', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isFocus ? 'وقت التركيز 🎯' : 'وقت الراحة ☕', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250, height: 250,
                  child: CircularProgressIndicator(
                    value: _secondsRemaining / (_isFocus ? focusTime : breakTime),
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_isFocus ? const Color(0xFF6C63FF) : Colors.greenAccent),
                  ),
                ),
                Text(_timeString, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 40),
                  style: IconButton.styleFrom(
                    backgroundColor: _isFocus ? const Color(0xFF6C63FF) : Colors.greenAccent,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton.filled(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 30),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
