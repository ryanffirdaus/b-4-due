import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill.dart';
import '../../payments/domain/payment.dart';

/// Everything the home screen shows, computed from plain data so it can be
/// unit tested without widgets.
@immutable
class HomeSummary {
  const HomeSummary({
    required this.overdue,
    required this.dueThisWeek,
    required this.later,
    required this.monthTotal,
    required this.monthBillCount,
    required this.monthUnknownAmountCount,
    this.monthPaidTotal = 0,
    this.monthPaidCount = 0,
  });

  /// Builds the summary for [today]. "This week" is today plus the next six
  /// days, which matches how people think about "what's coming up".
  ///
  /// [paymentsThisMonth] are payments for periods due this month; they count
  /// towards the month total so it does not shrink as bills get paid.
  factory HomeSummary.build({
    required List<Bill> bills,
    required LocalDate today,
    List<Payment> paymentsThisMonth = const [],
  }) {
    final active = bills.where((b) => b.isActive).toList()
      ..sort((a, b) {
        final byDate = a.dueDate.compareTo(b.dueDate);
        return byDate != 0 ? byDate : a.name.compareTo(b.name);
      });
    final weekEnd = today.addDays(6);

    final overdue = <Bill>[];
    final thisWeek = <Bill>[];
    final later = <Bill>[];
    for (final bill in active) {
      if (bill.dueDate.isBefore(today)) {
        overdue.add(bill);
      } else if (!bill.dueDate.isAfter(weekEnd)) {
        thisWeek.add(bill);
      } else {
        later.add(bill);
      }
    }

    var total = 0;
    var count = 0;
    var unknown = 0;
    for (final bill in active) {
      final due = bill.dueDate;
      if (due.year != today.year || due.month != today.month) continue;
      count++;
      final amount = bill.amount;
      if (amount == null) {
        unknown++;
      } else {
        total += amount;
      }
    }

    var paid = 0;
    for (final payment in paymentsThisMonth) {
      paid += payment.amount ?? 0;
    }

    return HomeSummary(
      overdue: overdue,
      dueThisWeek: thisWeek,
      later: later,
      monthTotal: total + paid,
      monthBillCount: count,
      monthUnknownAmountCount: unknown,
      monthPaidTotal: paid,
      monthPaidCount: paymentsThisMonth.length,
    );
  }

  final List<Bill> overdue;
  final List<Bill> dueThisWeek;
  final List<Bill> later;

  /// Known amounts of everything due this month, paid or not.
  final int monthTotal;

  /// Unpaid bills due this month.
  final int monthBillCount;
  final int monthUnknownAmountCount;
  final int monthPaidTotal;
  final int monthPaidCount;

  bool get isEmpty => overdue.isEmpty && dueThisWeek.isEmpty && later.isEmpty;
}
