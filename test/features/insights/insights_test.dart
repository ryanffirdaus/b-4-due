import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/domain/bill_status.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:b4due/features/insights/domain/insights.dart';
import 'package:b4due/features/payments/domain/payment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

void main() {
  final today = LocalDate(2026, 10, 10);

  group('BillStatus', () {
    test('follows the countdown', () {
      BillStatus at(int days) =>
          BillStatus.forDueDate(today.addDays(days), today);
      expect(at(-1), BillStatus.overdue);
      expect(at(0), BillStatus.today);
      expect(at(1), BillStatus.dueSoon);
      expect(at(3), BillStatus.dueSoon);
      expect(at(4), BillStatus.upcoming);
    });

    test('deleted bills are cancelled', () {
      final bill = testBill('x', due: today, deletedAt: DateTime.utc(2026));
      expect(BillStatus.of(bill, today), BillStatus.cancelled);
    });
  });

  group('calendarMonth', () {
    test('projects repeating bills through the month', () {
      final weekly = testBill(
        'n',
        name: 'Netflix',
        due: LocalDate(2026, 10, 31),
        recurrence: const Recurrence.monthly(),
      );
      final quarterly = testBill(
        'q',
        name: 'Asuransi',
        due: LocalDate(2026, 8, 15),
        recurrence: Recurrence.everyNMonths(2),
      );
      final november = calendarMonth(
        bills: [weekly, quarterly],
        payments: const [],
        month: LocalDate(2026, 11, 1),
        today: today,
      );
      // 31 Oct + 1 month clamps to 30 Nov; 15 Aug + 2 + 2 months = 15 Dec.
      expect(november.keys, [LocalDate(2026, 11, 30)]);
      expect(november.values.single.single.status, BillStatus.upcoming);

      final october = calendarMonth(
        bills: [quarterly],
        payments: const [],
        month: LocalDate(2026, 10, 1),
        today: today,
      );
      expect(october[LocalDate(2026, 10, 15)]!.single.name, 'Asuransi');
    });

    test('the current due date carries its real status', () {
      final month = calendarMonth(
        bills: [
          testBill('late', due: LocalDate(2026, 10, 8)),
          testBill('now', due: LocalDate(2026, 10, 10)),
        ],
        payments: const [],
        month: LocalDate(2026, 10, 1),
        today: today,
      );
      expect(month[LocalDate(2026, 10, 8)]!.single.status, BillStatus.overdue);
      expect(month[LocalDate(2026, 10, 10)]!.single.status, BillStatus.today);
    });

    test('recorded payments show as paid', () {
      final month = calendarMonth(
        bills: const [],
        payments: [
          PaymentEntry(
            billName: 'PLN',
            payment: Payment(
              id: 'p',
              billId: 'pln',
              dueDate: LocalDate(2026, 10, 2),
              paidAt: DateTime.utc(2026, 10, 1),
              amount: 400000,
              createdAt: DateTime.utc(2026, 10, 1),
            ),
          ),
        ],
        month: LocalDate(2026, 10, 1),
        today: today,
      );
      final entry = month[LocalDate(2026, 10, 2)]!.single;
      expect(entry.status, BillStatus.paid);
      expect(entry.amount, 400000);
    });
  });

  group('spendingStats', () {
    test('averages repeating bills per month and ranks categories', () {
      final stats = spendingStats(
        bills: [
          testBill('pln', due: LocalDate(2026, 10, 20), amount: 500000),
          testBill(
            'pkb',
            due: LocalDate(2026, 12, 3),
            amount: 1200000,
            category: BillCategory.vehicleTax,
            recurrence: const Recurrence.yearly(),
          ),
          testBill(
            'once',
            due: LocalDate(2026, 10, 12),
            amount: 9000000,
            recurrence: const Recurrence.once(),
          ),
          testBill('unknown', due: LocalDate(2026, 10, 25)),
        ],
        payments: const [],
        today: today,
      );
      expect(stats.averageMonthly, 600000);
      expect(stats.byCategory.first.key, BillCategory.electricity);
      expect(stats.mostExpensive!.id, 'pln');
      // Due within 30 days: pln, once, unknown.
      expect(stats.upcomingCount, 3);
      expect(stats.upcomingTotal, 9500000);
    });

    test('sums payments for the last six months', () {
      Payment paid(DateTime at, int amount) => Payment(
        id: '$at',
        billId: 'b',
        dueDate: LocalDate.fromDateTime(at),
        paidAt: at,
        amount: amount,
        createdAt: at,
      );
      final stats = spendingStats(
        bills: const [],
        payments: [
          paid(DateTime(2026, 10, 2), 100),
          paid(DateTime(2026, 10, 5), 50),
          paid(DateTime(2026, 5, 20), 70),
          paid(DateTime(2026, 3, 1), 999), // older than six months
        ],
        today: today,
      );
      expect(stats.monthlyPaid.map((e) => e.key.month), [5, 6, 7, 8, 9, 10]);
      expect(stats.monthlyPaid.first.value, 70);
      expect(stats.monthlyPaid.last.value, 150);
    });
  });
}
