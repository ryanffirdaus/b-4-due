import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/app_database.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/timezone_setup.dart';
import '../../bills/data/drift_bill_repository.dart';
import '../../currency/domain/money.dart';
import '../../home_widget/data/home_widget_gateway.dart';
import '../../payments/data/drift_payment_repository.dart';
import '../../payments/domain/pay_bill.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/notification_action_handler.dart';
import '../domain/reminder_planner.dart';
import '../domain/reminder_sync.dart';
import 'local_notification_gateway.dart';
import 'notification_actions.dart';
import 'notification_text.dart';

/// Everything needed to (re)schedule reminders, wired the same way in the UI
/// isolate, the workmanager task and the notification-action isolate.
class ReminderRuntime {
  ReminderRuntime._(
    this.database,
    this.plugin,
    this.gateway,
    this.sync,
    this.actions,
    this._widget,
    this._clock,
  );

  final AppDatabase database;
  final FlutterLocalNotificationsPlugin plugin;
  final LocalNotificationGateway gateway;
  final ReminderSync sync;
  final NotificationActionHandler actions;
  final HomeWidgetGateway _widget;
  final DateTime Function() _clock;

  /// Reschedules the reminders and refreshes the home-screen widget. Call
  /// this whenever bills or payments change, and from the periodic task so
  /// the widget's countdown stays right.
  Future<ReminderSyncResult> syncAll() async {
    final result = await sync.sync();
    await _widget.refresh(database, LocalDate.fromDateTime(_clock()));
    return result;
  }

  /// [database] defaults to the shared on-device database.
  ///
  /// [onForegroundResponse] receives taps while the app is running (the UI
  /// isolate only); background isolates leave it null.
  static Future<ReminderRuntime> create({
    AppDatabase? database,
    DateTime Function() clock = DateTime.now,
    DidReceiveNotificationResponseCallback? onForegroundResponse,
  }) async {
    await configureLocalTimeZone();
    final l10n = deviceLocalizations();
    await initializeDateFormatting(l10n.localeName);

    final plugin = FlutterLocalNotificationsPlugin();
    await initializeNotificationsPlugin(
      plugin,
      onForegroundResponse: onForegroundResponse,
    );

    final db = database ?? AppDatabase.open();
    final gateway = LocalNotificationGateway(plugin, l10n);
    final settings = SettingsRepository(db);
    final bills = DriftBillRepository(db);
    var main = idr;
    final sync = ReminderSync(
      bills: bills,
      settings: settings.getReminderSettings,
      gateway: gateway,
      beforeSync: () async => main = await settings.mainCurrency(),
      textFor: (plan, bill) =>
          buildNotificationText(l10n, plan, bill, main: main),
      now: () => tz.TZDateTime.from(clock(), tz.local),
      policy: currentSchedulePolicy(),
    );
    final widget = HomeWidgetGateway(l10n);
    Future<void> resync() async {
      await sync.sync();
      await widget.refresh(db, LocalDate.fromDateTime(clock()));
    }

    final actions = NotificationActionHandler(
      payBill: PayBill(
        bills: bills,
        payments: DriftPaymentRepository(db),
        transaction: db.writeTransaction,
        clock: clock,
        onChanged: resync,
        mainCurrency: settings.mainCurrency,
      ),
      snooze: SnoozeBill(bills: bills, clock: clock, onChanged: resync),
    );
    return ReminderRuntime._(db, plugin, gateway, sync, actions, widget, clock);
  }
}

SchedulePolicy currentSchedulePolicy() =>
    !kIsWeb && Platform.isIOS ? SchedulePolicy.ios : SchedulePolicy.android;

/// Initializes the plugin with the same callbacks in every isolate.
/// Initializing without the background handler would unregister it.
Future<void> initializeNotificationsPlugin(
  FlutterLocalNotificationsPlugin plugin, {
  DidReceiveNotificationResponseCallback? onForegroundResponse,
}) async {
  final l10n = deviceLocalizations();
  await plugin.initialize(
    settings: InitializationSettings(
      android: const AndroidInitializationSettings('ic_stat_b4due'),
      // Permission is requested from onboarding, with an explanation first.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            reminderCategoryId,
            actions: [
              DarwinNotificationAction.plain(
                actionMarkPaid,
                l10n.notifActionPaid,
              ),
              DarwinNotificationAction.plain(
                actionSnooze,
                l10n.notifActionSnooze,
              ),
            ],
          ),
        ],
      ),
    ),
    onDidReceiveNotificationResponse: onForegroundResponse,
    onDidReceiveBackgroundNotificationResponse:
        onBackgroundNotificationResponse,
  );
}
