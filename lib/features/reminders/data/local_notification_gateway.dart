import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../l10n/generated/app_localizations.dart';
import '../domain/notification_action_handler.dart';
import '../domain/notification_gateway.dart';
import '../domain/notification_id.dart';
import '../domain/reminder_payload.dart';
import '../domain/reminder_planner.dart';

/// Android channel for bill reminders. Changing the ID creates a new channel
/// (and loses the user's per-channel settings), so treat it as permanent.
const reminderChannelId = 'bill_reminders';

/// Notification action IDs, also used as iOS action identifiers.
const actionMarkPaid = ReminderActions.markPaid;
const actionSnooze = ReminderActions.snooze;

/// iOS category that carries the two actions above.
const reminderCategoryId = 'bill_reminder';

/// [NotificationGateway] backed by flutter_local_notifications.
class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway(this._plugin, this._l10n);

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations _l10n;
  bool? _canScheduleExact;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// [withActions] adds "Sudah dibayar" and "Ingatkan besok". Both run in
  /// the background without opening the app.
  NotificationDetails details({bool withActions = true}) => NotificationDetails(
    android: AndroidNotificationDetails(
      reminderChannelId,
      _l10n.notifChannelName,
      channelDescription: _l10n.notifChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      icon: 'ic_stat_b4due',
      color: const Color(0xFF459AF8), // Electric Blue, tints the small icon
      actions: withActions
          ? [
              AndroidNotificationAction(
                actionMarkPaid,
                _l10n.notifActionPaid,
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                actionSnooze,
                _l10n.notifActionSnooze,
                cancelNotification: true,
              ),
            ]
          : null,
    ),
    iOS: DarwinNotificationDetails(
      categoryIdentifier: withActions ? reminderCategoryId : null,
    ),
  );

  @override
  Future<Set<int>> pendingIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return {
      for (final p in pending)
        if (!ReservedNotificationIds.contains(p.id)) p.id,
    };
  }

  @override
  Future<void> schedule(PlannedNotification plan, NotificationText text) async {
    // Exact alarms are granted automatically on Android 13+ (USE_EXACT_ALARM)
    // and by the user on Android 12. Without them, fall back to inexact
    // delivery: a reminder a few minutes late beats no reminder.
    final exact = _canScheduleExact ??=
        await _android?.canScheduleExactNotifications() ?? true;
    await _plugin.zonedSchedule(
      id: plan.id,
      title: text.title,
      body: text.body,
      scheduledDate: tz.TZDateTime.from(plan.fireAt, tz.local),
      notificationDetails: details(),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: ReminderPayload(
        billId: plan.billId,
        dueDate: plan.dueDate,
      ).encode(),
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  /// Shows a notification immediately, for "Tes notifikasi sekarang".
  Future<void> showTest() => _plugin.show(
    id: ReservedNotificationIds.test,
    title: _l10n.notifTestTitle,
    body: _l10n.notifTestBody,
    notificationDetails: details(withActions: false),
  );
}
