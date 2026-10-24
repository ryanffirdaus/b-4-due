import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'app/routes.dart';
import 'core/providers.dart';
import 'features/calendar/data/calendar_wiring.dart';
import 'features/calendar/domain/calendar_sync.dart';
import 'features/currency/currency_providers.dart';
import 'features/currency/data/exchange_rate_data.dart';
import 'features/home_widget/data/home_widget_gateway.dart';
import 'features/onboarding/onboarding_controller.dart';
import 'features/reminders/data/background_sync.dart';
import 'features/reminders/data/reminder_runtime.dart';
import 'features/reminders/domain/reminder_payload.dart';
import 'features/reminders/reminder_providers.dart';
import 'features/security/app_lock_controller.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/theme_controller.dart';
import 'ui/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id');
  await initializeDateFormatting('en');

  final responses = StreamController<NotificationResponse>.broadcast();
  final runtime = await ReminderRuntime.create(
    onForegroundResponse: responses.add,
  );
  final settings = SettingsRepository(runtime.database);
  final onboarded = await settings.isOnboardingCompleted();
  final lockConfig = await settings.getAppLock();
  final theme = await settings.getThemePreference();
  final accent = AccentColors.byName(await settings.getAccent());
  final mainCurrency = await settings.ensureMainCurrency(
    regionCode: PlatformDispatcher.instance.locale.countryCode,
  );
  final initialLocation = await _initialLocation(runtime);
  final calendar = buildCalendarSync(runtime.database);

  runApp(
    ProviderScope(
      overrides: [
        initialOnboardingCompletedProvider.overrideWithValue(onboarded),
        initialLocationProvider.overrideWithValue(initialLocation),
        initialAppLockConfigProvider.overrideWithValue(lockConfig),
        initialThemePreferenceProvider.overrideWithValue(theme),
        initialAccentProvider.overrideWithValue(accent),
        initialMainCurrencyProvider.overrideWithValue(mainCurrency),
        notificationResponsesProvider.overrideWithValue(responses.stream),
        databaseProvider.overrideWithValue(runtime.database),
        reminderRuntimeProvider.overrideWithValue(runtime),
        onBillsChangedProvider.overrideWithValue(() async {
          await runtime.syncAll();
          await calendar.reconcile();
        }),
      ],
      child: const B4DueApp(),
    ),
  );

  // Off the critical path: refill the notification queue on every launch and
  // make sure the background safety net is registered.
  unawaited(_afterLaunch(runtime, calendar));
}

/// Opens the bill directly when the app was launched by tapping a reminder.
Future<String> _initialLocation(ReminderRuntime runtime) async {
  final launch = await runtime.plugin.getNotificationAppLaunchDetails();
  final response = launch?.notificationResponse;
  if (launch?.didNotificationLaunchApp == true && response != null) {
    final payload = ReminderPayload.tryParse(response.payload);
    if (payload != null) return Routes.billDetail(payload.billId);
  }
  final widgetBill = WidgetLinks.billId(await launchedFromHomeWidget());
  return widgetBill == null ? Routes.home : Routes.billDetail(widgetBill);
}

Future<void> _afterLaunch(
  ReminderRuntime runtime,
  CalendarSync calendar,
) async {
  try {
    final result = await runtime.syncAll();
    debugPrint('Reminder sync on launch: $result');
    // Replaces events of bills paid from a notification while closed.
    await calendar.reconcile();
    // Today's exchange rates for foreign-currency bills (no-op if fresh).
    final rates = buildExchangeRateService(
      runtime.database,
      onChanged: () async => runtime.syncAll(),
    );
    debugPrint('Exchange rates: ${await rates.refreshIfStale()}');
    await registerBackgroundSync();
  } on Object catch (error, stack) {
    debugPrint('Reminder setup failed: $error\n$stack');
  }
}
