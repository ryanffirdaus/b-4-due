import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/platform/device_channel.dart';
import '../core/providers.dart';
import '../features/currency/currency_providers.dart';
import '../features/reminders/domain/reminder_payload.dart';
import '../features/reminders/reminder_providers.dart';
import '../features/security/app_lock_controller.dart';
import '../features/security/presentation/app_lock_gate.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';
import 'routes.dart';
import 'theme.dart';

class B4DueApp extends ConsumerStatefulWidget {
  const B4DueApp({super.key});

  @override
  ConsumerState<B4DueApp> createState() => _B4DueAppState();
}

class _B4DueAppState extends ConsumerState<B4DueApp>
    with WidgetsBindingObserver {
  StreamSubscription<NotificationResponse>? _responses;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _responses = ref
        .read(notificationResponsesProvider)
        .listen(_onNotificationResponse);
    // With the app lock on, keep content out of the recent-apps preview.
    ref.listenManual(
      appLockConfigProvider.select((c) => c.enabled),
      (_, enabled) =>
          ref.read(deviceChannelProvider).setSecure(secure: enabled),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _responses?.cancel();
    super.dispose();
  }

  /// A tap on the notification opens the bill. Action buttons usually go to
  /// the background handler, but iOS may deliver them here while the app is
  /// in the foreground, so handle them the same way.
  Future<void> _onNotificationResponse(NotificationResponse response) async {
    if (response.actionId != null) {
      await ref
          .read(reminderRuntimeProvider)
          .actions
          .handle(response.actionId, response.payload);
      return;
    }
    final payload = ReminderPayload.tryParse(response.payload);
    if (payload == null) return;
    unawaited(ref.read(routerProvider).push(Routes.billDetail(payload.billId)));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      lock.onBackgrounded();
    }
    if (state == AppLifecycleState.resumed) {
      lock.onResumed();
      // "Today" may have changed while the app was in the background, and
      // the notification queue may need refilling.
      ref.invalidate(todayProvider);
      ref.read(onBillsChangedProvider)();
      ref.read(exchangeRateServiceProvider).refreshIfStale();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Indonesian unless the device explicitly prefers a supported language.
      localeResolutionCallback: (locale, supported) {
        for (final candidate in supported) {
          if (candidate.languageCode == locale?.languageCode) return candidate;
        }
        return const Locale('id');
      },
      // The lock covers every route, including ones opened from a
      // notification, and keeps them alive underneath.
      builder: (context, child) => AppLockGate(child: child!),
    );
  }
}
