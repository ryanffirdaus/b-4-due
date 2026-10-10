import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

/// Walks [count] due dates forward from [start], like a user paying on time.
List<String> _chain(
  Recurrence rule,
  LocalDate start, {
  required int count,
  int? anchorDay,
}) {
  final result = <String>[];
  var current = start;
  for (var i = 0; i < count; i++) {
    current = rule.nextDueDate(current, anchorDay: anchorDay ?? start.day)!;
    result.add(current.toIso());
  }
  return result;
}

void main() {
  group('Recurrence.nextDueDate', () {
    test('one-off bills have no next due date', () {
      expect(
        const Recurrence.once().nextDueDate(
          LocalDate(2026, 8, 17),
          anchorDay: 17,
        ),
        isNull,
      );
    });

    test('monthly on the 31st returns to the 31st after short months', () {
      expect(
        _chain(const Recurrence.monthly(), LocalDate(2026, 1, 31), count: 4),
        ['2026-02-28', '2026-03-31', '2026-04-30', '2026-05-31'],
      );
    });

    test('monthly on the 30th and 29th through February', () {
      expect(
        _chain(const Recurrence.monthly(), LocalDate(2026, 1, 30), count: 2),
        ['2026-02-28', '2026-03-30'],
      );
      expect(
        _chain(const Recurrence.monthly(), LocalDate(2026, 1, 29), count: 2),
        ['2026-02-28', '2026-03-29'],
      );
      expect(
        _chain(const Recurrence.monthly(), LocalDate(2028, 1, 29), count: 2),
        ['2028-02-29', '2028-03-29'],
      );
    });

    test('monthly crosses the year boundary', () {
      expect(
        _chain(const Recurrence.monthly(), LocalDate(2026, 11, 20), count: 3),
        ['2026-12-20', '2027-01-20', '2027-02-20'],
      );
    });

    test('yearly on 29 February falls back in common years only', () {
      expect(
        _chain(const Recurrence.yearly(), LocalDate(2024, 2, 29), count: 4),
        ['2025-02-28', '2026-02-28', '2027-02-28', '2028-02-29'],
      );
    });

    test('every 5 years (STNK renewal)', () {
      expect(
        _chain(
          const Recurrence.every5Years(),
          LocalDate(2026, 8, 17),
          count: 2,
        ),
        ['2031-08-17', '2036-08-17'],
      );
      expect(
        _chain(
          const Recurrence.every5Years(),
          LocalDate(2028, 2, 29),
          count: 2,
        ),
        ['2033-02-28', '2038-02-28'],
      );
    });

    test('every N months', () {
      expect(
        _chain(Recurrence.everyNMonths(3), LocalDate(2026, 11, 30), count: 3),
        ['2027-02-28', '2027-05-30', '2027-08-30'],
      );
      expect(
        _chain(Recurrence.everyNMonths(6), LocalDate(2026, 8, 31), count: 2),
        ['2027-02-28', '2027-08-31'],
      );
    });

    test('an explicit anchor day wins over the current day', () {
      // The stored due date was clamped to the 28th, but the user chose 31.
      expect(
        const Recurrence.monthly().nextDueDate(
          LocalDate(2026, 2, 28),
          anchorDay: 31,
        ),
        LocalDate(2026, 3, 31),
      );
    });

    test('everyNMonths validates its interval', () {
      expect(() => Recurrence.everyNMonths(0), throwsArgumentError);
      expect(() => Recurrence.everyNMonths(121), throwsArgumentError);
    });

    test('fromStorage round-trips every type', () {
      final rules = [
        const Recurrence.once(),
        const Recurrence.monthly(),
        const Recurrence.yearly(),
        const Recurrence.every5Years(),
        Recurrence.everyNMonths(4),
      ];
      for (final rule in rules) {
        expect(Recurrence.fromStorage(rule.type, rule.intervalMonths), rule);
      }
    });
  });
}
