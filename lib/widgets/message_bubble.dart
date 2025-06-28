import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF075E54),
              child: const Icon(
                Icons.android,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFFDCF8C6) // Light green for user
                    : Colors.white,           // White for AI
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: message.isUser 
                      ? const Radius.circular(12) 
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Timestamp
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (message.isUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            // User avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[400],
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
} 