import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/goal.dart';
import '../models/routine_task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(settings);
  }

  Future<void> scheduleRoutineReminder(RoutineTask task, String userName) async {
    if (!task.reminderEnabled) {
      return;
    }

    final tz.TZDateTime firstTime = tz.TZDateTime.from(task.startDateTime, tz.local);
    if (firstTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    for (int index = 0; index < 3; index++) {
      await _plugin.zonedSchedule(
        _baseId(task.id) + index,
        'Shindhu Study Alarm',
        '$userName, it is time for ${task.title}. Stay focused until you dismiss this reminder.',
        firstTime.add(Duration(minutes: index * 3)),
        NotificationDetails(android: _androidDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelRoutineReminder(String taskId) async {
    for (int index = 0; index < 3; index++) {
      await _plugin.cancel(_baseId(taskId) + index);
    }
  }

  Future<void> scheduleGoalReminder(Goal goal, String userName) async {
    final DateTime reminderTime = DateTime(
      goal.dueDate.year,
      goal.dueDate.month,
      goal.dueDate.day,
      19,
    );
    final tz.TZDateTime scheduleTime = tz.TZDateTime.from(reminderTime, tz.local);
    if (scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _plugin.zonedSchedule(
      _baseId(goal.id),
      'Goal Check-in',
      '$userName, review your goal "${goal.title}" before the day ends.',
      scheduleTime,
      NotificationDetails(android: _androidDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showPomodoroComplete(String subject) async {
    await _plugin.show(
      90420,
      'Focus Session Complete',
      'Great work. Your $subject Pomodoro session is complete.',
      NotificationDetails(android: _androidDetails()),
    );
  }

  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      'shindhu_study_channel',
      'Shindhu Study Alerts',
      channelDescription: 'Routine alarms, reminders, and timer alerts for Shindhu.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alarm_tone'),
    );
  }

  int _baseId(String value) => value.hashCode & 0x7fffffff;
}
