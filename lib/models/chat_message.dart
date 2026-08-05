// lib/models/chat_message.dart

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
