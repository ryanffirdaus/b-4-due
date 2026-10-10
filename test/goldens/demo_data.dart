import 'package:b4due/core/providers.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/bill.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:b4due/features/currency/currency_providers.dart';
import 'package:b4due/features/currency/domain/money.dart';
import 'package:b4due/features/payments/domain/payment.dart';
import 'package:b4due/features/reminders/domain/reminder_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../support/fixtures.dart';

/// "Today" in every golden.
final goldenToday = LocalDate(2026, 8, 10);

final goldenRates = ExchangeRates(
  idrPerUnit: const {'USD': 17880.55, 'EUR': 20036.94},
  rateDate: LocalDate(2026, 8, 7),
  fetchedAt: DateTime(2026, 8, 10, 8),
);

List<Bill> demoBills() => [
  testBill(
    'bpjs',
    name: 'BPJS Kesehatan',
    category: BillCategory.health,
    due: LocalDate(2026, 8, 8),
    amount: 150000,
  ),
  testBill(
    'pln',
    name: 'Listrik PLN',
    due: LocalDate(2026, 8, 10),
    amount: 487500,
  ),
  testBill(
    'claude',
    name: 'Claude Pro',
    category: BillCategory.subscription,
    due: LocalDate(2026, 8, 12),
    amount: 357611,
  ).copyWith(currency: usd, originalAmountMinor: () => 2000),
  testBill(
    'wifi',
    name: 'Internet rumah',
    category: BillCategory.internet,
    due: LocalDate(2026, 8, 14),
    amount: 330000,
  ),
  testBill(
    'netflix',
    name: 'Netflix',
    category: BillCategory.subscription,
    due: LocalDate(2026, 8, 25),
    amount: 65000,
  ),
  testBill(
    'pkb',
    name: 'Pajak motor',
    category: BillCategory.vehicleTax,
    recurrence: const Recurrence.yearly(),
    due: LocalDate(2026, 11, 2),
  ),
];

PaymentEntry _paid(String billId, String name, LocalDate due, int amount) {
  final at = DateTime(due.year, due.month, due.day, 9);
  return PaymentEntry(
    billName: name,
    payment: Payment(
      id: '$billId-$due',
      billId: billId,
      dueDate: due,
      paidAt: at,
      amount: amount,
      createdAt: at,
    ),
  );
}

/// Six months of history, newest first like the repository returns it.
List<PaymentEntry> demoPayments() => [
  _paid('kpr', 'Cicilan KPR', LocalDate(2026, 8, 5), 1250000),
  _paid('pdam', 'PDAM', LocalDate(2026, 8, 3), 98000),
  for (var m = 7; m >= 3; m--) ...[
    _paid('pln', 'Listrik PLN', LocalDate(2026, m, 10), 420000 + m * 9000),
    _paid('wifi', 'Internet rumah', LocalDate(2026, m, 14), 330000),
    _paid('netflix', 'Netflix', LocalDate(2026, m, 25), 65000),
  ],
];

/// Overrides every stream the tab screens read, so nothing touches a
/// database.
List<Override> demoOverrides({
  List<Bill>? bills,
  List<PaymentEntry>? payments,
}) {
  final history = payments ?? demoPayments();
  return [
    activeBillsProvider.overrideWithValue(AsyncData(bills ?? demoBills())),
    paymentHistoryProvider.overrideWithValue(AsyncData(history)),
    paymentsThisMonthProvider.overrideWithValue(
      AsyncData([
        for (final e in history)
          if (e.payment.paidAt.year == goldenToday.year &&
              e.payment.paidAt.month == goldenToday.month)
            e.payment,
      ]),
    ),
    reminderSettingsProvider.overrideWithValue(
      const AsyncData(ReminderSettings()),
    ),
    exchangeRatesProvider.overrideWithValue(AsyncData(goldenRates)),
  ];
}
