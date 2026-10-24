import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/converters.dart';
import '../../../core/time/local_date.dart';
import '../../currency/domain/money.dart';
import '../domain/payment.dart';
import '../domain/payment_repository.dart';

class DriftPaymentRepository implements PaymentRepository {
  DriftPaymentRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> add(Payment payment) =>
      _db.into(_db.payments).insert(paymentToCompanion(payment));

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.payments)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<bool> exists(String billId, LocalDate dueDate) async {
    final row =
        await (_db.select(_db.payments)
              ..where(
                (p) =>
                    p.billId.equals(billId) &
                    p.dueDate.equals(const LocalDateConverter().toSql(dueDate)),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Stream<List<PaymentEntry>> watchHistory() {
    final query = _db.select(_db.payments).join([
      innerJoin(_db.bills, _db.bills.id.equalsExp(_db.payments.billId)),
    ])..orderBy([OrderingTerm.desc(_db.payments.paidAt)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          PaymentEntry(
            payment: paymentFromRow(row.readTable(_db.payments)),
            billName: row.readTable(_db.bills).name,
          ),
      ],
    );
  }

  @override
  Stream<List<Payment>> watchForDueMonth(int year, int month) {
    final first = LocalDate(year, month, 1);
    final last = first.addMonths(1).addDays(-1);
    const converter = LocalDateConverter();
    final query = _db.select(_db.payments)
      ..where(
        (p) => p.dueDate.isBetweenValues(
          converter.toSql(first),
          converter.toSql(last),
        ),
      );
    return query.watch().map((rows) => rows.map(paymentFromRow).toList());
  }

  @override
  Future<List<Payment>> getAll() async {
    final rows = await (_db.select(
      _db.payments,
    )..orderBy([(p) => OrderingTerm.asc(p.paidAt)])).get();
    return rows.map(paymentFromRow).toList();
  }
}

Payment paymentFromRow(PaymentRow row) => Payment(
  id: row.id,
  billId: row.billId,
  dueDate: row.dueDate,
  paidAt: row.paidAt,
  amount: row.amount,
  currency: currencyByCode(row.currency),
  createdAt: row.createdAt,
);

PaymentsCompanion paymentToCompanion(Payment p) => PaymentsCompanion.insert(
  id: p.id,
  billId: p.billId,
  dueDate: p.dueDate,
  paidAt: p.paidAt,
  amount: Value(p.amount),
  currency: Value(p.currency.code),
  createdAt: p.createdAt,
);
