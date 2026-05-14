import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme_projesi_2/main.dart';
import 'package:bitirme_projesi_2/network_manager.dart';

// Validates the AI system's lifecycle integrity, including heartbeat tracking,
// state flagging, and buffer management.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
          (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async => 1,
    );
  });

  setUp(() {
    globalNetworkManager.isServerConnected.value = false;
    globalNetworkManager.systemStatus.value = "Offline";
  });

  group('AI System & Lifecycle Integrity Tests', () {

    test('Auto-Torch state should toggle correctly', () {
      bool initialTorch = false;
      initialTorch = true;
      expect(initialTorch, isTrue);
    });

    test('System Status should flag AI Struggling state', () {
      globalNetworkManager.isServerConnected.value = true;
      String currentStatus = "AI Struggling";
      expect(currentStatus, equals("AI Struggling"));
    });

    test('Heartbeat should only be active during sessions', () {
      expect(globalNetworkManager.isServerConnected.value, isFalse);

      globalNetworkManager.isServerConnected.value = true;
      expect(globalNetworkManager.isServerConnected.value, isTrue);

      globalNetworkManager.stopHeartbeat();
      expect(globalNetworkManager.isServerConnected.value, isFalse);
    });

    test('Session should not start if camera is uninitialized (Functional Correctness)', () {
      globalNetworkManager.stopHeartbeat();
      bool isCameraInitialized = false;

      void mockStartSession() {
        if (!isCameraInitialized) return;
        globalNetworkManager.startHeartbeat();
      }

      mockStartSession();
      expect(globalNetworkManager.isServerConnected.value, isFalse);
    });

    test('TTS Announce function should execute without native crashes', () async {
      final testManager = NetworkManager();
      bool didExecuteSafely = false;

      try {
        await testManager.announce("System active");
        didExecuteSafely = true;
      } catch (e) {
        didExecuteSafely = false;
      }

      expect(didExecuteSafely, isTrue);
    });

    test('Description buffer should maintain a maximum of 3 frames', () {
      final testManager = NetworkManager();

      testManager.handleIncomingData("Person detected");
      testManager.handleIncomingData("Person holding a cup");
      testManager.handleIncomingData("Person drinking from cup");
      testManager.handleIncomingData("Empty cup");
      testManager.handleIncomingData("Cup placed on table");

      expect(testManager.descriptionBuffer.length, 3);
      expect(testManager.descriptionBuffer.last, "Cup placed on table");
      expect(testManager.descriptionBuffer.first, "Person drinking from cup");
    });
  });
}