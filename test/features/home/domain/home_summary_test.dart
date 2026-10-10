import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/home/domain/home_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

void main() {
  final today = LocalDate(2026, 8, 10);

  test('splits bills into overdue, this week and later', () {
    final summary = HomeSummary.build(
      today: today,
      bills: [
        testBill('later', due: LocalDate(2026, 8, 17)),
        testBill('overdue', due: LocalDate(2026, 8, 9)),
        testBill('today', due: LocalDate(2026, 8, 10)),
        testBill('day6', due: LocalDate(2026, 8, 16)),
      ],
    );
    expect(summary.overdue.map((b) => b.id), ['overdue']);
    expect(summary.dueThisWeek.map((b) => b.id), ['today', 'day6']);
    expect(summary.later.map((b) => b.id), ['later']);
  });

  test('ignores deleted and archived bills', () {
    final summary = HomeSummary.build(
      today: today,
      bills: [
        testBill('deleted', due: today, deletedAt: DateTime.utc(2026)),
        testBill('archived', due: today, archivedAt: DateTime.utc(2026)),
      ],
    );
    expect(summary.isEmpty, isTrue);
    expect(summary.monthBillCount, 0);
  });

  test('month total counts known amounts and flags unknown ones', () {
    final summary = HomeSummary.build(
      today: today,
      bills: [
        testBill('a', due: LocalDate(2026, 8, 1), amount: 150000),
        testBill('b', due: LocalDate(2026, 8, 31), amount: 1100000),
        testBill('c', due: LocalDate(2026, 8, 20)),
        testBill('next-month', due: LocalDate(2026, 9, 1), amount: 999),
      ],
    );
    expect(summary.monthTotal, 1250000);
    expect(summary.monthBillCount, 3);
    expect(summary.monthUnknownAmountCount, 1);
  });
}
