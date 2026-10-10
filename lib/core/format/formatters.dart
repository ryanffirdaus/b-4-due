import 'package:intl/intl.dart';

import '../../features/currency/domain/money.dart';
import '../time/local_date.dart';

/// Locale-aware formatting for money and dates.
///
/// Requires `initializeDateFormatting` for [localeName] to have run, which
/// `bootstrap()` and the test helpers take care of.
class Formatters {
  Formatters(this.localeName)
    : _currency = NumberFormat.currency(
        locale: localeName,
        symbol: 'Rp',
        decimalDigits: 0,
      ),
      _grouped = NumberFormat.decimalPattern(localeName),
      _longDate = DateFormat('d MMMM y', localeName),
      _longDateWithDay = DateFormat('EEEE, d MMMM y', localeName),
      _shortDate = DateFormat('d MMM', localeName),
      _monthYear = DateFormat('MMMM y', localeName),
      _shortMonth = DateFormat('MMM', localeName);

  /// Shared instance per locale; the intl formatters are costly to build.
  factory Formatters.cached(String localeName) =>
      _cache.putIfAbsent(localeName, () => Formatters(localeName));

  static final _cache = <String, Formatters>{};

  final String localeName;
  final NumberFormat _currency;
  final NumberFormat _grouped;
  final DateFormat _longDate;
  final DateFormat _longDateWithDay;
  final DateFormat _shortDate;
  final DateFormat _monthYear;
  final DateFormat _shortMonth;

  /// `Rp 1.250.000`. The space between symbol and number is normalised so it
  /// does not depend on the CLDR pattern of the current locale.
  String rupiah(int amount) {
    final formatted = _currency.format(amount).replaceAll(' ', ' ');
    final digitsStart = formatted.indexOf(RegExp(r'[\d-]'));
    if (digitsStart <= 0) return formatted;
    return 'Rp ${formatted.substring(digitsStart).trim()}';
  }

  /// `US$20,00`, `¥1.500`, `Rp 1.250.000` for any supported currency.
  String money(Currency currency, int minorUnits) {
    if (currency == idr) return rupiah(minorUnits);
    // Our own unambiguous symbol: the locale's simpleCurrency prints a bare
    // "$" for USD, which Indonesians could read as SGD or AUD.
    final number = plainAmount(currency, minorUnits);
    return '${currency.symbol ?? '${currency.code} '}$number';
  }

  /// Text for an amount typed in [currency] (`20`, `19,99`) without symbol.
  String plainAmount(Currency currency, int minorUnits) =>
      NumberFormat.decimalPatternDigits(
        locale: localeName,
        decimalDigits: currency.decimals,
      ).format(minorUnits / currency.minorPerUnit);

  /// A bill's price as shown everywhere: `Rp 150.000`, or for a foreign
  /// bill `US$20,00 ≈ Rp 357.611` (`US$20,00` until a rate is known).
  /// [estimateLabel] wraps a rupiah estimate the user marked as such.
  String? price({
    required Currency currency,
    required int? rupiah,
    required int? originalMinor,
    required bool isEstimate,
    required String Function(String amount) estimateLabel,
  }) {
    if (currency != idr && originalMinor != null) {
      final foreign = money(currency, originalMinor);
      return rupiah == null ? foreign : '$foreign ≈ ${this.rupiah(rupiah)}';
    }
    if (rupiah == null) return null;
    return isEstimate
        ? estimateLabel(this.rupiah(rupiah))
        : this.rupiah(rupiah);
  }

  /// `1.250.000`, used inside the amount text field.
  String groupedNumber(int value) => _grouped.format(value);

  /// `17 Agustus 2026`
  String longDate(LocalDate date) => _longDate.format(date.toUtcDateTime());

  /// `Senin, 17 Agustus 2026`
  String longDateWithDay(LocalDate date) =>
      _longDateWithDay.format(date.toUtcDateTime());

  /// `17 Agu`
  String shortDate(LocalDate date) => _shortDate.format(date.toUtcDateTime());

  /// `Agu`
  String shortMonth(LocalDate date) => _shortMonth.format(date.toUtcDateTime());

  /// `Agustus 2026`
  String monthYear(LocalDate date) => _monthYear.format(date.toUtcDateTime());

  /// `09.00` in Indonesian, `09:00` in English.
  String timeOfDay(int minuteOfDay) {
    final hours = (minuteOfDay ~/ 60).toString().padLeft(2, '0');
    final minutes = (minuteOfDay % 60).toString().padLeft(2, '0');
    final separator = localeName.startsWith('id') ? '.' : ':';
    return '$hours$separator$minutes';
  }
}

/// Parses user-typed rupiah ("1.250.000", "Rp 50000") into an integer.
/// Returns null for empty or non-numeric input.
int? parseRupiah(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  // 15 digits is far beyond any household bill and avoids overflow.
  if (digits.length > 15) return null;
  return int.parse(digits);
}
