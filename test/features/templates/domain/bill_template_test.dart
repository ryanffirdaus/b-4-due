import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:b4due/features/templates/domain/bill_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BillTemplate byKey(String key) =>
      billTemplates.firstWhere((t) => t.key == key);

  test('template keys are unique', () {
    final keys = billTemplates.map((t) => t.key).toList();
    expect(keys.toSet(), hasLength(keys.length));
  });

  test('covers the common Indonesian bills', () {
    for (final key in [
      'pln',
      'pdam',
      'bpjs_kesehatan',
      'pkb',
      'stnk_5y',
      'netflix',
    ]) {
      expect(billTemplates.any((t) => t.key == key), isTrue, reason: key);
    }
    expect(byKey('stnk_5y').recurrence, const Recurrence.every5Years());
    expect(byKey('pkb').recurrence, const Recurrence.yearly());
  });

  group('suggestedDueDate', () {
    test('uses the typical day later this month', () {
      expect(
        byKey('bpjs_kesehatan').suggestedDueDate(LocalDate(2026, 8, 3)),
        LocalDate(2026, 8, 10),
      );
    });

    test('rolls to next month once the typical day has passed', () {
      expect(
        byKey('pln').suggestedDueDate(LocalDate(2026, 12, 21)),
        LocalDate(2027, 1, 20),
      );
    });

    test('keeps today when today is the typical day', () {
      expect(
        byKey('pln').suggestedDueDate(LocalDate(2026, 8, 20)),
        LocalDate(2026, 8, 20),
      );
    });

    test('falls back to a week from today', () {
      expect(
        byKey('netflix').suggestedDueDate(LocalDate(2026, 8, 28)),
        LocalDate(2026, 9, 4),
      );
    });
  });
}
