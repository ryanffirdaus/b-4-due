import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/currency/currency_providers.dart';
import 'package:b4due/features/currency/domain/money.dart';
import 'package:b4due/features/currency/presentation/main_currency_section.dart';
import 'package:b4due/features/home/presentation/home_screen.dart';
import 'package:b4due/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../goldens/demo_data.dart';
import '../../support/fixtures.dart';
import '../../support/pump_app.dart';

void main() {
  testWidgets('home shows totals in the main currency', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      today: goldenToday,
      locale: const Locale('en'),
      overrides: [
        ...demoOverrides(
          bills: [
            testBill(
              'netflix',
              name: 'Netflix',
              due: LocalDate(2026, 8, 25),
              amount: 1549,
            ).copyWith(currency: usd),
            testBill(
              'pln',
              name: 'PLN Electricity',
              due: LocalDate(2026, 8, 20),
              amount: 2726,
            ).copyWith(originalAmountMinor: () => 487500),
          ],
          payments: const [],
        ),
        initialMainCurrencyProvider.overrideWithValue(usd),
      ],
    );
    // US$15.49 + US$27.26, and the rupiah bill shows its own price.
    expect(find.text('US\$42.75'), findsOneWidget);
    expect(find.textContaining('Rp 487,500 ≈ US\$27.26'), findsWidgets);
  });

  testWidgets('settings show the main currency by code and name', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const B4Scaffold(body: MainCurrencySection()),
      today: goldenToday,
      locale: const Locale('en'),
      overrides: [initialMainCurrencyProvider.overrideWithValue(usd)],
    );
    expect(find.textContaining('USD · US dollar'), findsOneWidget);

    await tester.tap(find.text('Main currency'));
    await tester.pumpAndSettle();
    expect(find.text('Euro'), findsOneWidget);
    // The list goes on to all 31 ECB currencies.
    await tester.scrollUntilVisible(
      find.text('Bulgarian lev'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Bulgarian lev'), findsOneWidget);
  });
}
