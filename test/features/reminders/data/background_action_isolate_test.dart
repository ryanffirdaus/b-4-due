// The "Sudah dibayar" action runs in a background isolate with its own
// database connection, possibly at the same moment as the UI or a second
// delivery of the same action. These tests use real isolates and a real
// SQLite file (WAL, busy timeout) to check that path end to end, minus the
// notification plugin itself (covered on-device by integration_test/).
import 'dart:io';
import 'dart:isolate';

import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/payments/data/drift_payment_repository.dart';
import 'package:b4due/features/payments/domain/pay_bill.dart';
import 'package:b4due/features/reminders/domain/notification_action_handler.dart';
import 'package:b4due/features/reminders/domain/reminder_payload.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../support/fixtures.dart';

AppDatabase _open(String path) =>
    AppDatabase(NativeDatabase(File(path), setup: configureConnection));

/// What `onBackgroundNotificationResponse` does, minus the plugin: open a
/// fresh connection, handle the action, close.
///
/// [startAt] lines several isolates up so their transactions really overlap.
Future<String> _runActionInIsolate(
  String dbPath,
  String actionId,
  String payload, {
  DateTime? startAt,
}) {
  return Isolate.run(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = _open(dbPath);
    try {
      // Open the connection before the barrier, then start together.
      await db.customSelect('SELECT 1').get();
      if (startAt != null) {
        final wait = startAt.difference(DateTime.now());
        if (!wait.isNegative) await Future<void>.delayed(wait);
      }
      final bills = DriftBillRepository(db);
      final handler = NotificationActionHandler(
        payBill: PayBill(
          bills: bills,
          payments: DriftPaymentRepository(db),
          transaction: db.writeTransaction,
          clock: () => DateTime.utc(2026, 8, 20, 2),
          onChanged: () async {},
        ),
        snooze: SnoozeBill(
          bills: bills,
          clock: () => DateTime.utc(2026, 8, 20, 2),
          onChanged: () async {},
        ),
      );
      final outcome = await handler.handle(actionId, payload);
      return outcome.name;
    } finally {
      await db.close();
    }
  });
}

void main() {
  late Directory dir;
  late String dbPath;
  late AppDatabase uiDb;

  final payload = ReminderPayload(
    billId: 'pln',
    dueDate: LocalDate(2026, 8, 20),
  ).encode();

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('b4due_isolate_test');
    dbPath = p.join(dir.path, 'b4due.sqlite');
    uiDb = _open(dbPath);
    await DriftBillRepository(uiDb)
        .save(testBill('pln', due: LocalDate(2026, 8, 20), amount: 487500));
  });

  tearDown(() async {
    await uiDb.close();
    await dir.delete(recursive: true);
  });

  test('"Sudah dibayar" from a background isolate pays and advances', () async {
    final outcome = await _runActionInIsolate(
      dbPath,
      ReminderActions.markPaid,
      payload,
    );

    expect(outcome, 'paid');
    // The UI's own connection sees the background write.
    final bill = await DriftBillRepository(uiDb).findById('pln');
    expect(bill!.dueDate, LocalDate(2026, 9, 20));
    final payments = await DriftPaymentRepository(uiDb).getAll();
    expect(payments.single.dueDate, LocalDate(2026, 8, 20));
  });

  test(
    'simultaneous deliveries in several isolates pay exactly once',
    () async {
      final startAt = DateTime.now().add(const Duration(seconds: 2));
      final outcomes = await Future.wait([
        for (var i = 0; i < 6; i++)
          _runActionInIsolate(
            dbPath,
            ReminderActions.markPaid,
            payload,
            startAt: startAt,
          ),
      ]);

      expect(outcomes.where((o) => o == 'paid'), hasLength(1));
      expect(outcomes.where((o) => o == 'ignored'), hasLength(5));
      expect(await DriftPaymentRepository(uiDb).getAll(), hasLength(1));
      expect(
        (await DriftBillRepository(uiDb).findById('pln'))!.dueDate,
        LocalDate(2026, 9, 20),
      );
    },
  );

  test('works while the UI connection is writing too', () async {
    final ui = DriftBillRepository(uiDb);
    final background = _runActionInIsolate(
      dbPath,
      ReminderActions.markPaid,
      payload,
    );
    // Unrelated writes from the UI at the same time.
    for (var i = 0; i < 20; i++) {
      await ui.save(testBill('other-$i', due: LocalDate(2026, 9, 1)));
    }
    expect(await background, 'paid');
    expect(await ui.getAll(), hasLength(21));
  });

  test(
    'a stale notification for an already-paid period does nothing',
    () async {
      await _runActionInIsolate(dbPath, ReminderActions.markPaid, payload);
      final again = await _runActionInIsolate(
        dbPath,
        ReminderActions.markPaid,
        payload,
      );

      expect(again, 'ignored');
      expect(await DriftPaymentRepository(uiDb).getAll(), hasLength(1));
    },
  );

  test('"Ingatkan besok" from a background isolate sets the snooze', () async {
    final outcome = await _runActionInIsolate(
      dbPath,
      ReminderActions.snooze,
      payload,
    );

    expect(outcome, 'snoozed');
    expect(
      (await DriftBillRepository(uiDb).findById('pln'))!.snoozedUntil,
      DateTime.utc(2026, 8, 21, 2),
    );
  });

  test('malformed payloads and unknown actions are ignored', () async {
    expect(
      await _runActionInIsolate(dbPath, ReminderActions.markPaid, '{oops'),
      'ignored',
    );
    expect(await _runActionInIsolate(dbPath, 'unknown', payload), 'ignored');
    expect(await DriftPaymentRepository(uiDb).getAll(), isEmpty);
  });
}
