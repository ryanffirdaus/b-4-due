import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/bills/domain/bill.dart';
import 'package:b4due/features/calendar/data/drift_calendar_link_repository.dart';
import 'package:b4due/features/calendar/domain/calendar_event_spec.dart';
import 'package:b4due/features/calendar/domain/calendar_gateway.dart';
import 'package:b4due/features/calendar/domain/calendar_sync.dart';
import 'package:b4due/features/reminders/domain/reminder_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fixtures.dart';

class FakeCalendar implements CalendarGateway {
  var permission = true;
  final events = <String, CalendarEventSpec>{};
  var _next = 0;

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<List<CalendarInfo>> writableCalendars() async => const [
    CalendarInfo(id: 'cal-1', name: 'Pribadi'),
  ];

  @override
  Future<CalendarInfo> createLocalCalendar(String name) async =>
      CalendarInfo(id: 'local', name: name);

  @override
  Future<String> createEvent(String calendarId, CalendarEventSpec spec) async {
    final id = 'event-${_next++}';
    events[id] = spec;
    return id;
  }

  @override
  Future<void> deleteEvent(String eventId) async => events.remove(eventId);
}

void main() {
  late tz.Location jakarta;
  setUpAll(() {
    tzdata.initializeTimeZones();
    jakarta = tz.getLocation('Asia/Jakarta');
  });

  group('calendarEventFor', () {
    test('starts at the reminder time in WIB with one alarm per offset', () {
      final spec = calendarEventFor(
        testBill('pln', due: LocalDate(2026, 8, 20), name: 'Listrik PLN'),
        const ReminderSettings(), // H-7, H-3, H-1, H at 09:00
        jakarta,
        describe: (_) => 'Rp 487.500',
      );
      expect(spec.title, 'Listrik PLN');
      expect(spec.start.toUtc(), DateTime.utc(2026, 8, 20, 2));
      expect(spec.end.difference(spec.start), const Duration(minutes: 30));
      expect(spec.alarms, const [
        Duration.zero,
        Duration(days: 1),
        Duration(days: 3),
        Duration(days: 7),
      ]);
    });

    test('caps very early alarms at four weeks', () {
      final spec = calendarEventFor(
        testBill(
          'pkb',
          due: LocalDate(2026, 12, 3),
          reminderOffsets: [60, 30, 1],
        ),
        const ReminderSettings(),
        jakarta,
        describe: (_) => '',
      );
      expect(spec.alarms, const [Duration(days: 1), maxCalendarAlarm]);
    });

    test('fingerprint changes with visible content only', () {
      final bill = testBill('a', due: LocalDate(2026, 8, 20));
      CalendarEventSpec spec(Bill b) => calendarEventFor(
        b,
        const ReminderSettings(),
        jakarta,
        describe: (_) => 'x',
      );
      expect(spec(bill).fingerprint, spec(bill).fingerprint);
      expect(
        spec(bill.copyWith(name: 'Renamed')).fingerprint,
        isNot(spec(bill).fingerprint),
      );
    });
  });

  group('CalendarSync', () {
    late AppDatabase db;
    late DriftBillRepository bills;
    late DriftCalendarLinkRepository links;
    late FakeCalendar calendar;
    late CalendarSync sync;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      bills = DriftBillRepository(db);
      links = DriftCalendarLinkRepository(db);
      calendar = FakeCalendar();
      sync = CalendarSync(
        links: links,
        calendar: calendar,
        billById: bills.findById,
        specFor: (bill) async => calendarEventFor(
          bill,
          const ReminderSettings(),
          jakarta,
          describe: (_) => '',
        ),
      );
    });

    tearDown(() => db.close());

    test('add creates one event and remembers it', () async {
      final bill = testBill('pln', due: LocalDate(2026, 8, 20));
      await bills.save(bill);

      await sync.add(bill, 'cal-1');
      await sync.add(bill, 'cal-1'); // tapping twice does not duplicate

      expect(calendar.events, hasLength(1));
      final link = (await links.getAll()).single;
      expect(link.dueDate, LocalDate(2026, 8, 20));
      expect(calendar.events.containsKey(link.eventId), isTrue);
    });

    test('reconcile replaces the event after the bill is paid', () async {
      final bill = testBill('pln', due: LocalDate(2026, 8, 20));
      await bills.save(bill);
      await sync.add(bill, 'cal-1');

      await bills.save(bill.copyWith(dueDate: LocalDate(2026, 9, 20)));
      await sync.reconcile();

      expect(calendar.events, hasLength(1));
      expect(
        calendar.events.values.single.start.toUtc(),
        DateTime.utc(2026, 9, 20, 2),
      );
      expect((await links.getAll()).single.dueDate, LocalDate(2026, 9, 20));
    });

    test('reconcile updates an edited bill and leaves others alone', () async {
      final a = testBill('a', due: LocalDate(2026, 8, 20));
      final b = testBill('b', due: LocalDate(2026, 8, 21));
      await bills.save(a);
      await bills.save(b);
      await sync.add(a, 'cal-1');
      await sync.add(b, 'cal-1');
      final bEvent = (await links.getAll()).firstWhere((l) => l.billId == 'b');

      await bills.save(a.copyWith(name: 'Listrik rumah'));
      await sync.reconcile();

      expect(
        calendar.events.values.map((e) => e.title),
        contains('Listrik rumah'),
      );
      expect(calendar.events.containsKey(bEvent.eventId), isTrue);
      expect(calendar.events, hasLength(2));
    });

    test('reconcile removes events of deleted and finished bills', () async {
      final bill = testBill('pln', due: LocalDate(2026, 8, 20));
      await bills.save(bill);
      await sync.add(bill, 'cal-1');

      await bills.softDelete('pln', at: DateTime.utc(2026, 8, 1));
      await sync.reconcile();

      expect(calendar.events, isEmpty);
      expect(await links.getAll(), isEmpty);
    });

    test(
      'without permission reconcile does nothing (and never prompts)',
      () async {
        final bill = testBill('pln', due: LocalDate(2026, 8, 20));
        await bills.save(bill);
        await sync.add(bill, 'cal-1');
        calendar.permission = false;

        await bills.save(bill.copyWith(dueDate: LocalDate(2026, 9, 20)));
        await sync.reconcile();

        expect((await links.getAll()).single.dueDate, LocalDate(2026, 8, 20));
      },
    );

    test('remove deletes the event and the link', () async {
      final bill = testBill('pln', due: LocalDate(2026, 8, 20));
      await bills.save(bill);
      await sync.add(bill, 'cal-1');

      await sync.remove('pln');

      expect(calendar.events, isEmpty);
      expect(await links.getAll(), isEmpty);
    });
  });
}
