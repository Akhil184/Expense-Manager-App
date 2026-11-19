
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Expense Manager test environment works',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Text('Expense Manager'),
            ),
          ),
        );

        expect(find.text('Expense Manager'), findsOneWidget);
      });
}
