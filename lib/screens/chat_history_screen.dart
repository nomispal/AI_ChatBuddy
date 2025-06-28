import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.chatSessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No chat history yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a new chat to see it here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.chatSessions.length,
            itemBuilder: (context, index) {
              final session = provider.chatSessions[index];
              return _buildChatSessionTile(context, session, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatSessionTile(
    BuildContext context,
    ChatSession session,
    ChatProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF075E54),
          child: Icon(
            _getPersonaIcon(session.persona),
            color: Colors.white,
          ),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${session.persona.toUpperCase()} • ${session.messages.length} messages',
              style: const TextStyle(fontSize: 12),
            ),
            if (session.messages.isNotEmpty)
              Text(
                session.messages.last.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context, session, provider);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          provider.selectChatSession(session);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  IconData _getPersonaIcon(String persona) {
    switch (persona) {
      case 'student':
        return Icons.school;
      case 'teacher':
        return Icons.person;
      case 'coach':
        return Icons.fitness_center;
      default:
        return Icons.chat;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    ChatSession session,
    ChatProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteChatSession(session.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 