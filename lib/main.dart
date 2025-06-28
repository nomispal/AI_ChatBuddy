import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/chat_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider()..initialize(),
      child: MaterialApp(
        title: 'AI ChatBuddy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF075E54)),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        routes: {
          '/chat_history': (context) => const ChatHistoryScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
