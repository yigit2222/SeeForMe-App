import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme_projesi_2/main.dart';

// Tests the internal state logic for the settings page notifiers.
void main() {
  group('Settings Logic & State Tests', () {

    test('Theme Notifier should update correctly', () {
      appThemeNotifier.value = 'OLED Comfort';
      expect(appThemeNotifier.value, 'OLED Comfort');

      appThemeNotifier.value = 'Low Glare';
      expect(appThemeNotifier.value, 'Low Glare');
    });

    test('Speech Rate Custom values should persist', () {
      customSpeechRateNotifier.value = 1.8;
      expect(customSpeechRateNotifier.value, 1.8);
    });

    test('AI Detail Level should switch states', () {
      descriptionDetailNotifier.value = 'Detailed';
      expect(descriptionDetailNotifier.value, 'Detailed');
    });
  });
}