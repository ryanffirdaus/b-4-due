import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../bills/data/drift_bill_repository.dart';
import '../../payments/data/drift_payment_repository.dart';
import '../domain/backup_codec.dart';

/// Reads and replaces all user data. Import is all-or-nothing: the file is
/// fully decoded and validated before the database is touched, and the
/// replacement runs in one transaction.
class BackupService {
  BackupService(this._db, {required this._clock, required this._onRestored});

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Reschedules reminders after a restore.
  final Future<void> Function() _onRestored;

  Future<BackupData> collect() async {
    final bills = await DriftBillRepository(_db).getAll();
    final payments = await DriftPaymentRepository(_db).getAll();
    final settings = await _db.select(_db.appSettings).get();
    return BackupData(
      bills: bills,
      payments: payments,
      settings: {for (final s in settings) s.key: s.value},
      exportedAt: _clock().toUtc(),
    );
  }

  Future<String> exportJson() async => BackupCodec.encode(await collect());

  /// Decodes [json] without touching the database, so the UI can show what
  /// the file contains and ask for confirmation first.
  BackupData preview(String json) => BackupCodec.decode(json);

  /// Replaces every bill, payment and portable setting with [data].
  ///
  /// Returns the IDs of calendar events that belonged to the replaced
  /// bills, so the caller can remove them from the calendar.
  Future<List<String>> restore(BackupData data) async {
    final orphanEvents = await _db.writeTransaction(() async {
      final links = await _db.select(_db.calendarLinks).get();
      await _db.delete(_db.calendarLinks).go();
      await _db.delete(_db.payments).go();
      await _db.delete(_db.bills).go();
      await (_db.delete(
        _db.appSettings,
      )..where((s) => s.key.like('reminder.%'))).go();
      await _db.batch((batch) {
        batch
          ..insertAll(_db.bills, data.bills.map(billToCompanion))
          ..insertAll(_db.payments, data.payments.map(paymentToCompanion))
          ..insertAll(_db.appSettings, [
            for (final e in data.settings.entries)
              AppSettingsCompanion.insert(key: e.key, value: e.value),
          ], mode: InsertMode.insertOrReplace);
      });
      return [for (final l in links) l.eventId];
    });
    await _onRestored();
    return orphanEvents;
  }
}
