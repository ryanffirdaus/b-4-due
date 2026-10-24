import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';

import '../../features/bills/domain/bill_category.dart';
import '../../features/bills/domain/recurrence.dart';
import '../time/local_date.dart';
import 'app_database.steps.dart';
import 'converters.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// File name (without extension) of the SQLite database. The Android Auto
/// Backup rules in `android/app/src/main/res/xml` reference it.
const databaseName = 'b4due';

@DriftDatabase(
  tables: [Bills, AppSettings, Payments, CalendarLinks, CachedRates],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database.
  ///
  /// With `shareAcrossIsolates`, every isolate in the process (the UI, the
  /// notification action handler, the workmanager task) talks to a single
  /// drift server isolate, so writes from the background immediately update
  /// the UI's streams. WAL plus a busy timeout covers the remaining case of
  /// two servers racing at start-up.
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: databaseName,
      native: const DriftNativeOptions(
        shareAcrossIsolates: true,
        databaseDirectory: getApplicationSupportDirectory,
        setup: configureConnection,
      ),
    ),
  );

  @override
  int get schemaVersion => 7;

  /// A transaction that takes SQLite's write lock before running [action].
  ///
  /// A plain (deferred) transaction that reads first and writes later can
  /// fail immediately with SQLITE_BUSY when another isolate committed in
  /// between, because WAL cannot upgrade a stale read snapshot; the busy
  /// timeout does not help there. Writing first makes concurrent writers
  /// (UI, notification action isolate, background sync) queue instead.
  ///
  /// Taking the lock can still fail with SQLITE_BUSY before anything is
  /// written: when another connection holds it for longer than the busy
  /// timeout (a slow device, a large restore), and on platforms whose
  /// SQLite build does not actually sleep in its busy handler (measured on
  /// Linux: it gives up after ~65 ms instead of 5 s). So the transaction is
  /// retried here with real pauses for up to [busyRetryWindow], and a
  /// "Sudah dibayar" tap from a notification is never lost to a busy
  /// database.
  Future<T> writeTransaction<T>(Future<T> Function() action) async {
    final waited = Stopwatch()..start();
    for (var attempt = 0; ; attempt++) {
      try {
        return await transaction(() async {
          await customStatement('DELETE FROM app_settings WHERE 0');
          return action();
        });
      } on Object catch (e) {
        if (!_isBusy(e) || waited.elapsed >= busyRetryWindow) rethrow;
        await Future<void>.delayed(_busyPause(attempt));
      }
    }
  }

  /// How long [writeTransaction] keeps retrying a busy database.
  static const busyRetryWindow = Duration(seconds: 30);

  /// 50 ms, doubling up to one second.
  static Duration _busyPause(int attempt) =>
      Duration(milliseconds: 50 * (1 << attempt.clamp(0, 4)).clamp(1, 20));

  static bool _isBusy(Object e) {
    final cause = switch (e) {
      DriftWrappedException(:final cause) => cause,
      _ => e,
    };
    return cause is SqliteException &&
        (cause.resultCode & 0xff) == 5; // SQLITE_BUSY
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // One step per schema version, generated from the dumps in
    // drift_schemas/ and covered by test/core/database/migrations.
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.payments);
        await m.addColumn(schema.bills, schema.bills.snoozedUntil);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.calendarLinks);
      },
      from3To4: (m, schema) async {
        await m.addColumn(schema.bills, schema.bills.currency);
        await m.addColumn(schema.bills, schema.bills.originalAmountMinor);
        await m.createTable(schema.cachedRates);
      },
      from4To5: (m, schema) async {
        await m.addColumn(schema.bills, schema.bills.cardColor);
      },
      from5To6: (m, schema) async {
        await m.addColumn(schema.bills, schema.bills.installmentTotal);
        await m.addColumn(schema.bills, schema.bills.installmentNumber);
      },
      from6To7: (m, schema) async {
        await m.addColumn(schema.payments, schema.payments.currency);
        // Bills priced in another currency were always flagged as an
        // estimate; the flag is now only the user's own choice.
        await m.database.customStatement(
          'UPDATE bills SET amount_is_estimate = 0 '
          'WHERE original_amount_minor IS NOT NULL',
        );
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Per-connection SQLite settings. Must be a top-level function because it is
/// sent to the database isolate.
void configureConnection(CommonDatabase db) {
  db
    ..execute('PRAGMA journal_mode = WAL')
    ..execute('PRAGMA busy_timeout = 5000')
    ..execute('PRAGMA foreign_keys = ON');
}
