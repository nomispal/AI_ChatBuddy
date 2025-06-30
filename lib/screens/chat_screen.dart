import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentSession?.title ?? 'AI ChatBuddy',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${provider.selectedPersona.toUpperCase()} Mode • Groq AI',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            );
          },
        ),
        backgroundColor: const Color(0xFF075E54), // WhatsApp green
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              final provider = Provider.of<ChatProvider>(context, listen: false);
              if (value == 'new_chat') {
                _showPersonaDialog(context);
              } else if (value == 'chat_history') {
                Navigator.pushNamed(context, '/chat_history');
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
              const PopupMenuItem(
                value: 'chat_history',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('Chat History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.currentSession == null) {
            return _buildWelcomeScreen(context);
          }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5DDD5), // WhatsApp background
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: provider.currentMessages.length,
                    itemBuilder: (context, index) {
                      final message = provider.currentMessages[index];
                      return MessageBubble(message: message);
                    },
                  ),
                ),
              ),
              
              // Loading indicator
              if (provider.isLoading)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    children: [
                      SizedBox(width: 16),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('AI is typing...'),
                    ],
                  ),
                ),
              
              // Input area
              ChatInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
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
              'Choose an AI persona to start chatting',
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
      onTap: () {
        Navigator.of(context).pop();
        Provider.of<ChatProvider>(context, listen: false).startNewChat(persona);
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