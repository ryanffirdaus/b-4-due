import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../currency/domain/money.dart';

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
    this.currency = idr,
  });

  final String id;
  final String billId;

  /// Due date of the period this payment settled.
  final LocalDate dueDate;
  final DateTime paidAt;

  /// Minor units of [currency], copied from the bill when paid.
  final int? amount;

  /// The main currency when the bill was paid. History keeps it, so a later
  /// change of main currency never rewrites past amounts.
  final Currency currency;
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
