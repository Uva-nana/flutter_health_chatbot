import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final List<Map<String, String>> _history = [];

  GeminiService() {
    _history.add({
      'role': 'system',
      'content': '''You are a friendly and knowledgeable health and nutrition assistant.
Your role is to:
- Help users choose healthy meals based on their health goals and dietary needs
- Analyze food menus and suggest the best options for users
- Provide guidance on nutrition, calories, and dietary restrictions
- Support users with conditions like diabetes, high blood pressure, or allergies
- Give practical, easy-to-understand advice

Always be encouraging, supportive, and remind users to consult a doctor for medical advice.
Keep responses concise and friendly.'''
    });
  }

  Future<String> sendMessage(String message) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _history.add({'role': 'user', 'content': message});

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': _history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': reply});
        return reply;
      } else {
        return 'Error: ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
