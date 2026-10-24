import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/app_database.dart';
import '../../../core/format/formatters.dart';
import '../../../core/platform/device_channel.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/data/drift_bill_repository.dart';
import '../../bills/domain/bill.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../currency/domain/money.dart';
import '../../reminders/data/notification_text.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/calendar_event_spec.dart';
import '../domain/calendar_sync.dart';
import 'drift_calendar_link_repository.dart';
import 'eventide_calendar_gateway.dart';

/// Wires [CalendarSync] to the real database, calendar and settings.
CalendarSync buildCalendarSync(AppDatabase db) {
  final bills = DriftBillRepository(db);
  final settings = SettingsRepository(db);
  final l10n = deviceLocalizations();
  return CalendarSync(
    links: DriftCalendarLinkRepository(db),
    calendar: EventideCalendarGateway(const DeviceChannel()),
    billById: bills.findById,
    specFor: (bill) async {
      final main = await settings.mainCurrency();
      return calendarEventFor(
        bill,
        await settings.getReminderSettings(),
        tz.local,
        describe: (b) => describeForCalendar(l10n, b, main: main),
      );
    },
  );
}

/// Event description: amount, notes, and where the event came from.
String describeForCalendar(
  AppLocalizations l10n,
  Bill bill, {
  Currency main = idr,
}) {
  final format = Formatters.cached(l10n.localeName);
  final price = billPrice(l10n, format, bill, main: main);
  return [
    ?price,
    if (bill.notes != null) bill.notes!,
    l10n.calendarCreatedBy,
  ].join('\n');
}
