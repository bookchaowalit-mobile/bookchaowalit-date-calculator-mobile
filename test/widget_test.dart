import 'package:date_calculator/main.dart';
import 'package:date_calculator/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell builds with about tab', (tester) async {
    await tester.pumpWidget(const DateCalculatorApp());
    expect(find.text('Date Calculator'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('shows default difference and updates added days', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(today: DateTime(2026, 10, 1))),
    );
    expect(find.text('30 days'), findsOneWidget);
    expect(find.text('2026-10-31 (Saturday)'), findsWidgets);

    await tester.enterText(find.byKey(const Key('offset-input')), '-1');
    await tester.pump();
    expect(find.text('2026-09-30 (Wednesday)'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('offset-input')), 'abc');
    await tester.pump();
    expect(find.text('Enter a whole number'), findsOneWidget);
  });
}
