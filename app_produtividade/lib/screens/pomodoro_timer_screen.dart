import 'package:flutter/material.dart';
import 'dart:async';

class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({super.key});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  static const int _pomodoroDuration = 25 * 60; // 25 minutos em segundos
  static const int _shortBreakDuration = 5 * 60; // 5 minutos em segundos
  static const int _longBreakDuration = 15 * 60; // 15 minutos em segundos

  int _currentDuration = _pomodoroDuration;
  int _remainingTime = _pomodoroDuration;
  Timer? _timer;
  bool _isRunning = false;
  String _currentPhase = 'Trabalho';
  int _pomodoroCount = 0; // Para controlar os long breaks

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _onTimerCompleted();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    setState(() {
      _currentDuration = _pomodoroDuration;
      _remainingTime = _pomodoroDuration;
      _currentPhase = 'Trabalho';
      _pomodoroCount = 0;
    });
  }

  void _onTimerCompleted() {
    if (_currentPhase == 'Trabalho') {
      _pomodoroCount++;
      if (_pomodoroCount % 4 == 0) {
        // Long break a cada 4 pomodoros
        _currentPhase = 'Descanso Longo';
        _currentDuration = _longBreakDuration;
      } else {
        // Short break
        _currentPhase = 'Descanso Curto';
        _currentDuration = _shortBreakDuration;
      }
    } else {
      // Voltar para trabalho após o descanso
      _currentPhase = 'Trabalho';
      _currentDuration = _pomodoroDuration;
    }
    _remainingTime = _currentDuration;
    _startTimer(); // Inicia automaticamente a próxima fase
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Pomodoro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentPhase,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _remainingTime / _currentDuration,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF3CA6F6),
                  ),
                ),
                Text(
                  _formatTime(_remainingTime),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  child: Text(_isRunning ? 'PAUSAR' : 'INICIAR'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('REINICIAR'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Pomodoros Concluídos: $_pomodoroCount',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
} 