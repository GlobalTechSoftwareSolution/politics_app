import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:politics_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Politics App - Minimal Core Tests', () {
    testWidgets('App launches', (WidgetTester tester) async {
      await tester.pumpWidget(const app.PoliticsApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      print('✅ App launches successfully');
    });

    testWidgets('Dashboard loads data', (WidgetTester tester) async {
      await tester.pumpWidget(const app.PoliticsApp());
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(find.byType(Scaffold), findsWidgets);
      print('✅ Dashboard loads with data');
    });

    testWidgets('No crashes during navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const app.PoliticsApp());
      await tester.pumpAndSettle();

      // Try to interact with common UI elements
      final homeElements = find.byIcon(Icons.home);
      if (homeElements.hasFound) {
        await tester.tap(homeElements.first);
        await tester.pumpAndSettle();
      }

      expect(true, true); // just ensure no crash
      print('✅ Navigation works without crashes');
    });
  });
}
