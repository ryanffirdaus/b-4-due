import 'package:drift/drift.dart';

import '../../features/bills/domain/recurrence.dart';
import 'converters.dart';

/// Bills and subscriptions. Rows are soft-deleted via [deletedAt].
@DataClassName('BillRow')
class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get category => text().map(const BillCategoryConverter())();

  /// Whole rupiah; null when unknown.
  IntColumn get amount => integer().nullable()();
  BoolColumn get amountIsEstimate =>
      boolean().withDefault(const Constant(false))();

  TextColumn get dueDate => text().map(const LocalDateConverter())();
  IntColumn get anchorDay => integer()();
  TextColumn get recurrence => textEnum<RecurrenceType>()();
  IntColumn get intervalMonths => integer().withDefault(const Constant(0))();

  /// JSON array of day offsets; null means "use the app default".
  TextColumn get reminderOffsets =>
      text().map(const OffsetListConverter()).nullable()();

  /// Minutes after midnight; null means "use the app default".
  IntColumn get reminderMinuteOfDay => integer().nullable()();

  TextColumn get notes => text().nullable()();
  TextColumn get paymentUrl => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// "Ingatkan besok": one extra reminder at this instant. Added in v2.
  DateTimeColumn get snoozedUntil => dateTime().nullable()();

  /// ISO 4217 code of the bill's own currency. Added in v4.
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('IDR'))();

  /// Price in the currency's minor units; null for rupiah bills. Added in v4.
  IntColumn get originalAmountMinor => integer().nullable()();

  /// Index into the wallet-card colours; null follows the category.
  /// Added in v5.
  IntColumn get cardColor => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One recorded payment of one bill period. Added in v2.
@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get billId => text().references(Bills, #id)();

  /// The due date of the period that was paid.
  TextColumn get dueDate => text().map(const LocalDateConverter())();
  DateTimeColumn get paidAt => dateTime()();

  /// Whole rupiah, copied from the bill at payment time.
  IntColumn get amount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Untyped key/value store for app settings. Typed access lives in
/// `SettingsRepository`.
@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Last downloaded exchange rates, as rupiah per unit. Added in v4.
@DataClassName('ExchangeRateRow')
class CachedRates extends Table {
  TextColumn get currency => text()();
  RealColumn get idrPerUnit => real()();

  /// Publication date of the rate (yyyy-MM-dd).
  TextColumn get rateDate => text().map(const LocalDateConverter())();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {currency};
}

/// Opt-in "Tambahkan ke Kalender" link between a bill and the system
/// calendar event for its current due date. Device-specific, so it is not
/// part of backups. Added in v3.
@DataClassName('CalendarLinkRow')
class CalendarLinks extends Table {
  TextColumn get billId => text().references(Bills, #id)();
  TextColumn get calendarId => text()();
  TextColumn get eventId => text()();

  /// The due date the event was created for.
  TextColumn get dueDate => text().map(const LocalDateConverter())();

  /// Hash of the event's contents; a change means the event is stale.
  TextColumn get fingerprint => text()();

  @override
  Set<Column<Object>> get primaryKey => {billId};
}
