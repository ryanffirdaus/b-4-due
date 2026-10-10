import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/reminders/domain/notification_gateway.dart';
import 'package:b4due/features/reminders/domain/reminder_planner.dart';
import 'package:b4due/features/reminders/domain/reminder_settings.dart';
import 'package:b4due/features/reminders/domain/reminder_sync.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../support/fixtures.dart';

/// In-memory stand-in for the OS notification queue.
class FakeGateway implements NotificationGateway {
  final pending = <int, PlannedNotification>{};
  final texts = <int, NotificationText>{};
  var scheduleCalls = 0;

  @override
  Future<Set<int>> pendingIds() async => pending.keys.toSet();

  @override
  Future<void> schedule(PlannedNotification plan, NotificationText text) async {
    scheduleCalls++;
    pending[plan.id] = plan;
    texts[plan.id] = text;
  }

  @override
  Future<void> cancel(int id) async {
    pending.remove(id);
    texts.remove(id);
  }
}

void main() {
  late AppDatabase db;
  late DriftBillRepository repo;
  late FakeGateway gateway;
  late ReminderSync sync;
  late tz.TZDateTime now;

  setUpAll(tzdata.initializeTimeZones);

  setUp(() {
    final jakarta = tz.getLocation('Asia/Jakarta');
    now = tz.TZDateTime(jakarta, 2026, 8, 1, 12);
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftBillRepository(db);
    gateway = FakeGateway();
    sync = ReminderSync(
      bills: repo,
      settings: () async => const ReminderSettings(),
      gateway: gateway,
      textFor: (plan, bill) =>
          NotificationText(title: bill.name, body: '${plan.days}'),
      now: () => now,
    );
  });

  tearDown(() => db.close());

  test('schedules the plan and is idempotent', () async {
    await repo.save(testBill('pln', due: LocalDate(2026, 8, 20), name: 'PLN'));

    final first = await sync.sync();
    final snapshot = Map.of(gateway.pending);
    final second = await sync.sync();

    expect(first.scheduled, 4);
    expect(second.cancelled, 0);
    expect(gateway.pending, snapshot);
    expect(gateway.pending, hasLength(4));
    expect(gateway.texts.values.map((t) => t.title).toSet(), {'PLN'});
  });

  test('cancels reminders of deleted bills', () async {
    await repo.save(testBill('a', due: LocalDate(2026, 8, 20)));
    await repo.save(testBill('b', due: LocalDate(2026, 8, 22)));
    await sync.sync();
    expect(gateway.pending, hasLength(8));

    await repo.softDelete('a', at: DateTime.utc(2026, 8, 1));
    final result = await sync.sync();

    expect(result.cancelled, 4);
    expect(gateway.pending.values.map((p) => p.billId).toSet(), {'b'});
  });

  test('moves reminders when a bill is paid (due date advanced)', () async {
    final bill = testBill('a', due: LocalDate(2026, 8, 20));
    await repo.save(bill);
    await sync.sync();

    await repo.save(bill.copyWith(dueDate: LocalDate(2026, 9, 20)));
    await sync.sync();

    expect(gateway.pending.values.map((p) => p.dueDate).toSet(), {
      LocalDate(2026, 9, 20),
    });
  });

  test('concurrent calls are coalesced and end in the latest state', () async {
    await repo.save(testBill('a', due: LocalDate(2026, 8, 20)));
    final futures = [sync.sync(), sync.sync(), sync.sync()];
    await Future.wait(futures);
    // One run plus at most one follow-up, not three interleaved runs.
    expect(gateway.scheduleCalls, lessThanOrEqualTo(8));
    expect(gateway.pending, hasLength(4));
  });
}
