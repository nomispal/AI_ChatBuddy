import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/gpt_service.dart';

class ChatProvider extends ChangeNotifier {
  // Current state variables
  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  String _selectedPersona = 'student';
  
  // Services
  final GPTService _gptService = GPTService();

  // Getters (ways for UI to access the data)
  List<ChatSession> get chatSessions => _chatSessions;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String get selectedPersona => _selectedPersona;
  List<ChatMessage> get currentMessages => _currentSession?.messages ?? [];

  // Initialize the provider (load saved chats)
  Future<void> initialize() async {
    // await loadChatSessions(); // Temporarily disabled
    notifyListeners();
  }

  // Create a new chat session
  void startNewChat(String persona) {
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
    
    notifyListeners(); // Tell UI to update
    // saveChatSessions(); // Save to storage - temporarily disabled
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
    
    // Update title if this is the first message
    if (_currentSession!.messages.length == 1) {
      // Create a new session with updated title
      final updatedSession = ChatSession(
        id: _currentSession!.id,
        title: text.length > 30 ? '${text.substring(0, 30)}...' : text,
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
    // saveChatSessions(); // temporarily disabled

    // Show loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare conversation history for API
      List<Map<String, String>> conversation = _currentSession!.messages
          .map((msg) => {
                "role": msg.isUser ? "user" : "assistant",
                "content": msg.text,
              })
          .toList();

      // Get AI response
      String aiResponse = await _gptService.sendConversation(
        conversation.take(conversation.length - 1).toList(), // Don't include the message we just added
        _currentSession!.persona,
      );

      // Add AI response
      final aiMessage = ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _currentSession!.messages.add(aiMessage);
      
    } catch (e) {
      // Add error message if API call fails
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _currentSession!.messages.add(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    // saveChatSessions(); // temporarily disabled
  }

  // Switch to a different chat session
  void selectChatSession(ChatSession session) {
    _currentSession = session;
    _selectedPersona = session.persona;
    notifyListeners();
  }

  // Delete a chat session
  void deleteChatSession(String sessionId) {
    _chatSessions.removeWhere((session) => session.id == sessionId);
    
    // If we deleted the current session, clear it
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
    }
    
    notifyListeners();
    // saveChatSessions(); // temporarily disabled
  }

  // Change persona for new chats
  void setPersona(String persona) {
    _selectedPersona = persona;
    notifyListeners();
  }

  // Save chat sessions to local storage (temporarily disabled)
  Future<void> saveChatSessions() async {
    // Temporarily disabled due to build issues
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   final sessionsJson = _chatSessions.map((session) => session.toJson()).toList();
    //   await prefs.setString('chat_sessions', jsonEncode(sessionsJson));
    // } catch (e) {
    //   print('Error saving chat sessions: $e');
    // }
  }

  // Load chat sessions from local storage (temporarily disabled)
  Future<void> loadChatSessions() async {
    // Temporarily disabled due to build issues
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   final sessionsString = prefs.getString('chat_sessions');
    //   
    //   if (sessionsString != null) {
    //     final sessionsList = jsonDecode(sessionsString) as List;
    //     _chatSessions = sessionsList
    //         .map((sessionJson) => ChatSession.fromJson(sessionJson))
    //         .toList();
    //     
    //     // Sort by creation date (newest first)
    //     _chatSessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    //   }
    // } catch (e) {
    //   print('Error loading chat sessions: $e');
    //   _chatSessions = [];
    // }
    
    notifyListeners();
  }
} 