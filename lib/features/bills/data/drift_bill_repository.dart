import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../currency/domain/money.dart';
import '../domain/bill.dart';
import '../domain/bill_repository.dart';
import '../domain/recurrence.dart';

class DriftBillRepository implements BillRepository {
  DriftBillRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$BillsTable, BillRow> _activeQuery() =>
      _db.select(_db.bills)
        ..where((b) => b.deletedAt.isNull() & b.archivedAt.isNull())
        ..orderBy([
          (b) => OrderingTerm.asc(b.dueDate),
          (b) => OrderingTerm.asc(b.name),
        ]);

  @override
  Stream<List<Bill>> watchActive() =>
      _activeQuery().watch().map((rows) => rows.map(billFromRow).toList());

  @override
  Future<List<Bill>> getActive() async =>
      (await _activeQuery().get()).map(billFromRow).toList();

  @override
  Future<List<Bill>> getAll() async {
    final rows = await (_db.select(
      _db.bills,
    )..orderBy([(b) => OrderingTerm.asc(b.createdAt)])).get();
    return rows.map(billFromRow).toList();
  }

  @override
  Future<Bill?> findById(String id) async {
    final row = await (_db.select(
      _db.bills,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    return row == null ? null : billFromRow(row);
  }

  @override
  Future<void> save(Bill bill) =>
      _db.into(_db.bills).insertOnConflictUpdate(billToCompanion(bill));

  @override
  Future<void> softDelete(String id, {required DateTime at}) async {
    await (_db.update(_db.bills)..where((b) => b.id.equals(id))).write(
      BillsCompanion(deletedAt: Value(at), updatedAt: Value(at)),
    );
  }
}

Bill billFromRow(BillRow row) => Bill(
  id: row.id,
  name: row.name,
  category: row.category,
  amount: row.amount,
  amountIsEstimate: row.amountIsEstimate,
  currency: currencyByCode(row.currency),
  originalAmountMinor: row.originalAmountMinor,
  cardColor: row.cardColor,
  dueDate: row.dueDate,
  anchorDay: row.anchorDay,
  recurrence: Recurrence.fromStorage(row.recurrence, row.intervalMonths),
  reminderOffsets: row.reminderOffsets,
  reminderMinuteOfDay: row.reminderMinuteOfDay,
  notes: row.notes,
  paymentUrl: row.paymentUrl,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
  archivedAt: row.archivedAt,
  deletedAt: row.deletedAt,
  snoozedUntil: row.snoozedUntil,
);

BillsCompanion billToCompanion(Bill bill) => BillsCompanion.insert(
  id: bill.id,
  name: bill.name,
  category: bill.category,
  amount: Value(bill.amount),
  amountIsEstimate: Value(bill.amountIsEstimate),
  currency: Value(bill.currency.code),
  originalAmountMinor: Value(bill.originalAmountMinor),
  cardColor: Value(bill.cardColor),
  dueDate: bill.dueDate,
  anchorDay: bill.anchorDay,
  recurrence: bill.recurrence.type,
  intervalMonths: Value(bill.recurrence.intervalMonths),
  reminderOffsets: Value(bill.reminderOffsets),
  reminderMinuteOfDay: Value(bill.reminderMinuteOfDay),
  notes: Value(bill.notes),
  paymentUrl: Value(bill.paymentUrl),
  createdAt: bill.createdAt,
  updatedAt: bill.updatedAt,
  archivedAt: Value(bill.archivedAt),
  deletedAt: Value(bill.deletedAt),
  snoozedUntil: Value(bill.snoozedUntil),
);
