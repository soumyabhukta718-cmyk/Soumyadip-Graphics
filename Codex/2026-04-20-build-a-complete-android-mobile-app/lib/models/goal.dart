class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.timeframe,
    required this.targetCount,
    required this.completedCount,
    required this.dueDate,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String category;
  final String timeframe;
  final int targetCount;
  final int completedCount;
  final DateTime dueDate;
  final bool isCompleted;

  double get progress => targetCount == 0 ? 0 : completedCount / targetCount;

  Goal copyWith({
    String? id,
    String? title,
    String? category,
    String? timeframe,
    int? targetCount,
    int? completedCount,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      timeframe: timeframe ?? this.timeframe,
      targetCount: targetCount ?? this.targetCount,
      completedCount: completedCount ?? this.completedCount,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'category': category,
      'timeframe': timeframe,
      'target_count': targetCount,
      'completed_count': completedCount,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, Object?> map) {
    return Goal(
      id: map['id']! as String,
      title: map['title']! as String,
      category: map['category']! as String,
      timeframe: map['timeframe']! as String,
      targetCount: map['target_count']! as int,
      completedCount: map['completed_count']! as int,
      dueDate: DateTime.parse(map['due_date']! as String),
      isCompleted: (map['is_completed']! as int) == 1,
    );
  }
}
