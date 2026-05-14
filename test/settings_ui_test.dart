import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme_projesi_2/settings_screen.dart';
import 'package:bitirme_projesi_2/main.dart';

// Tests the UI interactions within the settings screen, ensuring dialogs
// open and close as expected.
void main() {
  testWidgets('Privacy Policy dialog should open and close', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    final privacyButton = find.text('Data Privacy');
    await tester.scrollUntilVisible(privacyButton, 500.0);
    await tester.pumpAndSettle();

    expect(privacyButton, findsOneWidget);

    await tester.tap(privacyButton);
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);

    await tester.tap(find.text('UNDERSTOOD'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsNothing);
  });
}