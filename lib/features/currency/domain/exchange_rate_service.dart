import 'dart:convert';

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill.dart';
import '../../bills/domain/bill_repository.dart';
import '../../bills/domain/bill_service.dart';
import 'money.dart';

/// Where fresh rates come from (the network, or a fake in tests).
abstract interface class ExchangeRateSource {
  Future<ExchangeRates> fetchLatest();
}

/// The last downloaded rates, kept on the device for offline use.
abstract interface class ExchangeRateStore {
  Future<ExchangeRates?> load();
  Stream<ExchangeRates?> watch();
  Future<void> save(ExchangeRates rates);
}

class ExchangeRateFormatException implements Exception {
  const ExchangeRateFormatException(this.message);
  final String message;

  @override
  String toString() => 'ExchangeRateFormatException: $message';
}

/// Parses a Frankfurter (ECB) `latest` response with the default EUR base,
/// e.g. `{"base":"EUR","date":"2026-10-09","rates":{"IDR":20036.9,...}}`,
/// into rupiah-per-unit cross rates for the supported currencies.
///
/// EUR is used as the base on purpose: asking for an IDR base returns
/// values rounded to five decimals (1 IDR = 0.000056 USD), which loses
/// about 5% of precision.
ExchangeRates parseFrankfurterRates(String body, {required DateTime now}) {
  final Object? json;
  try {
    json = jsonDecode(body);
  } on FormatException catch (e) {
    throw ExchangeRateFormatException('not JSON: ${e.message}');
  }
  if (json is! Map<String, dynamic>) {
    throw const ExchangeRateFormatException('not an object');
  }
  final base = json['base'];
  final rates = json['rates'];
  final date = json['date'];
  if (base is! String || rates is! Map<String, dynamic> || date is! String) {
    throw const ExchangeRateFormatException('missing base/rates/date');
  }
  num? perBase(String code) => code == base ? 1 : rates[code] as num?;
  final idrPerBase = perBase('IDR');
  if (idrPerBase == null || idrPerBase <= 0) {
    throw const ExchangeRateFormatException('no IDR rate');
  }
  final result = <String, double>{};
  for (final currency in supportedCurrencies) {
    if (currency == idr) continue;
    final unitsPerBase = perBase(currency.code);
    if (unitsPerBase == null || unitsPerBase <= 0) continue;
    result[currency.code] = idrPerBase / unitsPerBase;
  }
  final LocalDate rateDate;
  try {
    rateDate = LocalDate.parse(date);
  } on FormatException {
    throw ExchangeRateFormatException('bad date: $date');
  }
  return ExchangeRates(idrPerUnit: result, rateDate: rateDate, fetchedAt: now);
}

enum RefreshOutcome { refreshed, upToDate, failed }

/// Keeps cached rates fresh and the rupiah estimate of foreign-currency
/// bills in step with them.
///
/// Only the rates are fetched: a single anonymous GET with no user data.
/// Every failure is non-fatal; the app keeps using the last cached rates.
class ExchangeRateService {
  ExchangeRateService({
    required this._source,
    required this._store,
    required this._bills,
    required this._clock,
    required this._onChanged,
  });

  /// Rates older than this are refreshed on the next opportunity.
  static const maxAge = Duration(hours: 12);

  final ExchangeRateSource _source;
  final ExchangeRateStore _store;
  final BillRepository _bills;
  final DateTime Function() _clock;
  final OnBillsChanged _onChanged;

  Future<ExchangeRates?> cached() => _store.load();

  /// Downloads rates when the cache is missing or older than [maxAge] (or
  /// always with [force]), then reprices foreign-currency bills.
  Future<RefreshOutcome> refreshIfStale({bool force = false}) async {
    final now = _clock().toUtc();
    final current = await _store.load();
    if (!force && current != null && !current.isStale(now, maxAge: maxAge)) {
      return RefreshOutcome.upToDate;
    }
    final ExchangeRates fresh;
    try {
      fresh = await _source.fetchLatest();
    } on Object {
      return RefreshOutcome.failed;
    }
    await _store.save(fresh);
    if (await repriceBills(fresh) > 0) await _onChanged();
    return RefreshOutcome.refreshed;
  }

  /// Recomputes the rupiah amount of every active foreign-currency bill.
  /// Returns how many bills changed.
  Future<int> repriceBills(ExchangeRates rates) async {
    var changed = 0;
    for (final bill in await _bills.getActive()) {
      final updated = repriced(bill, rates);
      if (updated != null) {
        await _bills.save(updated.copyWith(updatedAt: _clock().toUtc()));
        changed++;
      }
    }
    return changed;
  }
}

/// The bill with its rupiah estimate updated for [rates], or null when
/// nothing changes (rupiah bills, unknown rate, same amount).
Bill? repriced(Bill bill, ExchangeRates rates) {
  final original = bill.originalAmountMinor;
  if (bill.currency == idr || original == null) return null;
  final amount = rates.toIdr(bill.currency, original);
  if (amount == null || amount == bill.amount) return null;
  return bill.copyWith(amount: () => amount, amountIsEstimate: true);
}
