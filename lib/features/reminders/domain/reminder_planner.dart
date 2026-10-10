import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill.dart';
import 'notification_id.dart';
import 'reminder_settings.dart';

enum ReminderKind {
  /// Before or on the due date (H-7 ... Hari-H).
  upcoming,

  /// After the due date has passed without payment.
  overdue,

  /// "Ingatkan besok" from a notification action.
  snooze,
}

/// One notification that should be pending in the OS.
@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.key,
    required this.billId,
    required this.dueDate,
    required this.kind,
    required this.days,
    required this.fireAt,
  });

  final int id;

  /// Identity of this reminder; [id] is derived from it.
  final String key;
  final String billId;

  /// The due date the reminder is about. Actions such as "paid" carry it so
  /// a stale notification can never pay a later period.
  final LocalDate dueDate;
  final ReminderKind kind;

  /// Days before the due date for [ReminderKind.upcoming], days past it for
  /// [ReminderKind.overdue]. For [ReminderKind.snooze]: days before the due
  /// date, negative when the bill will be overdue by then.
  final int days;
  final tz.TZDateTime fireAt;

  @override
  bool operator ==(Object other) =>
      other is PlannedNotification &&
      other.id == id &&
      other.key == key &&
      other.fireAt == fireAt;

  @override
  int get hashCode => Object.hash(id, key, fireAt);

  @override
  String toString() => 'PlannedNotification($key @ $fireAt #$id)';
}

/// How far ahead to schedule and how many notifications the OS allows.
@immutable
class SchedulePolicy {
  const SchedulePolicy({required this.horizon, required this.maxCount});

  /// Android has no small hard cap, but AlarmManager limits apps to 500
  /// alarms; staying well below leaves room for other components.
  static const android = SchedulePolicy(
    horizon: Duration(days: 120),
    maxCount: 400,
  );

  /// iOS keeps only the 64 soonest local notifications.
  static const ios = SchedulePolicy(horizon: Duration(days: 60), maxCount: 64);

  final Duration horizon;
  final int maxCount;
}

/// How many daily "overdue" nudges to keep queued. The queue is refilled on
/// every sync (app start, daily background task), so nudges continue for as
/// long as the bill stays unpaid without flooding the OS.
const overdueNudgeCount = 3;

/// Decides which notifications should exist right now.
///
/// Pure: the same bills, settings and [now] always give the same result, so
/// rescheduling is idempotent and safe to run as often as needed. [now] must
/// be in the device's location; reminder times are wall-clock times there.
List<PlannedNotification> planNotifications({
  required List<Bill> bills,
  required ReminderSettings settings,
  required tz.TZDateTime now,
  SchedulePolicy policy = SchedulePolicy.android,
}) {
  final location = now.location;
  final today = LocalDate(now.year, now.month, now.day);
  final horizonEnd = now.add(policy.horizon);
  final drafts = <_Draft>[];

  tz.TZDateTime at(LocalDate date, int minuteOfDay) => tz.TZDateTime(
    location,
    date.year,
    date.month,
    date.day,
    minuteOfDay ~/ 60,
    minuteOfDay % 60,
  );

  bool inWindow(tz.TZDateTime t) => t.isAfter(now) && !t.isAfter(horizonEnd);

  for (final bill in bills) {
    if (!bill.isActive) continue;
    final minute = bill.reminderMinuteOfDay ?? settings.defaultMinuteOfDay;
    final offsets = ReminderSettings.normalizeOffsets(
      bill.reminderOffsets ?? settings.defaultOffsets,
    );
    final due = bill.dueDate;
    final keyPrefix = '${bill.id}|${due.toIso()}';
    final billDrafts = <_Draft>[];

    for (final offset in offsets) {
      final fireAt = at(due.addDays(-offset), minute);
      if (!inWindow(fireAt)) continue;
      billDrafts.add(
        _Draft(
          '$keyPrefix|upcoming|$offset',
          bill,
          ReminderKind.upcoming,
          offset,
          fireAt,
        ),
      );
    }

    if (due.isBefore(today)) {
      // Next free daily slots, starting today if today's slot is still ahead.
      var day = at(today, minute).isAfter(now) ? today : today.addDays(1);
      for (var i = 0; i < overdueNudgeCount; i++, day = day.addDays(1)) {
        final fireAt = at(day, minute);
        if (!inWindow(fireAt)) continue;
        billDrafts.add(
          _Draft(
            '$keyPrefix|overdue|${day.toIso()}',
            bill,
            ReminderKind.overdue,
            day.differenceInDays(due),
            fireAt,
          ),
        );
      }
    }

    // A snooze replaces this bill's reminders up to the snooze time, so
    // "Ingatkan besok" at 09:00 does not also leave tomorrow's 09:00 nudge.
    final snoozed = bill.snoozedUntil;
    if (snoozed != null) {
      final fireAt = tz.TZDateTime.from(snoozed, location);
      if (inWindow(fireAt)) {
        billDrafts.removeWhere((d) => !d.fireAt.isAfter(fireAt));
        final snoozeDay = LocalDate(fireAt.year, fireAt.month, fireAt.day);
        billDrafts.add(
          _Draft(
            '$keyPrefix|snooze|${fireAt.millisecondsSinceEpoch}',
            bill,
            ReminderKind.snooze,
            due.differenceInDays(snoozeDay),
            fireAt,
          ),
        );
      }
    }
    drafts.addAll(billDrafts);
  }

  // Soonest first; the key breaks ties so the order is fully deterministic.
  drafts.sort((a, b) {
    final byTime = a.fireAt.compareTo(b.fireAt);
    return byTime != 0 ? byTime : a.key.compareTo(b.key);
  });
  final kept = drafts.take(policy.maxCount).toList();
  final ids = assignNotificationIds(kept.map((d) => d.key));

  return [
    for (final d in kept)
      PlannedNotification(
        id: ids[d.key]!,
        key: d.key,
        billId: d.bill.id,
        dueDate: d.bill.dueDate,
        kind: d.kind,
        days: d.days,
        fireAt: d.fireAt,
      ),
  ];
}

class _Draft {
  _Draft(this.key, this.bill, this.kind, this.days, this.fireAt);

  final String key;
  final Bill bill;
  final ReminderKind kind;
  final int days;
  final tz.TZDateTime fireAt;
}
