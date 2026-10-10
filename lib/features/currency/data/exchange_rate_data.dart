import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../core/database/app_database.dart';
import '../../bills/data/drift_bill_repository.dart';
import '../../bills/domain/bill_service.dart';
import '../domain/exchange_rate_service.dart';
import '../domain/money.dart';

/// Daily reference rates of the European Central Bank, served by the open
/// source Frankfurter API. The request carries no user data: no IDs, no
/// amounts, no currencies of the user's bills.
class FrankfurterRateSource implements ExchangeRateSource {
  FrankfurterRateSource({HttpClient? client, DateTime Function()? clock})
    : _client = client ?? HttpClient(),
      _clock = clock ?? DateTime.now;

  static final endpoint = Uri.https('api.frankfurter.dev', '/v1/latest');
  static const _timeout = Duration(seconds: 10);
  static const _maxBytes = 64 * 1024;

  final HttpClient _client;
  final DateTime Function() _clock;

  @override
  Future<ExchangeRates> fetchLatest() async {
    _client
      ..connectionTimeout = _timeout
      ..userAgent = 'B4Due';
    final request = await _client.getUrl(endpoint).timeout(_timeout);
    request.followRedirects = false;
    final response = await request.close().timeout(_timeout);
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('HTTP ${response.statusCode}', uri: endpoint);
    }
    final bytes = <int>[];
    await for (final chunk in response.timeout(_timeout)) {
      bytes.addAll(chunk);
      if (bytes.length > _maxBytes) {
        throw const HttpException('response too large');
      }
    }
    return parseFrankfurterRates(utf8.decode(bytes), now: _clock().toUtc());
  }
}

/// Rates cached in the `cached_rates` table.
class DriftExchangeRateStore implements ExchangeRateStore {
  DriftExchangeRateStore(this._db);

  final AppDatabase _db;

  @override
  Future<ExchangeRates?> load() async =>
      _fromRows(await _db.select(_db.cachedRates).get());

  @override
  Stream<ExchangeRates?> watch() =>
      _db.select(_db.cachedRates).watch().map(_fromRows);

  @override
  Future<void> save(ExchangeRates rates) => _db.writeTransaction(() async {
    await _db.delete(_db.cachedRates).go();
    await _db.batch((batch) {
      batch.insertAll(_db.cachedRates, [
        for (final e in rates.idrPerUnit.entries)
          CachedRatesCompanion.insert(
            currency: e.key,
            idrPerUnit: e.value,
            rateDate: rates.rateDate,
            fetchedAt: rates.fetchedAt,
          ),
      ]);
    });
  });

  static ExchangeRates? _fromRows(List<ExchangeRateRow> rows) {
    if (rows.isEmpty) return null;
    return ExchangeRates(
      idrPerUnit: {for (final r in rows) r.currency: r.idrPerUnit},
      rateDate: rows.first.rateDate,
      fetchedAt: rows.first.fetchedAt,
    );
  }
}

/// The rate service wired to the real database and network, for isolates
/// without Riverpod (start-up, background sync).
ExchangeRateService buildExchangeRateService(
  AppDatabase db, {
  required OnBillsChanged onChanged,
}) => ExchangeRateService(
  source: FrankfurterRateSource(),
  store: DriftExchangeRateStore(db),
  bills: DriftBillRepository(db),
  clock: DateTime.now,
  onChanged: onChanged,
);
