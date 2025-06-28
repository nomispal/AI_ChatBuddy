class ChatMessage {
  final String text;           // The actual message text
  final bool isUser;           // Is this message from user (true) or AI (false)?
  final DateTime timestamp;    // When was this message sent?

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Convert ChatMessage to JSON (for saving to storage)
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create ChatMessage from JSON (for loading from storage)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 