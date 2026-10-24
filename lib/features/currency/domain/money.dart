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
const eur = Currency('EUR', 2, '€');

/// Every currency the European Central Bank publishes a reference rate for
/// (all 31, so any pair can be converted), ordered roughly by how often
/// people pay bills and subscriptions in them. Symbols are unambiguous:
/// currencies that share "\$" or "kr" get a prefix or their code.
///
/// IDR keeps 0 decimals (not ISO's 2): rupiah amounts were stored as whole
/// rupiah before other main currencies existed, and sen are never used.
const supportedCurrencies = <Currency>[
  idr,
  usd,
  eur,
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
  Currency('BRL', 2, 'R\$'),
  Currency('MXN', 2, 'MX\$'),
  Currency('TRY', 2, '₺'),
  Currency('ILS', 2, '₪'),
  Currency('ZAR', 2, 'ZAR '),
  Currency('SEK', 2, 'SEK '),
  Currency('NOK', 2, 'NOK '),
  Currency('DKK', 2, 'DKK '),
  Currency('ISK', 0, 'ISK '),
  Currency('PLN', 2, 'PLN '),
  Currency('CZK', 2, 'CZK '),
  Currency('HUF', 2, 'HUF '),
  Currency('RON', 2, 'RON '),
  Currency('BGN', 2, 'BGN '),
];

/// The usual currency of a country (ISO 3166 code, e.g. "US"), if it is
/// supported. Used to pick the main currency on a fresh install.
Currency? currencyForRegion(String? countryCode) {
  final code = switch (countryCode?.toUpperCase()) {
    'ID' => 'IDR',
    'US' || 'EC' || 'SV' || 'PA' || 'PR' || 'TL' => 'USD',
    'AT' ||
    'BE' ||
    'CY' ||
    'DE' ||
    'EE' ||
    'ES' ||
    'FI' ||
    'FR' ||
    'GR' ||
    'HR' ||
    'IE' ||
    'IT' ||
    'LT' ||
    'LU' ||
    'LV' ||
    'MT' ||
    'NL' ||
    'PT' ||
    'SI' ||
    'SK' ||
    'MC' ||
    'SM' ||
    'VA' ||
    'AD' ||
    'ME' ||
    'XK' => 'EUR',
    'SG' => 'SGD',
    'MY' => 'MYR',
    'JP' => 'JPY',
    'GB' => 'GBP',
    'AU' => 'AUD',
    'CN' => 'CNY',
    'HK' => 'HKD',
    'KR' => 'KRW',
    'TH' => 'THB',
    'PH' => 'PHP',
    'IN' => 'INR',
    'CA' => 'CAD',
    'CH' || 'LI' => 'CHF',
    'NZ' => 'NZD',
    'BR' => 'BRL',
    'MX' => 'MXN',
    'TR' => 'TRY',
    'IL' => 'ILS',
    'ZA' => 'ZAR',
    'SE' => 'SEK',
    'NO' => 'NOK',
    'DK' => 'DKK',
    'IS' => 'ISK',
    'PL' => 'PLN',
    'CZ' => 'CZK',
    'HU' => 'HUF',
    'RO' => 'RON',
    'BG' => 'BGN',
    _ => null,
  };
  return code == null ? null : currencyByCode(code);
}

/// Looks a currency up by code; unknown codes (e.g. from a newer backup)
/// fall back to rupiah so amounts are never misread as another currency.
Currency currencyByCode(String code) => supportedCurrencies.firstWhere(
  (c) => c.code == code.toUpperCase(),
  orElse: () => idr,
);

/// Exchange rates expressed as rupiah per one unit of each currency.
///
/// Rupiah is only the pivot of the stored table; [convert] works between
/// any two supported currencies.
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

  /// Converts [minorUnits] of [from] to minor units of [to], rounded. Null
  /// when a rate is missing for either currency.
  int? convert(int minorUnits, Currency from, Currency to) {
    if (from == to) return minorUnits;
    final fromRate = rateFor(from);
    final toRate = rateFor(to);
    if (fromRate == null || toRate == null || toRate <= 0) return null;
    final idrValue = minorUnits / from.minorPerUnit * fromRate;
    return (idrValue / toRate * to.minorPerUnit).round();
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

/// Converts amounts to the main currency for totals. Without rates, only
/// amounts already in the main currency count.
@immutable
class MoneyConverter {
  const MoneyConverter(this.main, [this.rates]);

  /// Every amount is already in rupiah (the app before main currencies).
  static const rupiahOnly = MoneyConverter(idr);

  final Currency main;
  final ExchangeRates? rates;

  int? toMain(int? minorUnits, Currency from) {
    if (minorUnits == null) return null;
    if (from == main) return minorUnits;
    return rates?.convert(minorUnits, from, main);
  }
}
