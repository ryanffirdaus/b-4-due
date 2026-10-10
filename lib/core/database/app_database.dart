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
  int get schemaVersion => 4;

  /// A transaction that takes SQLite's write lock before running [action].
  ///
  /// A plain (deferred) transaction that reads first and writes later can
  /// fail immediately with SQLITE_BUSY when another isolate committed in
  /// between, because WAL cannot upgrade a stale read snapshot; the busy
  /// timeout does not help there. Writing first makes concurrent writers
  /// (UI, notification action isolate, background sync) queue instead.
  Future<T> writeTransaction<T>(Future<T> Function() action) {
    return transaction(() async {
      await customStatement('DELETE FROM app_settings WHERE 0');
      return action();
    });
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
