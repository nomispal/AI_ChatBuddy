import 'chat_message.dart';

class ChatSession {
  final String id;                    // Unique identifier for this chat
  final String title;                 // Chat title (first message or custom)
  final String persona;               // Which AI persona (student, teacher, coach)
  final List<ChatMessage> messages;   // All messages in this chat
  final DateTime createdAt;           // When this chat was created

  ChatSession({
    required this.id,
    required this.title,
    required this.persona,
    required this.messages,
    required this.createdAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'persona': persona,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      persona: json['persona'],
      messages: (json['messages'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 