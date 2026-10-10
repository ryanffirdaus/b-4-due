import '../../../core/database/app_database.dart';
import '../domain/calendar_sync.dart';

class DriftCalendarLinkRepository implements CalendarLinkRepository {
  DriftCalendarLinkRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<CalendarLink>> getAll() async =>
      (await _db.select(_db.calendarLinks).get()).map(_fromRow).toList();

  @override
  Stream<CalendarLink?> watch(String billId) =>
      (_db.select(_db.calendarLinks)..where((l) => l.billId.equals(billId)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _fromRow(row));

  @override
  Future<void> save(CalendarLink link) => _db
      .into(_db.calendarLinks)
      .insertOnConflictUpdate(
        CalendarLinkRow(
          billId: link.billId,
          calendarId: link.calendarId,
          eventId: link.eventId,
          dueDate: link.dueDate,
          fingerprint: link.fingerprint,
        ),
      );

  @override
  Future<void> delete(String billId) async {
    await (_db.delete(
      _db.calendarLinks,
    )..where((l) => l.billId.equals(billId))).go();
  }

  static CalendarLink _fromRow(CalendarLinkRow row) => CalendarLink(
    billId: row.billId,
    calendarId: row.calendarId,
    eventId: row.eventId,
    dueDate: row.dueDate,
    fingerprint: row.fingerprint,
  );
}
