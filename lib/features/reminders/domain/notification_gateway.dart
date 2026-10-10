import 'package:meta/meta.dart';

import 'reminder_planner.dart';

/// User-visible text of a reminder.
@immutable
class NotificationText {
  const NotificationText({required this.title, required this.body});

  final String title;
  final String body;
}

/// The OS notification scheduler, behind an interface so [ReminderSync] can
/// be tested without a device.
abstract interface class NotificationGateway {
  /// IDs of notifications scheduled but not yet shown.
  Future<Set<int>> pendingIds();

  /// Schedules (or replaces, if the ID exists) one notification.
  Future<void> schedule(PlannedNotification plan, NotificationText text);

  Future<void> cancel(int id);
}
