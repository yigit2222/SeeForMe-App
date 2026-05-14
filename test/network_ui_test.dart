import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme_projesi_2/main.dart';

// Tests the UI components related to network state, ensuring the badge
// accurately reflects the connection status.
void main() {
  testWidgets('Network Badge should reflect connection status', (WidgetTester tester) async {
    globalNetworkManager.isServerConnected.value = false;

    await tester.pumpWidget(const MaterialApp(home: LiveScreen()));

    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);

    globalNetworkManager.isServerConnected.value = true;
    await tester.pump();

    expect(find.text('Connected'), findsOneWidget);
    expect(find.byIcon(Icons.wifi), findsOneWidget);
  });
}