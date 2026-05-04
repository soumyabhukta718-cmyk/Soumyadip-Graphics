class PomodoroSession {
  const PomodoroSession({
    required this.id,
    required this.subject,
    required this.startedAt,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.completed,
  });

  final String id;
  final String subject;
  final DateTime startedAt;
  final int focusMinutes;
  final int breakMinutes;
  final bool completed;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'subject': subject,
      'started_at': startedAt.toIso8601String(),
      'focus_minutes': focusMinutes,
      'break_minutes': breakMinutes,
      'completed': completed ? 1 : 0,
    };
  }

  factory PomodoroSession.fromMap(Map<String, Object?> map) {
    return PomodoroSession(
      id: map['id']! as String,
      subject: map['subject']! as String,
      startedAt: DateTime.parse(map['started_at']! as String),
      focusMinutes: map['focus_minutes']! as int,
      breakMinutes: map['break_minutes']! as int,
      completed: (map['completed']! as int) == 1,
    );
  }
}
