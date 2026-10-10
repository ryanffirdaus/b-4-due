@Tags(['golden'])
library;

import 'package:b4due/features/bills/presentation/subscriptions_screen.dart';
import 'package:b4due/features/insights/presentation/calendar_screen.dart';
import 'package:b4due/features/insights/presentation/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';
import '../support/pump_app.dart';
import 'demo_data.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  Brightness brightness = Brightness.light,
}) async {
  await loadAppFonts();
  await pumpScreen(
    tester,
    screen,
    today: goldenToday,
    brightness: brightness,
    overrides: demoOverrides(),
  );
}

void main() {
  testWidgets('calendar month', (tester) async {
    await _pump(tester, const CalendarScreen());
    await expectLater(
      find.byType(CalendarScreen),
      matchesGoldenFile('calendar.png'),
    );
  });

  testWidgets('calendar day sheet', (tester) async {
    await _pump(tester, const CalendarScreen());
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    expect(find.text('Claude Pro'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('calendar_day_sheet.png'),
    );
  });

  testWidgets('statistics', (tester) async {
    await _pump(tester, const StatisticsScreen());
    await expectLater(
      find.byType(StatisticsScreen),
      matchesGoldenFile('statistics.png'),
    );
  });

  testWidgets('subscriptions in dark mode', (tester) async {
    await _pump(
      tester,
      const SubscriptionsScreen(),
      brightness: Brightness.dark,
    );
    await expectLater(
      find.byType(SubscriptionsScreen),
      matchesGoldenFile('subscriptions_dark.png'),
    );
  });
}
