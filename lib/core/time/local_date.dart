import 'package:meta/meta.dart';

/// A calendar date without time or timezone ("civil date").
///
/// Due dates are civil dates: a bill due on 17 August is due on 17 August
/// regardless of the device timezone. Storing them as `DateTime` invites
/// off-by-one bugs around midnight, so we keep them separate and only combine
/// them with a time of day and a timezone when scheduling notifications.
@immutable
class LocalDate implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day)
    : assert(month >= 1 && month <= 12),
      assert(day >= 1 && day <= daysInMonth(year, month));

  /// Takes only the Y/M/D fields of [dateTime], in whatever zone it is in.
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `yyyy-MM-dd`. Throws [FormatException] on anything else.
  factory LocalDate.parse(String input) {
    final match = _isoPattern.firstMatch(input);
    if (match == null) {
      throw FormatException('Expected yyyy-MM-dd', input);
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) {
      throw FormatException('Invalid calendar date', input);
    }
    return LocalDate(year, month, day);
  }

  static final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static int daysInMonth(int year, int month) {
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) return 29;
    return days[month - 1];
  }

  /// Adds [days] calendar days. Uses UTC internally so DST never interferes.
  LocalDate addDays(int days) {
    final utc = DateTime.utc(year, month, day).add(Duration(days: days));
    return LocalDate(utc.year, utc.month, utc.day);
  }

  /// Moves [months] months forward (or backward) and places the result on
  /// [preferredDay], clamped to the length of the target month.
  ///
  /// `preferredDay` defaults to this date's day. Passing the bill's original
  /// "anchor" day keeps a bill due on the 31st from drifting to the 28th
  /// forever after February.
  LocalDate addMonths(int months, {int? preferredDay}) {
    final monthIndex = year * 12 + (month - 1) + months;
    final targetYear = monthIndex ~/ 12;
    final targetMonth = monthIndex % 12 + 1;
    final wantedDay = preferredDay ?? day;
    final clampedDay = wantedDay.clamp(1, daysInMonth(targetYear, targetMonth));
    return LocalDate(targetYear, targetMonth, clampedDay);
  }

  /// Number of days from [other] to this date (positive if this is later).
  int differenceInDays(LocalDate other) => DateTime.utc(
    year,
    month,
    day,
  ).difference(DateTime.utc(other.year, other.month, other.day)).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  /// Midnight of this date as a UTC [DateTime]. Useful as a sortable key.
  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  /// `yyyy-MM-dd`; the storage and interchange format.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
