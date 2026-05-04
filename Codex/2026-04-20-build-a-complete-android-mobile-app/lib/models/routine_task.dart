class RoutineTask {
  const RoutineTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.startMinute,
    required this.endMinute,
    required this.isCompleted,
    required this.reminderEnabled,
    required this.notes,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final int startMinute;
  final int endMinute;
  final bool isCompleted;
  final bool reminderEnabled;
  final String notes;

  DateTime get startDateTime {
    return DateTime(date.year, date.month, date.day, startMinute ~/ 60, startMinute % 60);
  }

  DateTime get endDateTime {
    return DateTime(date.year, date.month, date.day, endMinute ~/ 60, endMinute % 60);
  }

  RoutineTask copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? date,
    int? startMinute,
    int? endMinute,
    bool? isCompleted,
    bool? reminderEnabled,
    String? notes,
  }) {
    return RoutineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'subject': subject,
      'date': date.toIso8601String(),
      'start_minute': startMinute,
      'end_minute': endMinute,
      'is_completed': isCompleted ? 1 : 0,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'notes': notes,
    };
  }

  factory RoutineTask.fromMap(Map<String, Object?> map) {
    return RoutineTask(
      id: map['id']! as String,
      title: map['title']! as String,
      subject: map['subject']! as String,
      date: DateTime.parse(map['date']! as String),
      startMinute: map['start_minute']! as int,
      endMinute: map['end_minute']! as int,
      isCompleted: (map['is_completed']! as int) == 1,
      reminderEnabled: (map['reminder_enabled']! as int) == 1,
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
