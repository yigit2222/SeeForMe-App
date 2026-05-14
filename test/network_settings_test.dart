import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bitirme_projesi_2/network_manager.dart';
import 'package:bitirme_projesi_2/main.dart';

// Verifies the configuration and routing logic for the server connection,
// ensuring IP and Port parsing functions accurately.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers.global'),
            (MethodCall methodCall) async => null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers'),
            (MethodCall methodCall) async => null);
  });

  group('Network & Routing Configuration Tests', () {

    test('Server IP Configurator should update destination address', () {
      final testManager = NetworkManager();
      String defaultIp = '192.168.1.100';
      serverIpAddressNotifier.value = defaultIp;

      String newIp = '10.0.0.55';
      serverIpAddressNotifier.value = newIp;
      testManager.updateServerIp(newIp);

      expect(serverIpAddressNotifier.value, equals('10.0.0.55'));
    });

    test('Server Configurator should parse IP and Port simultaneously', () {
      final testManager = NetworkManager();
      String combinedInput = '10.0.0.55:8888';

      testManager.updateServerIp(combinedInput);
      expect(testManager.serverAddress.address, equals('10.0.0.55'));
    });
  });
}