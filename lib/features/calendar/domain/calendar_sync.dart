import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill.dart';
import 'calendar_event_spec.dart';
import 'calendar_gateway.dart';

@immutable
class CalendarLink {
  const CalendarLink({
    required this.billId,
    required this.calendarId,
    required this.eventId,
    required this.dueDate,
    required this.fingerprint,
  });

  final String billId;
  final String calendarId;
  final String eventId;
  final LocalDate dueDate;
  final String fingerprint;
}

abstract interface class CalendarLinkRepository {
  Future<List<CalendarLink>> getAll();
  Stream<CalendarLink?> watch(String billId);
  Future<void> save(CalendarLink link);
  Future<void> delete(String billId);
}

/// Keeps calendar events in step with bills: when a bill is paid (new due
/// date), edited, or deleted, the old event is replaced or removed.
class CalendarSync {
  CalendarSync({
    required this._links,
    required this._calendar,
    required this._billById,
    required this._specFor,
  });

  final CalendarLinkRepository _links;
  final CalendarGateway _calendar;
  final Future<Bill?> Function(String id) _billById;
  final Future<CalendarEventSpec> Function(Bill bill) _specFor;

  /// Opt a bill in: creates the event now (may prompt for permission).
  Future<void> add(Bill bill, String calendarId) async {
    final existing = (await _links.getAll())
        .where((l) => l.billId == bill.id)
        .firstOrNull;
    if (existing != null) await _calendar.deleteEvent(existing.eventId);
    final spec = await _specFor(bill);
    final eventId = await _calendar.createEvent(calendarId, spec);
    await _links.save(
      CalendarLink(
        billId: bill.id,
        calendarId: calendarId,
        eventId: eventId,
        dueDate: bill.dueDate,
        fingerprint: spec.fingerprint,
      ),
    );
  }

  Future<void> remove(String billId) async {
    final link = (await _links.getAll())
        .where((l) => l.billId == billId)
        .firstOrNull;
    if (link == null) return;
    await _calendar.deleteEvent(link.eventId);
    await _links.delete(billId);
  }

  /// Brings every linked event up to date. Never prompts: without
  /// permission it does nothing and tries again next time.
  Future<void> reconcile() async {
    final links = await _links.getAll();
    if (links.isEmpty || !await _calendar.hasPermission()) return;
    for (final link in links) {
      final bill = await _billById(link.billId);
      if (bill == null || !bill.isActive) {
        await _calendar.deleteEvent(link.eventId);
        await _links.delete(link.billId);
      } else if (bill.dueDate != link.dueDate ||
          (await _specFor(bill)).fingerprint != link.fingerprint) {
        // Paid (new period) or edited: replace the event.
        await add(bill, link.calendarId);
      }
    }
  }
}
