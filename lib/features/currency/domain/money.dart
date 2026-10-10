import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';

/// Currencies a bill can be priced in. Rupiah is the home currency; the
/// others are the ones the European Central Bank publishes a rate for, so
/// they can always be converted.
@immutable
class Currency {
  const Currency(this.code, this.decimals, [this.symbol]);

  /// ISO 4217 code, e.g. "USD".
  final String code;

  /// Unambiguous display symbol ("US\$", "S\$", "RM"); falls back to the
  /// code. Plain "\$" is avoided because several currencies share it.
  final String? symbol;

  /// Minor-unit digits: 2 for USD (cents), 0 for IDR and JPY.
  final int decimals;

  int get minorPerUnit => _pow10(decimals);

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

const idr = Currency('IDR', 0, 'Rp');
const usd = Currency('USD', 2, 'US\$');

/// Ordered roughly by how often Indonesians pay subscriptions in them.
const supportedCurrencies = <Currency>[
  idr,
  usd,
  Currency('EUR', 2, '€'),
  Currency('SGD', 2, 'S\$'),
  Currency('MYR', 2, 'RM'),
  Currency('JPY', 0, '¥'),
  Currency('GBP', 2, '£'),
  Currency('AUD', 2, 'A\$'),
  Currency('CNY', 2, 'CN¥'),
  Currency('HKD', 2, 'HK\$'),
  Currency('KRW', 0, '₩'),
  Currency('THB', 2, '฿'),
  Currency('PHP', 2, '₱'),
  Currency('INR', 2, '₹'),
  Currency('CAD', 2, 'C\$'),
  Currency('CHF', 2, 'CHF '),
  Currency('NZD', 2, 'NZ\$'),
];

/// Looks a currency up by code; unknown codes (e.g. from a newer backup)
/// fall back to rupiah so amounts are never misread as another currency.
Currency currencyByCode(String code) => supportedCurrencies.firstWhere(
  (c) => c.code == code.toUpperCase(),
  orElse: () => idr,
);

/// Exchange rates expressed as rupiah per one unit of each currency.
@immutable
class ExchangeRates {
  const ExchangeRates({
    required this.idrPerUnit,
    required this.rateDate,
    required this.fetchedAt,
  });

  /// e.g. {"USD": 17880.55, "EUR": 20036.94}. Never contains IDR.
  final Map<String, double> idrPerUnit;

  /// The publication date of the rates (ECB working day).
  final LocalDate rateDate;

  /// When this device last downloaded them.
  final DateTime fetchedAt;

  bool get isEmpty => idrPerUnit.isEmpty;

  double? rateFor(Currency currency) =>
      currency == idr ? 1 : idrPerUnit[currency.code];

  /// Converts [minorUnits] of [currency] to whole rupiah, rounded to the
  /// nearest rupiah. Null when no rate is known for the currency.
  int? toIdr(Currency currency, int minorUnits) {
    if (currency == idr) return minorUnits;
    final rate = rateFor(currency);
    if (rate == null) return null;
    return (minorUnits / currency.minorPerUnit * rate).round();
  }

  bool isStale(DateTime now, {Duration maxAge = const Duration(hours: 12)}) =>
      now.difference(fetchedAt) > maxAge;
}

/// Parses an amount typed by the user in [currency]: "20", "19,99",
/// "19.99", "1.234,50" or "1,234.50". Returns minor units, or null for
/// empty or invalid input.
int? parseForeignAmount(String input, Currency currency) {
  var text = input.replaceAll(RegExp(r'[^0-9.,]'), '');
  if (text.isEmpty) return null;
  // The last separator followed by 1-2 digits is the decimal mark; every
  // other separator groups thousands.
  final match = RegExp(r'[.,](\d{1,2})$').firstMatch(text);
  var fraction = '';
  if (match != null) {
    fraction = match.group(1)!;
    text = text.substring(0, match.start);
  }
  final whole = text.replaceAll(RegExp('[.,]'), '');
  if (whole.isEmpty && fraction.isEmpty) return null;
  if (whole.length > 12) return null;
  final units = whole.isEmpty ? 0 : int.parse(whole);
  // Currencies without minor units (IDR, JPY, KRW) drop any fraction.
  final minor = currency.decimals == 0
      ? 0
      : int.parse(fraction.padRight(currency.decimals, '0'));
  return units * currency.minorPerUnit + minor;
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
