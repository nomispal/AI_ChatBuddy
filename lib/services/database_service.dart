import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_buddy.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create chat_sessions table
    await db.execute('''
      CREATE TABLE chat_sessions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        persona TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create chat_messages table
    await db.execute('''
      CREATE TABLE chat_messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        text TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  // Save a chat session
  Future<void> saveChatSession(ChatSession session) async {
    final db = await database;
    
    await db.insert(
      'chat_sessions',
      {
        'id': session.id,
        'title': session.title,
        'persona': session.persona,
        'created_at': session.createdAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Save all messages for this session
    for (ChatMessage message in session.messages) {
      await _saveChatMessage(session.id, message);
    }
  }

  // Save a single chat message
  Future<void> _saveChatMessage(String sessionId, ChatMessage message) async {
    final db = await database;
    
    await db.insert(
      'chat_messages',
      {
        'session_id': sessionId,
        'text': message.text,
        'is_user': message.isUser ? 1 : 0,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add a new message to existing session
  Future<void> addMessageToSession(String sessionId, ChatMessage message) async {
    await _saveChatMessage(sessionId, message);
  }

  // Update session title
  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final db = await database;
    
    await db.update(
      'chat_sessions',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Load all chat sessions
  Future<List<ChatSession>> loadAllChatSessions() async {
    final db = await database;
    
    final sessionMaps = await db.query(
      'chat_sessions',
      orderBy: 'created_at DESC', // Most recent first
    );

    List<ChatSession> sessions = [];
    
    for (var sessionMap in sessionMaps) {
      // Load messages for this session
      final messageMaps = await db.query(
        'chat_messages',
        where: 'session_id = ?',
        whereArgs: [sessionMap['id']],
        orderBy: 'timestamp ASC', // Oldest first for messages
      );

      List<ChatMessage> messages = messageMaps.map((messageMap) {
        return ChatMessage(
          text: messageMap['text'] as String,
          isUser: (messageMap['is_user'] as int) == 1,
          timestamp: DateTime.fromMillisecondsSinceEpoch(messageMap['timestamp'] as int),
        );
      }).toList();

      sessions.add(ChatSession(
        id: sessionMap['id'] as String,
        title: sessionMap['title'] as String,
        persona: sessionMap['persona'] as String,
        messages: messages,
        createdAt: DateTime.fromMillisecondsSinceEpoch(sessionMap['created_at'] as int),
      ));
    }

    return sessions;
  }

  // Delete a chat session
  Future<void> deleteChatSession(String sessionId) async {
    final db = await database;
    
    // Delete messages first (foreign key constraint)
    await db.delete(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    // Delete the session
    await db.delete(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Get session by ID with messages
  Future<ChatSession?> getChatSession(String sessionId) async {
    final db = await database;
    
    final sessionMaps = await db.query(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (sessionMaps.isEmpty) return null;

    final sessionMap = sessionMaps.first;
    
    // Load messages for this session
    final messageMaps = await db.query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );

    List<ChatMessage> messages = messageMaps.map((messageMap) {
      return ChatMessage(
        text: messageMap['text'] as String,
        isUser: (messageMap['is_user'] as int) == 1,
        timestamp: DateTime.fromMillisecondsSinceEpoch(messageMap['timestamp'] as int),
      );
    }).toList();

    return ChatSession(
      id: sessionMap['id'] as String,
      title: sessionMap['title'] as String,
      persona: sessionMap['persona'] as String,
      messages: messages,
      createdAt: DateTime.fromMillisecondsSinceEpoch(sessionMap['created_at'] as int),
    );
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('chat_messages');
    await db.delete('chat_sessions');
  }
} 