import '../../../core/time/local_date.dart';
import 'bill.dart';

/// Where a bill stands relative to today. Drives the status colours.
enum BillStatus {
  /// Recorded as paid (payment history, past calendar days).
  paid,

  /// Due in more than [BillStatus.dueSoonDays] days.
  upcoming,

  /// Due within [BillStatus.dueSoonDays] days.
  dueSoon,

  /// Due today.
  today,

  /// Past its due date and unpaid.
  overdue,

  /// Deleted or finished.
  cancelled;

  static const dueSoonDays = 3;

  static BillStatus of(Bill bill, LocalDate today) {
    if (!bill.isActive) return BillStatus.cancelled;
    return forDueDate(bill.dueDate, today);
  }

  static BillStatus forDueDate(LocalDate due, LocalDate today) {
    final days = due.differenceInDays(today);
    if (days < 0) return BillStatus.overdue;
    if (days == 0) return BillStatus.today;
    if (days <= dueSoonDays) return BillStatus.dueSoon;
    return BillStatus.upcoming;
  }
}
