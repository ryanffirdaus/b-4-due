import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/domain/bill.dart';
import '../calendar_providers.dart';
import '../domain/calendar_gateway.dart';

/// Opt-in "Tambahkan ke Kalender" for one bill. Calendar permission is only
/// requested when the user taps the button.
class CalendarCard extends ConsumerStatefulWidget {
  const CalendarCard({required this.bill, super.key});

  final Bill bill;

  @override
  ConsumerState<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends ConsumerState<CalendarCard> {
  var _busy = false;

  Future<void> _run(
    Future<String?> Function(AppLocalizations l10n) action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final message = await action(l10n);
      if (message != null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } on CalendarPermissionDenied {
      messenger.showSnackBar(SnackBar(content: Text(l10n.calendarDenied)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _add(AppLocalizations l10n) async {
    final gateway = ref.read(calendarGatewayProvider);
    final calendars = await gateway.writableCalendars();
    String? calendarId;
    var createdLocal = false;
    if (calendars.isEmpty) {
      // No account calendar on this phone: keep events in a local one.
      calendarId = (await gateway.createLocalCalendar(l10n.appTitle)).id;
      await ref.read(settingsRepositoryProvider).setCalendarId(calendarId);
      createdLocal = true;
    } else {
      calendarId = await _chooseCalendar(l10n, calendars);
    }
    if (calendarId == null) return null;
    await ref.read(calendarSyncProvider).add(widget.bill, calendarId);
    return createdLocal ? l10n.calendarAddedLocal : l10n.calendarAdded;
  }

  Future<String?> _remove(AppLocalizations l10n) async {
    await ref.read(calendarSyncProvider).remove(widget.bill.id);
    return l10n.calendarRemoved;
  }

  /// Uses the calendar picked before, the only one there is, or asks once.
  Future<String?> _chooseCalendar(
    AppLocalizations l10n,
    List<CalendarInfo> calendars,
  ) async {
    final settings = ref.read(settingsRepositoryProvider);
    final saved = await settings.getCalendarId();
    if (calendars.any((c) => c.id == saved)) return saved;
    if (calendars.length == 1) return calendars.single.id;
    if (!mounted) return null;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.calendarChoose),
        children: [
          for (final c in calendars)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, c.id),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: Theme.of(context).textTheme.bodyLarge),
                  if (c.account != null && c.account != c.name)
                    Text(
                      c.account!,
                      style: TextStyle(color: context.palette.textSecondary),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked != null) await settings.setCalendarId(picked);
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final linked =
        ref.watch(calendarLinkProvider(widget.bill.id)).value != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              linked ? Icons.event_available : Icons.edit_calendar_outlined,
              color: linked ? context.palette.primaryText : null,
            ),
            title: Text(linked ? l10n.calendarLinked : l10n.calendarAdd),
            subtitle: Text(
              linked ? l10n.calendarLinkedHelp : l10n.calendarAddHelp,
            ),
            onTap: _busy || linked ? null : () => _run(_add),
          ),
          if (linked) ...[
            const Divider(indent: 16),
            ListTile(
              leading: const Icon(Icons.event_busy_outlined),
              title: Text(l10n.calendarRemove),
              onTap: _busy ? null : () => _run(_remove),
            ),
          ],
        ],
      ),
    );
  }
}
