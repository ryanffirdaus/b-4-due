@Tags(['golden'])
library;

import 'package:b4due/features/bills/domain/bill.dart';
import 'package:b4due/features/home/presentation/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';
import '../support/pump_app.dart';
import 'demo_data.dart';

Future<void> _pumpHome(
  WidgetTester tester, {
  List<Bill>? bills,
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) async {
  await loadAppFonts();
  await pumpScreen(
    tester,
    const HomeScreen(),
    today: goldenToday,
    textScale: textScale,
    brightness: brightness,
    overrides: demoOverrides(
      bills: bills,
      payments: bills == null ? null : const [],
    ),
  );
}

void main() {
  testWidgets('home with bills', (tester) async {
    await _pumpHome(tester);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('home_with_bills.png'),
    );
  });

  testWidgets('home in dark mode', (tester) async {
    await _pumpHome(tester, brightness: Brightness.dark);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('home_dark.png'),
    );
  });

  testWidgets('home empty state', (tester) async {
    await _pumpHome(tester, bills: const []);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('home_empty.png'),
    );
  });

  testWidgets('home at large system font size', (tester) async {
    await _pumpHome(tester, textScale: 1.6);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('home_large_text.png'),
    );
  });
}
