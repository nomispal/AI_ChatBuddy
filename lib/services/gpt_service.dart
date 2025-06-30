import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GPTService {

  // Different AI personas with their system prompts
  static const Map<String, String> personas = {
    'student': 'You are a helpful study buddy. You help with homework, explain concepts clearly, and encourage learning. Keep responses friendly and educational.',
    'teacher': 'You are a knowledgeable teacher. You provide detailed explanations, ask thought-provoking questions, and guide students to understand concepts deeply.',
    'coach': 'You are a motivational life coach. You inspire, motivate, and help people achieve their goals. Be encouraging and positive in your responses.',
  };

  // Main method to send a message to Groq AI
  Future<String> sendMessage(String message, String persona) async {
    // Check if API key is properly configured
    if (!ApiConfig.isApiKeySet) {
      return 'Please configure your Groq API key in lib/config/api_config.dart\n\nTo get a FREE Groq API key:\n1. Visit https://console.groq.com/keys\n2. Sign up for free\n3. Create an API key\n4. Update apiKey in api_config.dart';
    }

    try {
      // Get the system prompt for the selected persona
      String systemPrompt = personas[persona] ?? personas['student']!;

      // Prepare the request body for Groq API
      Map<String, dynamic> requestBody = {
        "model": ApiConfig.model,
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": message}
        ],
        "max_tokens": ApiConfig.maxTokens,
        "temperature": ApiConfig.temperature,
      };

      // Make the HTTP request to Groq
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.apiKey}',
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
        // Handle API errors with specific messages
        print('Groq API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        
        if (response.statusCode == 401) {
          return 'Invalid Groq API key. Please check your API key at https://console.groq.com/keys';
        } else if (response.statusCode == 429) {
          return 'Rate limit exceeded. Please try again later.';
        } else if (response.statusCode == 402) {
          return 'Insufficient credits. Please check your Groq account.';
        } else {
          return 'Groq API Error (${response.statusCode}): Please try again later.';
        }
      }
    } catch (e) {
      print('Exception in sendMessage: $e');
      return 'Network error: $e\nPlease check your internet connection.';
    }
  }

  // Method to send a conversation (with chat history for context)
  Future<String> sendConversation(List<Map<String, String>> messages, String persona) async {
    // Check if API key is properly configured
    if (!ApiConfig.isApiKeySet) {
      return 'Please configure your Groq API key in lib/config/api_config.dart';
    }

    try {
      String systemPrompt = personas[persona] ?? personas['student']!;

      // Build the conversation history for Groq API
      List<Map<String, String>> apiMessages = [
        {"role": "system", "content": systemPrompt},
        ...messages,
      ];

      Map<String, dynamic> requestBody = {
        "model": ApiConfig.model,
        "messages": apiMessages,
        "max_tokens": ApiConfig.maxTokens,
        "temperature": ApiConfig.temperature,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['choices'][0]['message']['content'];
        return aiResponse.trim();
      } else {
        print('Groq API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        
        if (response.statusCode == 401) {
          return 'Invalid Groq API key. Please check your API key.';
        } else if (response.statusCode == 429) {
          return 'Rate limit exceeded. Please try again later.';
        } else if (response.statusCode == 402) {
          return 'Insufficient credits. Please check your Groq account.';
        } else {
          return 'Groq API Error (${response.statusCode}): Please try again later.';
        }
      }
    } catch (e) {
      print('Exception in sendConversation: $e');
      return 'Network error: $e\nPlease check your internet connection.';
    }
  }
} 