import 'dart:ui';

import '../../../core/format/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/domain/bill.dart';
import '../../currency/domain/money.dart';
import '../domain/notification_gateway.dart';
import '../domain/reminder_planner.dart';

/// The app's language when no BuildContext is available (background
/// isolates): Indonesian unless the device prefers a supported language.
AppLocalizations deviceLocalizations() {
  final device = PlatformDispatcher.instance.locale;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == device.languageCode,
  );
  return lookupAppLocalizations(
    supported ? Locale(device.languageCode) : const Locale('id'),
  );
}

/// Builds "Listrik PLN" / "Jatuh tempo 3 hari lagi, 20 Agustus 2026 · Rp 487.500".
NotificationText buildNotificationText(
  AppLocalizations l10n,
  PlannedNotification plan,
  Bill bill, {
  Currency main = idr,
}) {
  final format = Formatters.cached(l10n.localeName);
  // A snooze carries signed "days before due"; normalise it.
  final (kind, days) = switch (plan.kind) {
    ReminderKind.snooze when plan.days < 0 => (
      ReminderKind.overdue,
      -plan.days,
    ),
    ReminderKind.snooze => (ReminderKind.upcoming, plan.days),
    _ => (plan.kind, plan.days),
  };
  final when = switch ((kind, days)) {
    (ReminderKind.overdue, final days) => l10n.notifOverdue(days),
    (_, 0) => l10n.notifDueToday,
    (_, 1) => l10n.notifDueTomorrow(format.longDate(plan.dueDate)),
    (_, final days) => l10n.notifDueInDays(days, format.longDate(plan.dueDate)),
  };
  final price = format.price(
    currency: bill.currency,
    amount: bill.amount,
    originalMinor: bill.originalAmountMinor,
    isEstimate: false,
    estimateLabel: (a) => a,
    main: main,
  );
  return NotificationText(
    title: bill.name,
    body: price == null ? when : '$when · $price',
  );
}
