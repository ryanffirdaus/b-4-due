import '../../../core/time/local_date.dart';
import 'payment.dart';

/// Runs [action] atomically. Backed by a database transaction.
typedef UnitOfWork = Future<T> Function<T>(Future<T> Function() action);

abstract interface class PaymentRepository {
  Future<void> add(Payment payment);

  Future<void> delete(String id);

  /// Whether this bill period has already been recorded as paid.
  Future<bool> exists(String billId, LocalDate dueDate);

  /// Newest first, with bill names (including deleted bills).
  Stream<List<PaymentEntry>> watchHistory();

  /// Payments whose period falls in [year]/[month].
  Stream<List<Payment>> watchForDueMonth(int year, int month);

  Future<List<Payment>> getAll();
}
