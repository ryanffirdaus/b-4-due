import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';

/// How a bill repeats. Stored by [name] in the database and in backups, so
/// renaming a value is a breaking change.
enum RecurrenceType { once, monthly, yearly, every5Years, everyNMonths }

/// A recurrence rule. Every repeating rule is expressed as "every N months",
/// which keeps the date arithmetic in one place.
@immutable
class Recurrence {
  const Recurrence._(this.type, this.intervalMonths);

  const Recurrence.once() : this._(RecurrenceType.once, 0);
  const Recurrence.monthly() : this._(RecurrenceType.monthly, 1);
  const Recurrence.yearly() : this._(RecurrenceType.yearly, 12);
  const Recurrence.every5Years() : this._(RecurrenceType.every5Years, 60);

  factory Recurrence.everyNMonths(int months) {
    if (months < 1 || months > maxCustomInterval) {
      throw ArgumentError.value(
        months,
        'months',
        'must be between 1 and $maxCustomInterval',
      );
    }
    return Recurrence._(RecurrenceType.everyNMonths, months);
  }

  /// Rebuilds a rule from its stored form. [intervalMonths] is only read for
  /// [RecurrenceType.everyNMonths].
  factory Recurrence.fromStorage(RecurrenceType type, int? intervalMonths) {
    return switch (type) {
      RecurrenceType.once => const Recurrence.once(),
      RecurrenceType.monthly => const Recurrence.monthly(),
      RecurrenceType.yearly => const Recurrence.yearly(),
      RecurrenceType.every5Years => const Recurrence.every5Years(),
      RecurrenceType.everyNMonths => Recurrence.everyNMonths(
        intervalMonths ?? 1,
      ),
    };
  }

  /// Ten years is plenty for "every N months"; longer cycles are typos.
  static const maxCustomInterval = 120;

  final RecurrenceType type;

  /// 0 for [RecurrenceType.once].
  final int intervalMonths;

  bool get repeats => type != RecurrenceType.once;

  /// The due date that follows [current], or `null` for one-off bills.
  ///
  /// [anchorDay] is the day of month the user originally picked (1-31). The
  /// result lands on that day when the month is long enough, otherwise on the
  /// month's last day: a bill anchored on the 31st goes 31 Jan, 28/29 Feb,
  /// 31 Mar, and a yearly bill anchored on 29 Feb returns to the 29th in leap
  /// years.
  LocalDate? nextDueDate(LocalDate current, {required int anchorDay}) {
    if (!repeats) return null;
    return current.addMonths(intervalMonths, preferredDay: anchorDay);
  }

  @override
  bool operator ==(Object other) =>
      other is Recurrence &&
      other.type == type &&
      other.intervalMonths == intervalMonths;

  @override
  int get hashCode => Object.hash(type, intervalMonths);

  @override
  String toString() => 'Recurrence(${type.name}, $intervalMonths)';
}
