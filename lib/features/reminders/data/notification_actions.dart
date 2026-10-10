import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'reminder_runtime.dart';

/// Entry point for "Sudah dibayar" / "Ingatkan besok" tapped on a
/// notification. Runs in a fresh background isolate, often while the app is
/// not running at all.
///
/// The database connection goes through drift's shared isolate: if the UI is
/// alive, this isolate talks to the same database server, so the home screen
/// updates immediately; if not, it starts the server itself. The use cases
/// are transactional and idempotent, so a duplicate delivery pays only once.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  DartPluginRegistrant.ensureInitialized();
  final runtime = await ReminderRuntime.create();
  try {
    final outcome = await runtime.actions.handle(
      response.actionId,
      response.payload,
    );
    debugPrint('Notification action ${response.actionId}: $outcome');
  } on Object catch (error, stack) {
    debugPrint('Notification action failed: $error\n$stack');
  } finally {
    await runtime.database.close();
  }
}
