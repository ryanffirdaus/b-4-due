import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill.dart';
import '../../bills/domain/bill_category.dart';
import '../../bills/domain/bill_status.dart';
import '../../currency/domain/money.dart';
import '../../payments/domain/payment.dart';

/// One dot on the calendar: a bill due (or paid) on a given day.
@immutable
class CalendarEntry {
  const CalendarEntry({
    required this.billId,
    required this.name,
    required this.date,
    required this.status,
    this.amount,
    this.currency = idr,
    this.bill,
  });

  final String billId;
  final String name;
  final LocalDate date;
  final BillStatus status;

  /// In [currency]'s minor units.
  final int? amount;
  final Currency currency;

  /// The bill, for upcoming entries (null for past payments of deleted bills).
  final Bill? bill;
}

/// Every due date of active bills, projected forward through their
/// recurrence, plus recorded payments, for the month of [month].
///
/// The current unpaid due date gets its real status (overdue, today, ...);
/// projected later periods are "upcoming"; periods with a recorded payment
/// are "paid".
Map<LocalDate, List<CalendarEntry>> calendarMonth({
  required List<Bill> bills,
  required List<PaymentEntry> payments,
  required LocalDate month,
  required LocalDate today,
  Currency main = idr,
}) {
  final first = LocalDate(month.year, month.month, 1);
  final last = first.addMonths(1).addDays(-1);
  final result = <LocalDate, List<CalendarEntry>>{};
  void add(CalendarEntry e) => result.putIfAbsent(e.date, () => []).add(e);

  for (final bill in bills.where((b) => b.isActive)) {
    var due = bill.dueDate;
    var current = true;
    // Bounded: even a monthly bill only needs a few steps to pass the month.
    for (var i = 0; i < 400 && !due.isAfter(last); i++) {
      if (!due.isBefore(first)) {
        add(
          CalendarEntry(
            billId: bill.id,
            name: bill.name,
            date: due,
            status: current
                ? BillStatus.forDueDate(due, today)
                : BillStatus.upcoming,
            amount: bill.amount,
            currency: main,
            bill: bill,
          ),
        );
      }
      final next = bill.recurrence.nextDueDate(due, anchorDay: bill.anchorDay);
      if (next == null) break;
      due = next;
      current = false;
    }
  }

  for (final entry in payments) {
    final p = entry.payment;
    if (p.dueDate.isBefore(first) || p.dueDate.isAfter(last)) continue;
    add(
      CalendarEntry(
        billId: p.billId,
        name: entry.billName,
        date: p.dueDate,
        status: BillStatus.paid,
        amount: p.amount,
        currency: p.currency,
      ),
    );
  }

  for (final list in result.values) {
    list.sortBy((e) => e.name.toLowerCase());
  }
  return result;
}

/// Figures for the statistics screen.
@immutable
class SpendingStats {
  const SpendingStats({
    required this.averageMonthly,
    required this.byCategory,
    required this.monthlyPaid,
    required this.upcomingTotal,
    required this.upcomingCount,
    this.mostExpensive,
    this.mostExpensiveMonthly = 0,
  });

  /// Monthly-equivalent cost of every active repeating bill with a known
  /// amount (a yearly Rp 1.200.000 counts as Rp 100.000/month).
  final int averageMonthly;

  /// Monthly-equivalent cost per category, largest first.
  final List<MapEntry<BillCategory, int>> byCategory;

  /// Paid per calendar month in the main currency, oldest first (last six
  /// months).
  final List<MapEntry<LocalDate, int>> monthlyPaid;

  /// Bills due in the next 30 days.
  final int upcomingTotal;
  final int upcomingCount;

  final Bill? mostExpensive;
  final int mostExpensiveMonthly;

  bool get isEmpty =>
      averageMonthly == 0 && monthlyPaid.every((e) => e.value == 0);
}

/// Monthly-equivalent amount of a repeating bill in the main currency (null
/// for one-off bills and unknown amounts).
int? monthlyEquivalent(Bill bill) {
  final amount = bill.amount;
  final months = bill.recurrence.intervalMonths;
  if (amount == null || months == 0) return null;
  return (amount / months).round();
}

SpendingStats spendingStats({
  required List<Bill> bills,
  required List<Payment> payments,
  required LocalDate today,
  MoneyConverter money = MoneyConverter.rupiahOnly,
}) {
  final active = bills.where((b) => b.isActive).toList();

  var average = 0;
  final perCategory = <BillCategory, int>{};
  Bill? top;
  var topMonthly = 0;
  for (final bill in active) {
    final monthly = monthlyEquivalent(bill);
    if (monthly == null) continue;
    average += monthly;
    perCategory.update(
      bill.category,
      (v) => v + monthly,
      ifAbsent: () => monthly,
    );
    if (monthly > topMonthly) {
      top = bill;
      topMonthly = monthly;
    }
  }

  final thisMonth = LocalDate(today.year, today.month, 1);
  final months = [for (var i = 5; i >= 0; i--) thisMonth.addMonths(-i)];
  final paid = {for (final m in months) m: 0};
  for (final p in payments) {
    final local = p.paidAt.toLocal();
    final key = LocalDate(local.year, local.month, 1);
    if (paid.containsKey(key)) {
      paid[key] = paid[key]! + (money.toMain(p.amount, p.currency) ?? 0);
    }
  }

  final horizon = today.addDays(30);
  var upcomingTotal = 0;
  var upcomingCount = 0;
  for (final bill in active) {
    if (bill.dueDate.isAfter(horizon)) continue;
    upcomingCount++;
    upcomingTotal += bill.amount ?? 0;
  }

  return SpendingStats(
    averageMonthly: average,
    byCategory: perCategory.entries.sortedBy<num>((e) => -e.value),
    monthlyPaid: paid.entries.toList(),
    upcomingTotal: upcomingTotal,
    upcomingCount: upcomingCount,
    mostExpensive: top,
    mostExpensiveMonthly: topMonthly,
  );
}
