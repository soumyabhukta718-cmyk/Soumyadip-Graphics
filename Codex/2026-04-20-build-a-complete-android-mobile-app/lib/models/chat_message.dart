class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    required this.language,
    required this.isOffline,
    this.imagePath,
  });

  final String id;
  final String sender;
  final String text;
  final DateTime createdAt;
  final String language;
  final bool isOffline;
  final String? imagePath;

  bool get isUser => sender == 'user';

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'sender': sender,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'language': language,
      'is_offline': isOffline ? 1 : 0,
      'image_path': imagePath,
    };
  }

  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      id: map['id']! as String,
      sender: map['sender']! as String,
      text: map['text']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
      language: map['language']! as String,
      isOffline: (map['is_offline']! as int) == 1,
      imagePath: map['image_path'] as String?,
    );
  }
}
