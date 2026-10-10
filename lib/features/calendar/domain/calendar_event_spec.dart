import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../bills/domain/bill.dart';
import '../../reminders/domain/reminder_settings.dart';

/// What the system calendar event for a bill's current due date looks like.
@immutable
class CalendarEventSpec {
  const CalendarEventSpec({
    required this.title,
    required this.start,
    required this.end,
    required this.alarms,
    this.description,
    this.url,
  });

  final String title;
  final DateTime start;
  final DateTime end;

  /// How long before [start] the calendar should alert.
  final List<Duration> alarms;
  final String? description;
  final String? url;

  /// Stable digest of everything the user can see in the event. (Not
  /// `String.hashCode`, which may differ between runs.)
  String get fingerprint => sha1
      .convert(
        utf8.encode(
          [
            title,
            start.toUtc().toIso8601String(),
            end.toUtc().toIso8601String(),
            alarms.map((a) => a.inMinutes).join(','),
            description ?? '',
            url ?? '',
          ].join('\u0000'),
        ),
      )
      .toString();
}

/// Calendar apps reject very early alarms (Google Calendar caps at 4 weeks).
const maxCalendarAlarm = Duration(days: 28);

/// Builds the event for [bill]'s current due date: a 30-minute event at the
/// bill's reminder time, with one alarm per reminder offset, so the calendar
/// app alerts even if the phone kills B4Due's own notifications.
CalendarEventSpec calendarEventFor(
  Bill bill,
  ReminderSettings settings,
  tz.Location location, {
  required String Function(Bill bill) describe,
}) {
  final minute = bill.reminderMinuteOfDay ?? settings.defaultMinuteOfDay;
  final due = bill.dueDate;
  final start = tz.TZDateTime(
    location,
    due.year,
    due.month,
    due.day,
    minute ~/ 60,
    minute % 60,
  );
  final offsets = ReminderSettings.normalizeOffsets(
    bill.reminderOffsets ?? settings.defaultOffsets,
  );
  final alarms = <Duration>{
    for (final days in offsets)
      Duration(days: days) > maxCalendarAlarm
          ? maxCalendarAlarm
          : Duration(days: days),
  }.toList()..sort();
  return CalendarEventSpec(
    title: bill.name,
    start: start,
    end: start.add(const Duration(minutes: 30)),
    alarms: alarms,
    description: describe(bill),
    url: bill.paymentUrl,
  );
}
