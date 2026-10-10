import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification-related permission state, as needed by onboarding/settings.
class ReminderPermissionStatus {
  const ReminderPermissionStatus({
    required this.notificationsAllowed,
    required this.exactAlarmsAllowed,
  });

  final bool notificationsAllowed;

  /// Only ever false on Android 12 (13+ uses USE_EXACT_ALARM).
  final bool exactAlarmsAllowed;

  bool get allGood => notificationsAllowed && exactAlarmsAllowed;
}

class ReminderPermissions {
  ReminderPermissions(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<ReminderPermissionStatus> status() async {
    final android = _android;
    if (android != null) {
      return ReminderPermissionStatus(
        notificationsAllowed: await android.areNotificationsEnabled() ?? true,
        exactAlarmsAllowed:
            await android.canScheduleExactNotifications() ?? true,
      );
    }
    final ios = _ios;
    if (ios != null) {
      final options = await ios.checkPermissions();
      return ReminderPermissionStatus(
        notificationsAllowed: options?.isEnabled ?? false,
        exactAlarmsAllowed: true,
      );
    }
    return const ReminderPermissionStatus(
      notificationsAllowed: true,
      exactAlarmsAllowed: true,
    );
  }

  /// Shows the system prompt (Android 13+, iOS). Returns whether allowed.
  Future<bool> requestNotifications() async {
    final android = _android;
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  /// Opens the "Alarms & reminders" screen (Android 12).
  Future<bool> requestExactAlarms() async =>
      await _android?.requestExactAlarmsPermission() ?? true;
}
