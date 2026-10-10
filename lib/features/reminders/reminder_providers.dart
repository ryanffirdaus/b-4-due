import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/reminder_permissions.dart';
import 'data/reminder_runtime.dart';

/// Overridden in `main` with the runtime created at start-up.
final reminderRuntimeProvider = Provider<ReminderRuntime>(
  (ref) =>
      throw UnimplementedError('reminderRuntimeProvider must be overridden'),
);

final reminderPermissionsProvider = Provider<ReminderPermissions>(
  (ref) => ReminderPermissions(ref.watch(reminderRuntimeProvider).plugin),
);

/// Current permission state; invalidate after returning from system settings.
final reminderPermissionStatusProvider =
    FutureProvider<ReminderPermissionStatus>(
      (ref) => ref.watch(reminderPermissionsProvider).status(),
    );

/// Notification taps and actions delivered to the running UI isolate.
final notificationResponsesProvider = Provider<Stream<NotificationResponse>>(
  (ref) => const Stream.empty(),
);
