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

  Stream<String> sendMessageStream(String message) async* {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _history.add({'role': 'user', 'content': message});

    final client = http.Client();
    final fullResponse = StringBuffer();

    try {
      final request = http.Request('POST', Uri.parse(_apiUrl));
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': _history,
        'stream': true,
      });

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        yield 'Error: $body';
        return;
      }

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;
          final data = trimmed.substring(6);
          if (data == '[DONE]') break;
          try {
            final json = jsonDecode(data);
            final content =
                json['choices'][0]['delta']['content'] as String?;
            if (content != null) {
              fullResponse.write(content);
              yield content;
            }
          } catch (_) {}
        }
      }

      _history.add({'role': 'assistant', 'content': fullResponse.toString()});
    } catch (e) {
      yield 'Error: $e';
    } finally {
      client.close();
    }
  }
}
