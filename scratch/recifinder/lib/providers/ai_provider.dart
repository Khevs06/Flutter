// lib/providers/ai_provider.dart

import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';

/// Holds the state of the AI assistant (loading, response, error).
class AiProvider with ChangeNotifier {
  final AiService _aiService;

  /// [apiKey] may be omitted or empty; in that case we fall back to
  /// environment variable via [AiService.fromEnvironment].
  AiProvider({String? apiKey})
      : _aiService = (apiKey != null && apiKey.isNotEmpty)
            ? AiService(apiKey: apiKey)
            : AiService.fromEnvironment();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
