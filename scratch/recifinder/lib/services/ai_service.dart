// lib/services/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Very lightweight wrapper around OpenAI's Chat API.
///
/// You must provide an API key yourself. The easiest way is to supply a
/// `--dart-define=OPENAI_API_KEY=...` when running the app, and read it
/// via `const String.fromEnvironment` in the calling code.
class AiService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  final String apiKey;

  /// Creates a service instance using the supplied key.
  ///
  /// Calling code is responsible for providing a non-empty value. A
  /// convenience factory is provided to read the key from the Dart
  /// environment (i.e. `--dart-define=OPENAI_API_KEY=…`).
  AiService({required this.apiKey}) : assert(apiKey.isNotEmpty, 'API key cannot be empty');

  /// Reads the API key from the `OPENAI_API_KEY` environment variable.
  ///
  /// If the environment value is missing or empty an [ArgumentError] is
  /// thrown. This mirrors the behaviour of the main application, which
  /// should also make sure to pass a valid key.
  factory AiService.fromEnvironment() {
    const key = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (key.isEmpty) {
      throw ArgumentError('OPENAI_API_KEY must be defined via --dart-define');
    }
    return AiService(apiKey: key);
  }

  /// Sends a simple request to the GPT chat endpoint and returns the
  /// text output from the first choice.
  Future<String> askQuestion(String prompt) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful cooking assistant that suggests recipes based on user requests.'
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'] as String;
      }
      return '';
    } else {
      throw Exception('AI request failed: ${response.statusCode} ${response.body}');
    }
  }
}