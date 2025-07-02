import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Load environment variables from .env file
  static String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get baseUrl => dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
  static String get model => dotenv.env['GROQ_MODEL'] ?? 'llama3-8b-8192';
  
  // Model configuration
  static int get maxTokens => int.parse(dotenv.env['GROQ_MAX_TOKENS'] ?? '500');
  static double get temperature => double.parse(dotenv.env['GROQ_TEMPERATURE'] ?? '0.7');
  
  // Validate if API key is set
  static bool get isApiKeySet {
    return apiKey.isNotEmpty && apiKey.startsWith('gsk_');
  }
}

