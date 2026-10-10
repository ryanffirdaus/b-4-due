import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';

/// A recorded payment of one period of a bill.
@immutable
class Payment {
  const Payment({
    required this.id,
    required this.billId,
    required this.dueDate,
    required this.paidAt,
    required this.createdAt,
    this.amount,
  });

  final String id;
  final String billId;

  /// Due date of the period this payment settled.
  final LocalDate dueDate;
  final DateTime paidAt;

  /// Whole rupiah, copied from the bill when paid.
  final int? amount;
  final DateTime createdAt;

  @override
  String toString() => 'Payment($billId, $dueDate)';
}

/// A payment joined with the bill's name, for the history list.
@immutable
class PaymentEntry {
  const PaymentEntry({required this.payment, required this.billName});

  final Payment payment;
  final String billName;
}
