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
  /// The raw string is normalised to eliminate any characters that the web
  /// `fetch` API cannot express in headers (ISO‑8859‑1). This guards against
  /// stray whitespace or non‑ASCII symbols introduced during copy/paste, which
  /// previously crashed the app on web, as you’ve seen.
  ///
  /// An empty key is still permitted; callers should use [isConfigured] to
  /// check before attempting to perform a request.
  AiService({required String apiKey}) : apiKey = _sanitizeKey(apiKey);

  /// Reads the API key from the `OPENAI_API_KEY` environment variable.
  ///
  /// The value is passed through the same sanitiser used by the regular
  /// constructor; if you accidentally include non‑ASCII characters the key
  /// will simply be stripped rather than blowing up the page.
  factory AiService.fromEnvironment() {
    const key = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    return AiService(apiKey: key);
  }

  /// Sends a simple request to the GPT chat endpoint and returns the
  /// text output from the first choice.
  /// Whether the service has a non-empty key configured.
  bool get isConfigured => apiKey.isNotEmpty;

  /// Remove characters that cannot be used in HTTP header values.
  ///
  /// According to the browser spec header values must be ISO‑8859‑1 (latin1)
  /// strings, so drop anything above `0xFF`.  Also trim whitespace from both
  /// ends.
  static String _sanitizeKey(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    final buffer = StringBuffer();
    for (final codeUnit in trimmed.codeUnits) {
      if (codeUnit <= 0xFF) buffer.writeCharCode(codeUnit);
    }
    return buffer.toString();
  }

  Future<String> askQuestion(String prompt) async {
    if (apiKey.isEmpty) {
      throw StateError('No API key configured for AiService');
    }
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