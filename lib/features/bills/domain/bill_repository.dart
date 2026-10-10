import 'bill.dart';

/// Persistence boundary for bills. Implemented with Drift in the data layer;
/// the domain and the use cases only depend on this interface.
abstract interface class BillRepository {
  /// Active bills (not deleted, not archived), ordered by due date.
  Stream<List<Bill>> watchActive();

  Future<List<Bill>> getActive();

  /// Every bill including deleted and archived ones; used by backups.
  Future<List<Bill>> getAll();

  Future<Bill?> findById(String id);

  /// Inserts or replaces the bill with the same id.
  Future<void> save(Bill bill);

  /// Marks the bill as deleted without removing the row.
  Future<void> softDelete(String id, {required DateTime at});
}
