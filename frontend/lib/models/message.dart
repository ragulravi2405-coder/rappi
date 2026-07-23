class Message {
  final String id;
  final String chatId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }
}
