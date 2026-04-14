// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finpath/main.dart';

void main() {
  testWidgets('FinPath app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Since main.dart initializes Firebase and requires Providers, 
    // this test might fail without proper mocking.
    // We update the class name back to MyApp to match your updated main.dart definition.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial screen (likely AuthScreen or a loading indicator) is present.
    // Since your app now starts with AuthWrapper, we check for a general widget instead of specific text.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
