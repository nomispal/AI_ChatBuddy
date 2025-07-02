import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/gpt_service.dart';
import '../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  // Current state variables
  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  String _selectedPersona = 'student';
  
  // Services
  final GPTService _gptService = GPTService();
  final DatabaseService _databaseService = DatabaseService();
  
  // Scroll controller for auto-scroll
  final ScrollController scrollController = ScrollController();

  // Getters (ways for UI to access the data)
  List<ChatSession> get chatSessions => _chatSessions;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String get selectedPersona => _selectedPersona;
  List<ChatMessage> get currentMessages => _currentSession?.messages ?? [];

  // Initialize the provider (load saved chats)
  Future<void> initialize() async {
    await loadChatSessions();
    notifyListeners();
  }

  // Create a new chat session
  Future<void> startNewChat(String persona) async {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      persona: persona,
      messages: [],
      createdAt: DateTime.now(),
    );

    _chatSessions.insert(0, session); // Add to beginning of list
    _currentSession = session;
    _selectedPersona = persona;
    
    // Save to database
    await _databaseService.saveChatSession(session);
    
    notifyListeners(); // Tell UI to update
  }

  // Send a message in the current chat
  Future<void> sendMessage(String text) async {
    if (_currentSession == null || text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _currentSession!.messages.add(userMessage);
    
    // Save user message to database
    await _databaseService.addMessageToSession(_currentSession!.id, userMessage);
    
    // Update title if this is the first message
    if (_currentSession!.messages.length == 1) {
      final newTitle = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      
      // Update title in database
      await _databaseService.updateSessionTitle(_currentSession!.id, newTitle);
      
      // Create a new session with updated title
      final updatedSession = ChatSession(
        id: _currentSession!.id,
        title: newTitle,
        persona: _currentSession!.persona,
        messages: _currentSession!.messages,
        createdAt: _currentSession!.createdAt,
      );
      
      // Update in the list
      final index = _chatSessions.indexWhere((s) => s.id == _currentSession!.id);
      if (index != -1) {
        _chatSessions[index] = updatedSession;
        _currentSession = updatedSession;
      }
    }

    notifyListeners();
    _scrollToBottom();

    // Show loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Add a delay to respect rate limits (especially for free tier)
      await Future.delayed(const Duration(seconds: 2));

      // Prepare conversation history for API
      List<Map<String, String>> conversation = _currentSession!.messages
          .map((msg) => {
                "role": msg.isUser ? "user" : "assistant",
                "content": msg.text,
              })
          .toList();

      // Remove the last message (the one we just added) from the conversation history
      // since we want to send all previous messages as context
      if (conversation.isNotEmpty) {
        conversation.removeLast();
      }

      // Get AI response using the corrected conversation history
      String aiResponse = await _gptService.sendConversation(
        conversation,
        _currentSession!.persona,
      );

      // Add AI response
      final aiMessage = ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _currentSession!.messages.add(aiMessage);
      
      // Save AI message to database
      await _databaseService.addMessageToSession(_currentSession!.id, aiMessage);
      
    } catch (e) {
      // Add more detailed error message for debugging
      print('Error in sendMessage: $e');
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error: $e\nPlease check your API key and internet connection.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _currentSession!.messages.add(errorMessage);
      
      // Save error message to database
      await _databaseService.addMessageToSession(_currentSession!.id, errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    _scrollToBottom();
  }

  // Switch to a different chat session
  void selectChatSession(ChatSession session) {
    _currentSession = session;
    _selectedPersona = session.persona;
    notifyListeners();
    // Auto-scroll to bottom to show recent messages
    _scrollToBottom();
  }

  // Delete a chat session
  Future<void> deleteChatSession(String sessionId) async {
    // Delete from database
    await _databaseService.deleteChatSession(sessionId);
    
    // Remove from local list
    _chatSessions.removeWhere((session) => session.id == sessionId);
    
    // If we deleted the current session, clear it
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
    }
    
    notifyListeners();
  }

  // Change persona for new chats
  void setPersona(String persona) {
    _selectedPersona = persona;
    notifyListeners();
  }

  // Load chat sessions from database
  Future<void> loadChatSessions() async {
    try {
      _chatSessions = await _databaseService.loadAllChatSessions();
    } catch (e) {
      print('Error loading chat sessions: $e');
      _chatSessions = [];
    }
    notifyListeners();
  }

  // Clear all chat sessions
  Future<void> clearAllChats() async {
    try {
      await _databaseService.clearAllData();
      _chatSessions.clear();
      _currentSession = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing chats: $e');
    }
  }

  // Auto-scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Dispose method to clean up scroll controller
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
} 