class ApiConfig {
  // 🚀 GROQ Configuration (FREE - 14,400 requests/day!)
  static const String apiKey = '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';
  static const String baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String model = 'llama3-8b-8192'; // Fast and free model
  
  // Model configuration
  static const int maxTokens = 500;
  static const double temperature = 0.7;
  
  // Validate if API key is set
  static bool get isApiKeySet {
    return apiKey.isNotEmpty && apiKey.startsWith('gsk_');
  }
}

