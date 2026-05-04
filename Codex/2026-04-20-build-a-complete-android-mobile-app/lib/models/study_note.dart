class StudyNote {
  const StudyNote({
    required this.id,
    required this.subject,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  final String subject;
  final String title;
  final String content;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'subject': subject,
      'title': title,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudyNote.fromMap(Map<String, Object?> map) {
    return StudyNote(
      id: map['id']! as String,
      subject: map['subject']! as String,
      title: map['title']! as String,
      content: map['content']! as String,
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }
}
