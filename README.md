# AI ChatBuddy 🤖

AI ChatBuddy is a Flutter-based chat application that lets you interact with different AI personas powered by Groq AI. Whether you need a study buddy, a teacher, or a life coach, AI ChatBuddy is here to help!

## Features ✨

- Multiple AI personas (Student, Teacher, Coach)
- Chat history management
- Beautiful Material Design 3 UI
- Onboarding experience
- Secure API key management
- Offline message storage

## Getting Started 🚀

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- A Groq API key (get one for free at [console.groq.com](https://console.groq.com))

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ai_chatbuddy.git
   cd ai_chatbuddy
   ```

2. Create a `.env` file in the project root with the following content:
   ```
   GROQ_API_KEY=your_api_key_here
   GROQ_BASE_URL=https://api.groq.com/openai/v1/chat/completions
   GROQ_MODEL=llama3-8b-8192
   GROQ_MAX_TOKENS=500
   GROQ_TEMPERATURE=0.7
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Environment Variables 🔐

The app uses the following environment variables:

- `GROQ_API_KEY`: Your Groq API key
- `GROQ_BASE_URL`: Groq API endpoint
- `GROQ_MODEL`: AI model to use
- `GROQ_MAX_TOKENS`: Maximum tokens per response
- `GROQ_TEMPERATURE`: Response creativity (0.0-1.0)

## AI Personas 🎭

- **Student Buddy**: A helpful study companion that assists with homework and explains concepts clearly
- **Teacher**: A knowledgeable educator providing detailed explanations and thought-provoking questions
- **Life Coach**: A motivational coach helping you achieve your goals with positive encouragement

## Security 🔒

- API keys are stored securely in the `.env` file
- The `.env` file is ignored by git to prevent accidental exposure
- Environment variables are loaded at runtime
- API key validation is performed before making requests

## Contributing 🤝

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments 🙏

- [Groq AI](https://groq.com) for their powerful AI API
- Flutter team for the amazing framework
- All contributors who help improve this project
