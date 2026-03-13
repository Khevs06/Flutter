import 'package:flutter_test/flutter_test.dart';
import 'package:recifinder/services/ai_service.dart';

void main() {
  test('AiService.fromEnvironment returns empty key when none defined', () {
    final svc = AiService.fromEnvironment();
    expect(svc.apiKey, isEmpty);
    expect(svc.isConfigured, isFalse);
  });

  test('AiService.marked configured when key provided', () {
    final svc = AiService(apiKey: 'abc');
    expect(svc.isConfigured, isTrue);
  });
}
