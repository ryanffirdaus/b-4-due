import 'package:b4due/core/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDate', () {
    test('parses and formats ISO dates', () {
      final date = LocalDate.parse('2026-08-17');
      expect(date, LocalDate(2026, 8, 17));
      expect(date.toIso(), '2026-08-17');
    });

    test('rejects malformed and impossible dates', () {
      expect(() => LocalDate.parse('2026-8-17'), throwsFormatException);
      expect(() => LocalDate.parse('17-08-2026'), throwsFormatException);
      expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
      expect(() => LocalDate.parse('2025-02-29'), throwsFormatException);
      expect(() => LocalDate.parse('2026-13-01'), throwsFormatException);
    });

    test('knows leap years', () {
      expect(LocalDate.isLeapYear(2024), isTrue);
      expect(LocalDate.isLeapYear(2026), isFalse);
      expect(LocalDate.isLeapYear(1900), isFalse);
      expect(LocalDate.isLeapYear(2000), isTrue);
      expect(LocalDate.daysInMonth(2028, 2), 29);
      expect(LocalDate.daysInMonth(2026, 2), 28);
      expect(LocalDate.daysInMonth(2026, 4), 30);
    });

    test('addDays crosses month and year boundaries', () {
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      expect(LocalDate(2024, 3, 1).addDays(-1), LocalDate(2024, 2, 29));
      expect(LocalDate(2026, 1, 10).addDays(-7), LocalDate(2026, 1, 3));
    });

    test('addMonths clamps to the end of shorter months', () {
      expect(LocalDate(2026, 1, 31).addMonths(1), LocalDate(2026, 2, 28));
      expect(LocalDate(2028, 1, 31).addMonths(1), LocalDate(2028, 2, 29));
      expect(LocalDate(2026, 3, 31).addMonths(1), LocalDate(2026, 4, 30));
      expect(LocalDate(2026, 11, 15).addMonths(3), LocalDate(2027, 2, 15));
      expect(LocalDate(2026, 3, 31).addMonths(-1), LocalDate(2026, 2, 28));
    });

    test('addMonths honours a preferred day', () {
      expect(
        LocalDate(2026, 2, 28).addMonths(1, preferredDay: 31),
        LocalDate(2026, 3, 31),
      );
    });

    test('differenceInDays is signed', () {
      final a = LocalDate(2026, 8, 17);
      expect(a.differenceInDays(LocalDate(2026, 8, 10)), 7);
      expect(LocalDate(2026, 8, 10).differenceInDays(a), -7);
      expect(
        LocalDate(2025, 1, 1).differenceInDays(LocalDate(2024, 1, 1)),
        366,
      );
    });

    test('orders and compares by value', () {
      final dates = [
        LocalDate(2026, 5, 1),
        LocalDate(2025, 12, 31),
        LocalDate(2026, 1, 15),
      ]..sort();
      expect(dates.map((d) => d.toIso()), [
        '2025-12-31',
        '2026-01-15',
        '2026-05-01',
      ]);
      expect(LocalDate(2026, 1, 1) == LocalDate(2026, 1, 1), isTrue);
      expect({LocalDate(2026, 1, 1), LocalDate(2026, 1, 1)}, hasLength(1));
    });
  });
}
