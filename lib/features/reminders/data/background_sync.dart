import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../currency/data/exchange_rate_data.dart';
import 'reminder_runtime.dart';

const _periodicTaskName = 'b4due.reminderSync';

/// Workmanager entry point. Runs in its own isolate, possibly while the app
/// is closed, and refills the notification queue (e.g. the daily overdue
/// nudges and reminders that just entered the scheduling window).
@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final runtime = await ReminderRuntime.create();
      final result = await runtime.syncAll();
      debugPrint('Background reminder sync: $result');
      final rates = buildExchangeRateService(
        runtime.database,
        onChanged: () async => runtime.syncAll(),
      );
      debugPrint('Background exchange rates: ${await rates.refreshIfStale()}');
      await runtime.database.close();
      return true;
    } on Object catch (error, stack) {
      debugPrint('Background reminder sync failed: $error\n$stack');
      return false;
    }
  });
}

/// Registers the twice-daily safety-net sync. Android only: iOS background
/// fetch needs BGTaskScheduler setup and gives no timing guarantees, and the
/// iOS queue is refilled whenever the app is opened.
Future<void> registerBackgroundSync() async {
  if (kIsWeb || !Platform.isAndroid) return;
  await Workmanager().initialize(backgroundTaskDispatcher);
  await Workmanager().registerPeriodicTask(
    _periodicTaskName,
    _periodicTaskName,
    frequency: const Duration(hours: 12),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
