import 'package:meta/meta.dart';

import '../../bills/domain/bill.dart';
import '../../home/domain/home_summary.dart';

/// What the home-screen widget shows: this month's remaining total and the
/// most urgent bill.
@immutable
class WidgetSnapshot {
  const WidgetSnapshot({required this.total, required this.paid, this.next});

  /// Uses the same numbers as Beranda, so the widget and the app agree.
  factory WidgetSnapshot.from(HomeSummary summary) => WidgetSnapshot(
    total: summary.monthTotal,
    paid: summary.monthPaidTotal,
    next: [
      ...summary.overdue,
      ...summary.dueThisWeek,
      ...summary.later,
    ].firstOrNull,
  );

  /// This month's bills in the main currency, paid or not.
  final int total;
  final int paid;

  /// The most urgent active bill, or null when there is none.
  final Bill? next;

  int get remaining => (total - paid).clamp(0, total);

  /// Paid share of the month, 0 to 100.
  int get percentPaid => total == 0 ? 0 : (paid * 100 / total).round();
}
