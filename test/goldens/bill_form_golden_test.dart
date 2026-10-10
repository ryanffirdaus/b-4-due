@Tags(['golden'])
library;

import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/providers.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/presentation/bill_form_screen.dart';
import 'package:b4due/features/currency/currency_providers.dart';
import 'package:b4due/features/currency/domain/exchange_rate_service.dart';
import 'package:b4due/features/currency/domain/money.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/golden.dart';
import '../support/pump_app.dart';
import 'demo_data.dart';

/// Already holds fresh rates, so the form never goes online.
class _CachedRates implements ExchangeRateStore {
  @override
  Future<ExchangeRates?> load() async => goldenRates;

  @override
  Stream<ExchangeRates?> watch() => Stream.value(goldenRates);

  @override
  Future<void> save(ExchangeRates rates) async {}
}

Future<void> _pumpForm(WidgetTester tester, Widget form) async {
  await loadAppFonts();
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  await pumpScreen(
    tester,
    form,
    today: goldenToday,
    overrides: [
      ...demoOverrides(),
      databaseProvider.overrideWithValue(db),
      exchangeRateStoreProvider.overrideWithValue(_CachedRates()),
    ],
  );
}

void main() {
  testWidgets('new bill from the PLN template', (tester) async {
    await _pumpForm(tester, const BillFormScreen(templateKey: 'pln'));
    await expectLater(
      find.byType(BillFormScreen),
      matchesGoldenFile('bill_form_template.png'),
    );
  });

  testWidgets('a USD subscription shows its rupiah estimate', (tester) async {
    await _pumpForm(tester, const BillFormScreen(templateKey: 'claude_pro'));
    await tester.enterText(find.byType(TextField).at(1), '20');
    await tester.pumpAndSettle();
    expect(find.textContaining('357.611'), findsOneWidget);
    await expectLater(
      find.byType(BillFormScreen),
      matchesGoldenFile('bill_form_usd.png'),
    );
  });

  testWidgets('editing a bill with its own reminders', (tester) async {
    final bill = testBill(
      'kpr',
      name: 'Cicilan KPR',
      category: BillCategory.installment,
      due: LocalDate(2026, 8, 25),
      amount: 4250000,
      reminderOffsets: const [14, 3, 0],
      reminderMinuteOfDay: 19 * 60,
    );
    await _pumpForm(tester, BillFormScreen(bill: bill));
    await expectLater(
      find.byType(BillFormScreen),
      matchesGoldenFile('bill_form_edit.png'),
    );
  });
}
