import 'package:b4due/core/format/formatters.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
    await initializeDateFormatting('en');
  });

  group('Indonesian', () {
    late Formatters f;
    setUp(() => f = Formatters('id'));

    test('formats rupiah with dot grouping and no decimals', () {
      expect(f.rupiah(1250000), 'Rp 1.250.000');
      expect(f.rupiah(0), 'Rp 0');
      expect(f.rupiah(999), 'Rp 999');
    });

    test('formats long dates with Indonesian month names', () {
      expect(f.longDate(LocalDate(2026, 8, 17)), '17 Agustus 2026');
      expect(f.longDate(LocalDate(2027, 1, 1)), '1 Januari 2027');
      expect(
        f.longDateWithDay(LocalDate(2026, 8, 17)),
        'Senin, 17 Agustus 2026',
      );
      expect(f.monthYear(LocalDate(2026, 3, 5)), 'Maret 2026');
    });

    test('formats time of day with a dot', () {
      expect(f.timeOfDay(9 * 60), '09.00');
      expect(f.timeOfDay(19 * 60 + 5), '19.05');
    });
  });

  test('English uses English month names', () {
    final f = Formatters('en');
    expect(f.longDate(LocalDate(2026, 8, 17)), '17 August 2026');
    expect(f.timeOfDay(9 * 60), '09:00');
  });

  group('parseRupiah', () {
    test('accepts grouped and prefixed input', () {
      expect(parseRupiah('1.250.000'), 1250000);
      expect(parseRupiah('Rp 50000'), 50000);
      expect(parseRupiah(' 7 500 '), 7500);
    });

    test('returns null for empty or absurd input', () {
      expect(parseRupiah(''), isNull);
      expect(parseRupiah('abc'), isNull);
      expect(parseRupiah('9' * 16), isNull);
    });
  });
}
