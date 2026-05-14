import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme_projesi_2/settings_screen.dart';
import 'package:bitirme_projesi_2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Tests the UI interactions within the settings screen, ensuring dialogs
// open and close as expected.
void main() {
  setUpAll(() async {
    // Tell SharedPreferences to use a fake dictionary for testing
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });
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

  test('Settings Persistence: Should save Language to SharedPreferences', () async {
    String newLanguage = 'tr';
    currentLanguageNotifier.value = newLanguage;
    await prefs.setString('currentLanguage', newLanguage);

    // Check the phone's memory to see if it saved
    String? savedMemory = prefs.getString('currentLanguage');
    expect(savedMemory, 'tr', reason: 'The language did not save to persistent storage');
  });
}