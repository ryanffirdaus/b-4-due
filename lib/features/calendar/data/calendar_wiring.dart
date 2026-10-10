import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/app_database.dart';
import '../../../core/format/formatters.dart';
import '../../../core/platform/device_channel.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/data/drift_bill_repository.dart';
import '../../bills/domain/bill.dart';
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
    specFor: (bill) async => calendarEventFor(
      bill,
      await settings.getReminderSettings(),
      tz.local,
      describe: (b) => describeForCalendar(l10n, b),
    ),
  );
}

/// Event description: amount, notes, and where the event came from.
String describeForCalendar(AppLocalizations l10n, Bill bill) {
  final format = Formatters.cached(l10n.localeName);
  final amount = bill.amount;
  return [
    if (amount != null) format.rupiah(amount),
    if (bill.notes != null) bill.notes!,
    l10n.calendarCreatedBy,
  ].join('\n');
}
