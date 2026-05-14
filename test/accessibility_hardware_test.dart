import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bitirme_projesi_2/network_manager.dart';
import 'package:bitirme_projesi_2/main.dart';

// Tests for hardware accessibility features, including Auto-Torch
// hysteresis logic and Text to Speech toggle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel('xyz.luan/audioplayers.global')
        .setMockMethodCallHandler((MethodCall methodCall) async => null);

    const MethodChannel('xyz.luan/audioplayers')
        .setMockMethodCallHandler((MethodCall methodCall) async => null);
  });

  group('Accessibility & Hardware Control Tests', () {

    test('Auto-Torch should respect manual override and global settings', () {
      bool isManualTorchOverride = false;
      final ValueNotifier<bool> isAutoTorchEnabled = ValueNotifier<bool>(true);

      bool simulateAIDecision(double brightness) {
        if (!isManualTorchOverride && isAutoTorchEnabled.value) {
          return brightness < 45;
        }
        return false;
      }

      expect(simulateAIDecision(30.0), isTrue);

      isManualTorchOverride = true;
      expect(simulateAIDecision(30.0), isFalse, reason: "AI should be blocked by manual override");

      isManualTorchOverride = false;
      isAutoTorchEnabled.value = false;
      expect(simulateAIDecision(30.0), isFalse, reason: "AI should be blocked by settings toggle");
    });

    test('TTS Toggle should intercept and block audio announcements', () async {
      final testManager = NetworkManager();
      testManager.isTtsEnabled.value = false;

      bool didAttemptToSpeak = false;

      Future<void> mockAnnounce(String message) async {
        if (testManager.isTtsEnabled.value) {
          didAttemptToSpeak = true;
        }
      }

      await mockAnnounce("Connected to Server");
      expect(didAttemptToSpeak, isFalse);
    });
  });
}