import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/utils/date_time_utils.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class PomodoroProvider extends ChangeNotifier {
  PomodoroProvider({
    required this.databaseService,
    required this.notificationService,
  }) {
    unawaited(_loadStats());
  }

  final DatabaseService databaseService;
  final NotificationService notificationService;

  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isBreak = false;
  int _remainingSeconds = 25 * 60;
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  String _subject = 'General';
  int _todayFocusMinutes = 0;
  int _weeklyFocusMinutes = 0;
  int _completedSessions = 0;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isBreak => _isBreak;
  int get remainingSeconds => _remainingSeconds;
  int get focusMinutes => _focusMinutes;
  int get breakMinutes => _breakMinutes;
  String get subject => _subject;
  int get todayFocusMinutes => _todayFocusMinutes;
  int get weeklyFocusMinutes => _weeklyFocusMinutes;
  int get completedSessions => _completedSessions;

  String get formattedRemaining {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get phaseLabel => _isBreak ? 'Break Time' : 'Focus Time';

  Future<void> _loadStats() async {
    final List<PomodoroSession> sessions = await databaseService.fetchPomodoroSessions();
    final DateTime today = DateTimeUtils.dayOnly(DateTime.now());
    final DateTime weekStart = today.subtract(Duration(days: today.weekday - 1));

    _todayFocusMinutes = sessions
        .where((PomodoroSession session) => DateTimeUtils.dayOnly(session.startedAt) == today && session.completed)
        .fold<int>(0, (int total, PomodoroSession session) => total + session.focusMinutes);

    _weeklyFocusMinutes = sessions
        .where((PomodoroSession session) => !session.startedAt.isBefore(weekStart) && session.completed)
        .fold<int>(0, (int total, PomodoroSession session) => total + session.focusMinutes);

    _completedSessions = sessions.where((PomodoroSession session) => session.completed).length;
    notifyListeners();
  }

  void start({
    required String subject,
    int focusMinutes = 25,
    int breakMinutes = 5,
  }) {
    _timer?.cancel();
    _subject = subject;
    _focusMinutes = focusMinutes;
    _breakMinutes = breakMinutes;
    _remainingSeconds = focusMinutes * 60;
    _isRunning = true;
    _isPaused = false;
    _isBreak = false;
    _startTimer();
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _isPaused = true;
    _isRunning = false;
    notifyListeners();
  }

  void resume() {
    if (_remainingSeconds <= 0) {
      return;
    }
    _isPaused = false;
    _isRunning = true;
    _startTimer();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isBreak = false;
    _remainingSeconds = _focusMinutes * 60;
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
        return;
      }

      if (!_isBreak) {
        await _completeFocusSession();
        if (_breakMinutes > 0) {
          _isBreak = true;
          _remainingSeconds = _breakMinutes * 60;
          notifyListeners();
          return;
        }
      }

      reset();
    });
  }

  Future<void> _completeFocusSession() async {
    final PomodoroSession session = PomodoroSession(
      id: 'pomodoro_${DateTime.now().microsecondsSinceEpoch}',
      subject: _subject,
      startedAt: DateTime.now(),
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      completed: true,
    );
    await databaseService.insertPomodoroSession(session);
    await notificationService.showPomodoroComplete(_subject);
    await _loadStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
