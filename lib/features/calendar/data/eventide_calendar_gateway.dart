import 'package:eventide/eventide.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../../core/platform/device_channel.dart';
import '../domain/calendar_event_spec.dart';
import '../domain/calendar_gateway.dart';

/// [CalendarGateway] on top of the eventide plugin (Android CalendarContract
/// / iOS EventKit). Calendar permission is requested by eventide on the first
/// call that needs it, i.e. only when the user taps "Tambahkan ke Kalender".
class EventideCalendarGateway implements CalendarGateway {
  EventideCalendarGateway(this._device, [Eventide? eventide])
    : _eventide = eventide ?? Eventide();

  final DeviceChannel _device;
  final Eventide _eventide;

  @override
  Future<bool> hasPermission() => _device.hasCalendarPermission();

  @override
  Future<List<CalendarInfo>> writableCalendars() async {
    try {
      final calendars = await _eventide.retrieveCalendars();
      return [
        for (final c in calendars)
          CalendarInfo(id: c.id, name: c.title, account: c.account.name),
      ];
    } on ETPermissionException {
      throw const CalendarPermissionDenied();
    }
  }

  @override
  Future<CalendarInfo> createLocalCalendar(String name) async {
    try {
      final calendar = await _eventide.createCalendar(
        title: name,
        color: const Color(0xFF459AF8), // Electric Blue
      );
      return CalendarInfo(id: calendar.id, name: calendar.title);
    } on ETPermissionException {
      throw const CalendarPermissionDenied();
    }
  }

  @override
  Future<String> createEvent(String calendarId, CalendarEventSpec spec) async {
    try {
      final event = await _eventide.createEvent(
        calendarId: calendarId,
        title: spec.title,
        startDate: spec.start,
        endDate: spec.end,
        description: spec.description,
        url: spec.url,
        reminders: spec.alarms,
      );
      return event.id;
    } on ETPermissionException {
      throw const CalendarPermissionDenied();
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventide.deleteEvent(eventId: eventId);
    } on ETException catch (e) {
      // Already deleted by the user, or the calendar was removed.
      debugPrint('Calendar event $eventId not deleted: $e');
    }
  }
}
