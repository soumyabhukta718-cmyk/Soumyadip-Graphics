import 'dart:math';

import '../models/routine_task.dart';

class PlannerService {
  List<RoutineTask> generateSuggestedRoutine({
    required DateTime date,
    required List<String> subjects,
    required int studyHours,
  }) {
    final List<String> chosenSubjects = subjects.isEmpty
        ? <String>['Mathematics', 'Reasoning', 'English', 'General Knowledge']
        : subjects;

    final List<RoutineTask> tasks = <RoutineTask>[];
    int cursor = 6 * 60;
    final int blocks = max(2, studyHours);

    for (int index = 0; index < blocks; index++) {
      final String subject = chosenSubjects[index % chosenSubjects.length];
      final int focusMinutes = index == 0 ? 60 : 50;
      final int startMinute = cursor;
      final int endMinute = cursor + focusMinutes;

      tasks.add(
        RoutineTask(
          id: 'routine_${date.microsecondsSinceEpoch}_$index',
          title: '$subject Focus Sprint',
          subject: subject,
          date: DateTime(date.year, date.month, date.day),
          startMinute: startMinute,
          endMinute: endMinute,
          isCompleted: false,
          reminderEnabled: true,
          notes: 'Suggested by Shindhu for balanced revision and mock practice.',
        ),
      );

      cursor = endMinute + 10;
      if (cursor > 21 * 60) {
        break;
      }
    }

    return tasks;
  }

  RoutineTask? rescheduleMissedTask(RoutineTask task, DateTime now) {
    if (task.isCompleted || task.endDateTime.isAfter(now)) {
      return null;
    }

    final DateTime newDate = now.hour < 20
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day + 1);
    final int proposedStart = now.hour < 20
        ? ((now.hour * 60 + now.minute + 29) ~/ 30) * 30
        : 6 * 60;
    final int duration = max(30, task.endMinute - task.startMinute);
    final int startMinute = min(proposedStart, 21 * 60);
    final int endMinute = min(startMinute + duration, 22 * 60);

    return task.copyWith(
      date: newDate,
      startMinute: startMinute,
      endMinute: endMinute,
      notes: '${task.notes}\nAuto-rescheduled by Shindhu.',
    );
  }
}
