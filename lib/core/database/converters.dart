import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/bills/domain/bill_category.dart';
import '../time/local_date.dart';

/// Stores [LocalDate] as `yyyy-MM-dd`, which sorts correctly as text.
class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIso();
}

/// Stores [BillCategory] by name and tolerates unknown names (for example a
/// backup made by a newer app version) by mapping them to "other".
class BillCategoryConverter extends TypeConverter<BillCategory, String> {
  const BillCategoryConverter();

  @override
  BillCategory fromSql(String fromDb) => BillCategory.fromName(fromDb);

  @override
  String toSql(BillCategory value) => value.name;
}

/// Stores a list of reminder offsets (days) as a JSON array.
class OffsetListConverter extends TypeConverter<List<int>, String> {
  const OffsetListConverter();

  @override
  List<int> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<int>();

  @override
  String toSql(List<int> value) => jsonEncode(value);
}
