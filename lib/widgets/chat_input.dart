import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.sendMessage(text);
    
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  // Emoji button (placeholder)
                  IconButton(
                    onPressed: () {
                      // TODO: Add emoji picker
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  
                  // Attachment button (placeholder)
                  IconButton(
                    onPressed: () {
                      // TODO: Add attachment functionality
                    },
                    icon: Icon(
                      Icons.attach_file,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Voice message button (placeholder for future)
                  IconButton(
                    onPressed: () {
                      // TODO: Add voice message functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice message coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.mic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Send button
          Container(
            margin: const EdgeInsets.only(left: 4.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF075E54),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 