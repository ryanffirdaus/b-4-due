import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/bill.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';

final fixtureCreatedAt = DateTime.utc(2026, 1, 1);

/// A bill with sensible defaults; override only what a test cares about.
Bill testBill(
  String id, {
  required LocalDate due,
  String? name,
  BillCategory category = BillCategory.electricity,
  Recurrence recurrence = const Recurrence.monthly(),
  int? anchorDay,
  int? amount,
  List<int>? reminderOffsets,
  int? reminderMinuteOfDay,
  DateTime? deletedAt,
  DateTime? archivedAt,
}) => Bill(
  id: id,
  name: name ?? 'Bill $id',
  category: category,
  dueDate: due,
  anchorDay: anchorDay ?? due.day,
  recurrence: recurrence,
  amount: amount,
  reminderOffsets: reminderOffsets,
  reminderMinuteOfDay: reminderMinuteOfDay,
  createdAt: fixtureCreatedAt,
  updatedAt: fixtureCreatedAt,
  deletedAt: deletedAt,
  archivedAt: archivedAt,
);
