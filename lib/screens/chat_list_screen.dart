import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI ChatBuddy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Your AI Conversations',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'new_chat') {
                _showPersonaDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('New Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.chatSessions.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: provider.chatSessions.length,
            itemBuilder: (context, index) {
              final session = provider.chatSessions[index];
              return _buildChatTile(context, session, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPersonaDialog(context),
        backgroundColor: const Color(0xFF075E54),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE5DDD5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: Color(0xFF075E54),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to AI ChatBuddy!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF075E54),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start your first conversation with AI',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showPersonaDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E54),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatSession session, ChatProvider provider) {
    String lastMessage = 'No messages yet';
    String lastMessageTime = '';
    
    if (session.messages.isNotEmpty) {
      final lastMsg = session.messages.last;
      lastMessage = lastMsg.text;
      if (lastMessage.length > 50) {
        lastMessage = '${lastMessage.substring(0, 50)}...';
      }
      
      final now = DateTime.now();
      final diff = now.difference(lastMsg.timestamp);
      
      if (diff.inDays > 0) {
        lastMessageTime = '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        lastMessageTime = '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        lastMessageTime = '${diff.inMinutes}m ago';
      } else {
        lastMessageTime = 'Just now';
      }
    }

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
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${session.persona.toUpperCase()} • $lastMessageTime',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  '${session.messages.length} msgs',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          provider.selectChatSession(session);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
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

  void _showPersonaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose AI Persona'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPersonaOption(
              context,
              'student',
              'Study Buddy',
              'Helps with homework and explains concepts',
              Icons.school,
            ),
            const SizedBox(height: 12),
            _buildPersonaOption(
              context,
              'teacher',
              'Teacher',
              'Provides detailed explanations and guidance',
              Icons.person,
            ),
            const SizedBox(height: 12),
            _buildPersonaOption(
              context,
              'coach',
              'Life Coach',
              'Motivates and helps achieve goals',
              Icons.fitness_center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaOption(
    BuildContext context,
    String persona,
    String title,
    String description,
    IconData icon,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.of(context).pop();
        final provider = Provider.of<ChatProvider>(context, listen: false);
        await provider.startNewChat(persona);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF075E54)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 