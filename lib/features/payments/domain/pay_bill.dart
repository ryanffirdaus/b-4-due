import 'package:uuid/uuid.dart';

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill.dart';
import '../../bills/domain/bill_repository.dart';
import '../../bills/domain/bill_service.dart';
import 'payment.dart';
import 'payment_repository.dart';

enum PayOutcome {
  /// Payment recorded; a repeating bill moved to its next due date.
  paid,

  /// Payment recorded; a one-off bill was archived.
  archived,

  /// Nothing to do: the period was already paid, the bill was deleted, or a
  /// stale notification referred to an older period.
  alreadyHandled,
}

/// Result of [PayBill]; [before] allows undo.
class PayResult {
  const PayResult(this.outcome, {this.before, this.payment});

  final PayOutcome outcome;
  final Bill? before;
  final Payment? payment;
}

/// "Sudah dibayar": records the payment and advances the bill.
///
/// Safe to run twice and from any isolate: the work happens in one
/// transaction, and when [expectedDueDate] is given (notification actions
/// always pass it) the payment is only recorded if the bill is still on that
/// period. A double tap, or the same action delivered twice, pays once.
class PayBill {
  PayBill({
    required this._bills,
    required this._payments,
    required this._transaction,
    required this._clock,
    required this._onChanged,
    String Function()? newId,
  }) : _newId = newId ?? const Uuid().v4;

  final BillRepository _bills;
  final PaymentRepository _payments;
  final UnitOfWork _transaction;
  final DateTime Function() _clock;
  final OnBillsChanged _onChanged;
  final String Function() _newId;

  Future<PayResult> call(String billId, {LocalDate? expectedDueDate}) async {
    final result = await _transaction(() async {
      final bill = await _bills.findById(billId);
      if (bill == null || !bill.isActive) {
        return const PayResult(PayOutcome.alreadyHandled);
      }
      if (expectedDueDate != null && bill.dueDate != expectedDueDate) {
        return const PayResult(PayOutcome.alreadyHandled);
      }
      if (await _payments.exists(bill.id, bill.dueDate)) {
        return const PayResult(PayOutcome.alreadyHandled);
      }

      final now = _clock().toUtc();
      final payment = Payment(
        id: _newId(),
        billId: bill.id,
        dueDate: bill.dueDate,
        paidAt: now,
        amount: bill.amount,
        createdAt: now,
      );
      await _payments.add(payment);

      // The last instalment finishes the plan like a one-off bill.
      final next = bill.isLastInstallment
          ? null
          : bill.recurrence.nextDueDate(
              bill.dueDate,
              anchorDay: bill.anchorDay,
            );
      final updated = bill.copyWith(
        dueDate: next,
        archivedAt: next == null ? () => now : null,
        installmentNumber: bill.hasInstallments && next != null
            ? () => bill.installmentNumber! + 1
            : null,
        snoozedUntil: () => null,
        updatedAt: now,
      );
      await _bills.save(updated);
      return PayResult(
        next == null ? PayOutcome.archived : PayOutcome.paid,
        before: bill,
        payment: payment,
      );
    });
    if (result.outcome != PayOutcome.alreadyHandled) await _onChanged();
    return result;
  }

  /// Reverts a payment made a moment ago ("Batalkan" on the snackbar).
  Future<void> undo(PayResult result) async {
    final before = result.before;
    final payment = result.payment;
    if (before == null || payment == null) return;
    await _transaction(() async {
      await _payments.delete(payment.id);
      await _bills.save(before.copyWith(updatedAt: _clock().toUtc()));
    });
    await _onChanged();
  }
}

/// "Ingatkan besok": one extra reminder 24 hours from now.
class SnoozeBill {
  SnoozeBill({
    required this._bills,
    required this._clock,
    required this._onChanged,
  });

  static const delay = Duration(days: 1);

  final BillRepository _bills;
  final DateTime Function() _clock;
  final OnBillsChanged _onChanged;

  Future<bool> call(String billId, {LocalDate? expectedDueDate}) async {
    final bill = await _bills.findById(billId);
    if (bill == null || !bill.isActive) return false;
    if (expectedDueDate != null && bill.dueDate != expectedDueDate) {
      return false;
    }
    final now = _clock().toUtc();
    // Whole minutes, so the reminder lands on a clean time.
    final until = DateTime.fromMillisecondsSinceEpoch(
      (now.add(delay).millisecondsSinceEpoch ~/ 60000) * 60000,
      isUtc: true,
    );
    await _bills.save(bill.copyWith(snoozedUntil: () => until, updatedAt: now));
    await _onChanged();
    return true;
  }
}
