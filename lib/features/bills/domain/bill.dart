import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../currency/domain/money.dart';
import 'bill_category.dart';
import 'recurrence.dart';

/// A bill or subscription the user wants to be reminded about.
///
/// [dueDate] is the *current, unpaid* due date. Paying a repeating bill moves
/// it to the next one; paying a one-off bill archives it.
@immutable
class Bill {
  const Bill({
    required this.id,
    required this.name,
    required this.category,
    required this.dueDate,
    required this.anchorDay,
    required this.recurrence,
    required this.createdAt,
    required this.updatedAt,
    this.amount,
    this.amountIsEstimate = false,
    this.currency = idr,
    this.originalAmountMinor,
    this.cardColor,
    this.installmentTotal,
    this.installmentNumber,
    this.reminderOffsets,
    this.reminderMinuteOfDay,
    this.notes,
    this.paymentUrl,
    this.archivedAt,
    this.deletedAt,
    this.snoozedUntil,
  });

  final String id;
  final String name;
  final BillCategory category;

  /// Whole rupiah. `null` when the user does not know the amount. For a
  /// foreign-currency bill this is the estimate at the latest known rate.
  final int? amount;
  final bool amountIsEstimate;

  /// The currency the bill is priced in. Rupiah for most bills.
  final Currency currency;

  /// The price in [currency]'s minor units (e.g. 2000 = US\$20.00). Null for
  /// rupiah bills, where [amount] is the price.
  final int? originalAmountMinor;

  bool get isForeign => currency != idr;

  /// Which wallet-card colour to show (an index into the app's card
  /// colours); null follows the category.
  final int? cardColor;

  /// Instalment plan: the number of payments in total, and which one is
  /// due now (1-based). Both null for an open-ended bill.
  final int? installmentTotal;
  final int? installmentNumber;

  bool get hasInstallments =>
      installmentTotal != null && installmentNumber != null;

  /// Payments still to make, the current one included.
  int? get installmentsLeft => hasInstallments
      ? (installmentTotal! - installmentNumber! + 1).clamp(0, installmentTotal!)
      : null;

  /// Paying this one finishes the plan.
  bool get isLastInstallment =>
      hasInstallments && installmentNumber! >= installmentTotal!;

  final LocalDate dueDate;

  /// Day of month the user originally chose; see [Recurrence.nextDueDate].
  final int anchorDay;
  final Recurrence recurrence;

  /// Days before the due date to remind (0 = on the day). `null` means "use
  /// the app-wide default".
  final List<int>? reminderOffsets;

  /// Minutes after midnight to send reminders. `null` means "use the default".
  final int? reminderMinuteOfDay;

  final String? notes;
  final String? paymentUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set when a one-off bill has been paid.
  final DateTime? archivedAt;

  /// Soft delete marker. Deleted bills are kept so payment history and
  /// backups stay consistent.
  final DateTime? deletedAt;

  /// When set, one extra "Ingatkan besok" reminder fires at this instant.
  final DateTime? snoozedUntil;

  bool get isDeleted => deletedAt != null;
  bool get isArchived => archivedAt != null;

  /// Whether the bill still needs reminders.
  bool get isActive => !isDeleted && !isArchived;

  Bill copyWith({
    String? name,
    BillCategory? category,
    int? Function()? amount,
    bool? amountIsEstimate,
    Currency? currency,
    int? Function()? originalAmountMinor,
    int? Function()? cardColor,
    int? Function()? installmentTotal,
    int? Function()? installmentNumber,
    LocalDate? dueDate,
    int? anchorDay,
    Recurrence? recurrence,
    List<int>? Function()? reminderOffsets,
    int? Function()? reminderMinuteOfDay,
    String? Function()? notes,
    String? Function()? paymentUrl,
    DateTime? updatedAt,
    DateTime? Function()? archivedAt,
    DateTime? Function()? deletedAt,
    DateTime? Function()? snoozedUntil,
  }) {
    return Bill(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount != null ? amount() : this.amount,
      amountIsEstimate: amountIsEstimate ?? this.amountIsEstimate,
      currency: currency ?? this.currency,
      originalAmountMinor: originalAmountMinor != null
          ? originalAmountMinor()
          : this.originalAmountMinor,
      cardColor: cardColor != null ? cardColor() : this.cardColor,
      installmentTotal: installmentTotal != null
          ? installmentTotal()
          : this.installmentTotal,
      installmentNumber: installmentNumber != null
          ? installmentNumber()
          : this.installmentNumber,
      dueDate: dueDate ?? this.dueDate,
      anchorDay: anchorDay ?? this.anchorDay,
      recurrence: recurrence ?? this.recurrence,
      reminderOffsets: reminderOffsets != null
          ? reminderOffsets()
          : this.reminderOffsets,
      reminderMinuteOfDay: reminderMinuteOfDay != null
          ? reminderMinuteOfDay()
          : this.reminderMinuteOfDay,
      notes: notes != null ? notes() : this.notes,
      paymentUrl: paymentUrl != null ? paymentUrl() : this.paymentUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt != null ? archivedAt() : this.archivedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
      snoozedUntil: snoozedUntil != null ? snoozedUntil() : this.snoozedUntil,
    );
  }

  @override
  String toString() => 'Bill($id, $name, due $dueDate)';
}
