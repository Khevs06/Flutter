// lib/providers/ai_provider.dart

import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';

/// Holds the state of the AI assistant (loading, response, error).
class AiProvider with ChangeNotifier {
  final AiService _aiService;

  /// [apiKey] may be null or empty; this allows the UI to run without
  /// requiring a value to be passed in (e.g. when the app is launched without
  /// `--dart-define=OPENAI_API_KEY=...`).
  AiProvider({String? apiKey}) : _aiService = AiService(apiKey: apiKey ?? '');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// True when we have an API key and service is usable.
  bool get isEnabled => _aiService.isConfigured;

  String? _response;
  String? get response => _response;

  String? _error;
  String? get error => _error;

  /// Sends [prompt] to the AI and stores the reply.
  Future<void> ask(String prompt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _response = await _aiService.askQuestion(prompt);
    } catch (e) {
      // Common case: no API key defined.
      _error = e.toString();
      _response = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _response = null;
    _error = null;
    notifyListeners();
  }
}
