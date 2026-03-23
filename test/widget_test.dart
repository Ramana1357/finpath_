import 'package:flutter_test/flutter_test.dart';
import 'package:finpath/main.dart';

void main() {
  testWidgets('FinPathApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FinPathApp());

    // Verify that our app starts at the Home screen.
    expect(find.text('FINPATH'), findsOneWidget);
    expect(find.text('Monthly Overview'), findsOneWidget);

    // Tap on the Vault icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.shield_outlined));
    await tester.pumpAndSettle();

    // Verify that we are on the Vault screen.
    expect(find.text('Dream Vault'), findsOneWidget);
  });
}
