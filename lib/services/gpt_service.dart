import 'dart:convert';
import 'package:http/http.dart' as http;

class GPTService {
  // You'll need to get your own API key from OpenAI
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  // Different AI personas with their system prompts
  static const Map<String, String> personas = {
    'student': 'You are a helpful study buddy. You help with homework, explain concepts clearly, and encourage learning. Keep responses friendly and educational.',
    'teacher': 'You are a knowledgeable teacher. You provide detailed explanations, ask thought-provoking questions, and guide students to understand concepts deeply.',
    'coach': 'You are a motivational life coach. You inspire, motivate, and help people achieve their goals. Be encouraging and positive in your responses.',
  };

  // Main method to send a message to GPT
  Future<String> sendMessage(String message, String persona) async {
    try {
      // Get the system prompt for the selected persona
      String systemPrompt = personas[persona] ?? personas['student']!;

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": message}
        ],
        "max_tokens": 500,  // Limit response length
        "temperature": 0.7, // Control creativity (0.0 = very focused, 1.0 = very creative)
      };

      // Make the HTTP request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = jsonDecode(response.body);
        
        // Extract the AI's response text
        String aiResponse = data['choices'][0]['message']['content'];
        return aiResponse.trim();
      } else {
        // Handle API errors
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Sorry, I encountered an error. Please try again.';
      }
    } catch (e) {
      // Handle network or other errors
      print('Exception: $e');
      return 'Sorry, I couldn\'t connect to the AI service. Please check your internet connection.';
    }
  }

  // Method to send a conversation (with chat history for context)
  Future<String> sendConversation(List<Map<String, String>> messages, String persona) async {
    try {
      String systemPrompt = personas[persona] ?? personas['student']!;

      // Build the conversation history
      List<Map<String, String>> apiMessages = [
        {"role": "system", "content": systemPrompt},
        ...messages,
      ];

      Map<String, dynamic> requestBody = {
        "model": "gpt-3.5-turbo",
        "messages": apiMessages,
        "max_tokens": 500,
        "temperature": 0.7,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['choices'][0]['message']['content'];
        return aiResponse.trim();
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Sorry, I encountered an error. Please try again.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Sorry, I couldn\'t connect to the AI service. Please check your internet connection.';
    }
  }
} 