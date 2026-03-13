// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recifinder/main.dart';

void main() {
  testWidgets('App builds and displays title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // pass a dummy key so our validation assertions don’t fire
    await tester.pumpWidget(const ReciFinderApp(openAiKey: 'test-key'));

    // The home screen should show our app bar title.
    expect(find.text('ReciFinder'), findsOneWidget);

    // There should be a search field on screen.
    expect(find.byType(TextField), findsOneWidget);
  });
}
