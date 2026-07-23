class Chat {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? 'New Chat',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
