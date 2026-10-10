import 'package:meta/meta.dart';

import 'calendar_event_spec.dart';

@immutable
class CalendarInfo {
  const CalendarInfo({required this.id, required this.name, this.account});

  final String id;
  final String name;
  final String? account;
}

/// Thrown when the user refuses calendar access.
class CalendarPermissionDenied implements Exception {
  const CalendarPermissionDenied();
}

/// The system calendar, behind an interface for tests.
abstract interface class CalendarGateway {
  /// Checks access without prompting.
  Future<bool> hasPermission();

  /// May prompt for permission (only call from a user action).
  Future<List<CalendarInfo>> writableCalendars();

  /// Creates an on-device calendar, for phones without any account
  /// calendar (e.g. no Google account).
  Future<CalendarInfo> createLocalCalendar(String name);

  /// Returns the new event's ID. May prompt for permission.
  Future<String> createEvent(String calendarId, CalendarEventSpec spec);

  /// Deleting an event the user already removed is not an error.
  Future<void> deleteEvent(String eventId);
}
