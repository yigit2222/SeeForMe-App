import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme_projesi_2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Isolated tests for session lifecycle management.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Tell SharedPreferences to use a fake dictionary for testing
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

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

  test('Heartbeat should only be active during sessions', () {
    expect(globalNetworkManager.isServerConnected.value, isFalse);

    globalNetworkManager.isServerConnected.value = true;
    expect(globalNetworkManager.isServerConnected.value, isTrue);

    globalNetworkManager.stopHeartbeat();
    expect(globalNetworkManager.isServerConnected.value, isFalse);
  });
}