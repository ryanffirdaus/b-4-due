import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:b4due/features/reminders/domain/notification_id.dart';
import 'package:b4due/features/reminders/domain/reminder_planner.dart';
import 'package:b4due/features/reminders/domain/reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../support/fixtures.dart';

void main() {
  late tz.Location jakarta;

  setUpAll(() {
    tzdata.initializeTimeZones();
    jakarta = tz.getLocation('Asia/Jakarta');
  });

  tz.TZDateTime wib(int y, int m, int d, [int h = 0, int min = 0]) =>
      tz.TZDateTime(jakarta, y, m, d, h, min);

  const settings = ReminderSettings(); // H-7, H-3, H-1, H, 09:00

  List<String> fireTimes(List<PlannedNotification> plan) =>
      plan.map((p) => p.fireAt.toIso8601String()).toList();

  group('upcoming reminders', () {
    test('default offsets at 09:00 WIB', () {
      final plan = planNotifications(
        bills: [testBill('pln', due: LocalDate(2026, 8, 20))],
        settings: settings,
        now: wib(2026, 8, 1, 12),
      );
      expect(fireTimes(plan), [
        '2026-08-13T09:00:00.000+0700',
        '2026-08-17T09:00:00.000+0700',
        '2026-08-19T09:00:00.000+0700',
        '2026-08-20T09:00:00.000+0700',
      ]);
      expect(plan.map((p) => p.days), [7, 3, 1, 0]);
      expect(plan.every((p) => p.kind == ReminderKind.upcoming), isTrue);
    });

    test('09:00 WIB is 02:00 UTC', () {
      final plan = planNotifications(
        bills: [
          testBill('pln', due: LocalDate(2026, 8, 20), reminderOffsets: [0]),
        ],
        settings: settings,
        now: wib(2026, 8, 1),
      );
      expect(plan.single.fireAt.toUtc(), DateTime.utc(2026, 8, 20, 2));
    });

    test('skips reminders whose time has already passed', () {
      final plan = planNotifications(
        bills: [testBill('pln', due: LocalDate(2026, 8, 20))],
        settings: settings,
        // 09:00 on H-1 has passed; only the due-day reminder is left.
        now: wib(2026, 8, 19, 9, 1),
      );
      expect(fireTimes(plan), ['2026-08-20T09:00:00.000+0700']);
    });

    test('a reminder exactly at "now" is not rescheduled', () {
      final plan = planNotifications(
        bills: [
          testBill('pln', due: LocalDate(2026, 8, 20), reminderOffsets: [0]),
        ],
        settings: settings,
        now: wib(2026, 8, 20, 9),
      );
      expect(plan, isEmpty);
    });

    test('per-bill offsets and time override the defaults', () {
      final plan = planNotifications(
        bills: [
          testBill(
            'kpr',
            due: LocalDate(2026, 9, 5),
            reminderOffsets: [14, 0, 14],
            reminderMinuteOfDay: 19 * 60 + 30,
          ),
        ],
        settings: settings,
        now: wib(2026, 8, 1),
      );
      expect(fireTimes(plan), [
        '2026-08-22T19:30:00.000+0700',
        '2026-09-05T19:30:00.000+0700',
      ]);
    });

    test('offsets crossing a month boundary', () {
      final plan = planNotifications(
        bills: [
          testBill('bpjs', due: LocalDate(2026, 3, 2), reminderOffsets: [3]),
        ],
        settings: settings,
        now: wib(2026, 2, 1),
      );
      expect(fireTimes(plan), ['2026-02-27T09:00:00.000+0700']);
    });
  });

  group('bill state', () {
    test('deleted and archived (paid one-off) bills get nothing', () {
      final plan = planNotifications(
        bills: [
          testBill(
            'deleted',
            due: LocalDate(2026, 8, 20),
            deletedAt: DateTime.utc(2026, 8),
          ),
          testBill(
            'paid-once',
            due: LocalDate(2026, 8, 20),
            recurrence: const Recurrence.once(),
            archivedAt: DateTime.utc(2026, 8),
          ),
        ],
        settings: settings,
        now: wib(2026, 8, 1),
      );
      expect(plan, isEmpty);
    });

    test('paying moves reminders to the next due date', () {
      final before = testBill('pln', due: LocalDate(2026, 8, 20));
      final after = before.copyWith(dueDate: LocalDate(2026, 9, 20));
      final now = wib(2026, 8, 18);

      final planBefore = planNotifications(
        bills: [before],
        settings: settings,
        now: now,
      );
      final planAfter = planNotifications(
        bills: [after],
        settings: settings,
        now: now,
      );

      expect(
        planBefore.every((p) => p.dueDate == LocalDate(2026, 8, 20)),
        isTrue,
      );
      expect(
        planAfter.every((p) => p.dueDate == LocalDate(2026, 9, 20)),
        isTrue,
      );
      expect(fireTimes(planAfter).first, '2026-09-13T09:00:00.000+0700');
      // Different period, different keys: nothing from August survives.
      expect(
        planAfter
            .map((p) => p.key)
            .toSet()
            .intersection(planBefore.map((p) => p.key).toSet()),
        isEmpty,
      );
    });
  });

  group('overdue bills', () {
    test('get three daily nudges starting today when the slot is ahead', () {
      final plan = planNotifications(
        bills: [testBill('bpjs', due: LocalDate(2026, 8, 10))],
        settings: settings,
        now: wib(2026, 8, 12, 7),
      );
      expect(plan.every((p) => p.kind == ReminderKind.overdue), isTrue);
      expect(fireTimes(plan), [
        '2026-08-12T09:00:00.000+0700',
        '2026-08-13T09:00:00.000+0700',
        '2026-08-14T09:00:00.000+0700',
      ]);
      expect(plan.map((p) => p.days), [2, 3, 4]);
    });

    test('start tomorrow once today\'s slot has passed', () {
      final plan = planNotifications(
        bills: [testBill('bpjs', due: LocalDate(2026, 8, 10))],
        settings: settings,
        now: wib(2026, 8, 12, 21),
      );
      expect(fireTimes(plan).first, '2026-08-13T09:00:00.000+0700');
      expect(plan, hasLength(overdueNudgeCount));
    });

    test('a bill due today is not overdue yet', () {
      final plan = planNotifications(
        bills: [testBill('pln', due: LocalDate(2026, 8, 10))],
        settings: settings,
        now: wib(2026, 8, 10, 8),
      );
      expect(plan.single.kind, ReminderKind.upcoming);
      expect(plan.single.days, 0);
    });
  });

  group('snoozed bills', () {
    test('get one reminder at the snooze time, replacing earlier ones', () {
      final bill = testBill('bpjs', due: LocalDate(2026, 8, 10)).copyWith(
        // "Ingatkan besok" tapped at 09:00 WIB on 12 Aug.
        snoozedUntil: () => DateTime.utc(2026, 8, 13, 2),
      );
      final plan = planNotifications(
        bills: [bill],
        settings: settings,
        now: wib(2026, 8, 12, 9, 1),
      );
      // The overdue nudge at 13 Aug 09:00 is replaced by the snooze.
      expect(plan.first.kind, ReminderKind.snooze);
      expect(
        plan.first.fireAt.toIso8601String(),
        '2026-08-13T09:00:00.000+0700',
      );
      expect(plan.first.days, -3);
      expect(
        plan.where((p) => !p.fireAt.isAfter(plan.first.fireAt)),
        hasLength(1),
      );
      expect(plan.skip(1).every((p) => p.kind == ReminderKind.overdue), isTrue);
    });

    test('an expired snooze is ignored', () {
      final bill = testBill(
        'pln',
        due: LocalDate(2026, 8, 20),
      ).copyWith(snoozedUntil: () => DateTime.utc(2026, 8, 1));
      final plan = planNotifications(
        bills: [bill],
        settings: settings,
        now: wib(2026, 8, 5),
      );
      expect(plan.any((p) => p.kind == ReminderKind.snooze), isFalse);
      expect(plan, hasLength(4));
    });
  });

  group('ids and limits', () {
    test('are deterministic and independent of input order', () {
      final bills = [
        testBill('a', due: LocalDate(2026, 8, 20)),
        testBill('b', due: LocalDate(2026, 8, 21)),
        testBill('c', due: LocalDate(2026, 8, 5)),
      ];
      final now = wib(2026, 8, 8);
      final first = planNotifications(
        bills: bills,
        settings: settings,
        now: now,
      );
      final second = planNotifications(
        bills: bills.reversed.toList(),
        settings: settings,
        now: now,
      );
      expect(second, first);
      expect(first.map((p) => p.id).toSet(), hasLength(first.length));
      expect(first.any((p) => ReservedNotificationIds.contains(p.id)), isFalse);
    });

    test('the same reminder keeps its id across runs', () {
      final bill = testBill('a', due: LocalDate(2026, 8, 20));
      final early = planNotifications(
        bills: [bill],
        settings: settings,
        now: wib(2026, 8, 1),
      );
      final later = planNotifications(
        bills: [bill],
        settings: settings,
        now: wib(2026, 8, 18),
      );
      final dueDayEarly = early.singleWhere((p) => p.days == 0);
      final dueDayLater = later.singleWhere((p) => p.days == 0);
      expect(dueDayLater.id, dueDayEarly.id);
    });

    test('respects the 64-notification iOS limit, soonest first', () {
      final bills = [
        for (var i = 0; i < 30; i++)
          testBill('bill-$i', due: LocalDate(2026, 9, 1).addDays(i)),
      ];
      final plan = planNotifications(
        bills: bills,
        settings: settings,
        now: wib(2026, 8, 1),
        policy: SchedulePolicy.ios,
      );
      expect(plan, hasLength(64));
      final times = plan.map((p) => p.fireAt).toList();
      expect(times, [...times]..sort());

      final everything = planNotifications(
        bills: bills,
        settings: settings,
        now: wib(2026, 8, 1),
        policy: const SchedulePolicy(
          horizon: Duration(days: 365),
          maxCount: 1000,
        ),
      );
      expect(everything, hasLength(120));
      expect(plan.last.fireAt.isAfter(everything[63].fireAt), isFalse);
    });

    test('only schedules inside the horizon', () {
      final plan = planNotifications(
        bills: [
          testBill(
            'stnk',
            due: LocalDate(2031, 8, 17),
            recurrence: const Recurrence.every5Years(),
          ),
        ],
        settings: settings,
        now: wib(2026, 8, 1),
      );
      expect(plan, isEmpty);
    });
  });

  group('assignNotificationIds', () {
    test('probes past collisions and reserved ids deterministically', () {
      final ids = assignNotificationIds(['x', 'y', 'z']);
      expect(ids.values.toSet(), hasLength(3));
      expect(assignNotificationIds(['z', 'x', 'y']), ids);
    });

    test('stable hash matches known FNV-1a values', () {
      // FNV-1a 32-bit of "" is 0x811c9dc5; of "a" is 0xe40c292c.
      expect(stableNotificationId(''), 0x811c9dc5 & 0x7fffffff);
      expect(stableNotificationId('a'), 0xe40c292c & 0x7fffffff);
    });
  });
}
