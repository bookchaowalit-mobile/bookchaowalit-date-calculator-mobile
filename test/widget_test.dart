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
    expect(find.textContaining('Enter a whole number'), findsOneWidget);
  });

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: HomeScreen(today: DateTime(2026, 10, 1)),
        ),
      );

  testWidgets('huge or hex offsets show an error instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    for (final bad in ['100000000000', '0x10', '']) {
      await tester.enterText(find.byKey(const Key('offset-input')), bad);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: bad);
      expect(find.byKey(const Key('offset-result')), findsNothing);
      expect(find.textContaining('Enter a whole number'), findsOneWidget);
    }
  });

  testWidgets('tapping a date opens the picker and applies the choice', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.tap(find.text('End'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('14 days'), findsOneWidget);
  });

  testWidgets('shows a note when the end date is before the start', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.textContaining('before the start'), findsNothing);
    await tester.tap(find.text('End'));
    await tester.pumpAndSettle();
    // The picker opens on October 2026 because the end date is 2026-10-31.
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('-30 days'), findsOneWidget);
    expect(find.textContaining('before the start'), findsOneWidget);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale on a phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
