import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/format/formatters.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/currency/data/exchange_rate_data.dart';
import 'package:b4due/features/currency/domain/exchange_rate_service.dart';
import 'package:b4due/features/currency/domain/money.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../support/fixtures.dart';

final jpy = currencyByCode('JPY');

/// Shape of a real Frankfurter response (EUR base), trimmed.
const _frankfurterBody = '''
{"amount":1.0,"base":"EUR","date":"2026-10-09",
 "rates":{"IDR":20036.94,"USD":1.1206,"JPY":177.33,"SGD":1.4348,"BRL":6.1}}
''';

class FakeSource implements ExchangeRateSource {
  FakeSource(this.result);
  ExchangeRates? result;
  var calls = 0;

  @override
  Future<ExchangeRates> fetchLatest() async {
    calls++;
    final r = result;
    if (r == null) throw Exception('offline');
    return r;
  }
}

ExchangeRates rates({double usdRate = 17880.55, DateTime? fetchedAt}) =>
    ExchangeRates(
      idrPerUnit: {'USD': usdRate, 'JPY': 112.99},
      rateDate: LocalDate(2026, 10, 9),
      fetchedAt: fetchedAt ?? DateTime.utc(2026, 10, 10, 1),
    );

void main() {
  group('parseForeignAmount', () {
    test('accepts the ways people type prices', () {
      expect(parseForeignAmount('20', usd), 2000);
      expect(parseForeignAmount('19,99', usd), 1999);
      expect(parseForeignAmount('19.99', usd), 1999);
      expect(parseForeignAmount('19,9', usd), 1990);
      expect(parseForeignAmount('1.234,50', usd), 123450);
      expect(parseForeignAmount('1,234.50', usd), 123450);
      expect(parseForeignAmount('\$ 20', usd), 2000);
    });

    test('currencies without minor units ignore fractions', () {
      expect(parseForeignAmount('1.500', jpy), 1500);
      expect(parseForeignAmount('1500', jpy), 1500);
      expect(parseForeignAmount('19,99', jpy), 19);
    });

    test('rejects empty and absurd input', () {
      expect(parseForeignAmount('', usd), isNull);
      expect(parseForeignAmount('abc', usd), isNull);
      expect(parseForeignAmount('9' * 13, usd), isNull);
    });
  });

  group('ExchangeRates', () {
    test('converts minor units to whole rupiah, rounding', () {
      final r = rates();
      expect(r.toIdr(usd, 2000), 357611); // 20 × 17,880.55
      expect(r.toIdr(jpy, 1500), 169485);
      expect(r.toIdr(idr, 150000), 150000);
      expect(r.toIdr(const Currency('SGD', 2), 100), isNull);
    });

    test('is stale after 12 hours', () {
      final r = rates(fetchedAt: DateTime.utc(2026, 10, 10, 1));
      expect(r.isStale(DateTime.utc(2026, 10, 10, 12)), isFalse);
      expect(r.isStale(DateTime.utc(2026, 10, 10, 14)), isTrue);
    });
  });

  group('parseFrankfurterRates', () {
    test('derives rupiah cross rates from the EUR base', () {
      final r = parseFrankfurterRates(
        _frankfurterBody,
        now: DateTime.utc(2026, 10, 10),
      );
      expect(r.rateDate, LocalDate(2026, 10, 9));
      expect(r.idrPerUnit['EUR'], 20036.94);
      expect(r.idrPerUnit['USD'], closeTo(17880.55, 0.01));
      expect(r.idrPerUnit['JPY'], closeTo(112.99, 0.01));
      // Unsupported currencies are ignored; rupiah is never a key.
      expect(r.idrPerUnit.containsKey('BRL'), isFalse);
      expect(r.idrPerUnit.containsKey('IDR'), isFalse);
    });

    test('rejects malformed responses', () {
      for (final body in [
        'not json',
        '[]',
        '{"base":"EUR","date":"2026-10-09","rates":{"USD":1.1}}',
        '{"base":"EUR","date":"oops","rates":{"IDR":20000}}',
      ]) {
        expect(
          () => parseFrankfurterRates(body, now: DateTime.utc(2026)),
          throwsA(isA<ExchangeRateFormatException>()),
          reason: body,
        );
      }
    });
  });

  group('ExchangeRateService', () {
    late AppDatabase db;
    late DriftBillRepository bills;
    late DriftExchangeRateStore store;
    late FakeSource source;
    late ExchangeRateService service;
    late int changes;
    var now = DateTime.utc(2026, 10, 10, 2);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      bills = DriftBillRepository(db);
      store = DriftExchangeRateStore(db);
      source = FakeSource(rates());
      changes = 0;
      now = DateTime.utc(2026, 10, 10, 2);
      service = ExchangeRateService(
        source: source,
        store: store,
        bills: bills,
        clock: () => now,
        onChanged: () async => changes++,
      );
    });

    tearDown(() => db.close());

    Future<void> saveClaude({int? amount}) => bills.save(
      testBill(
        'claude',
        due: LocalDate(2026, 10, 20),
        amount: amount,
      ).copyWith(currency: usd, originalAmountMinor: () => 2000),
    );

    test(
      'first refresh downloads, caches and reprices foreign bills',
      () async {
        await saveClaude();
        await bills.save(
          testBill('pln', due: LocalDate(2026, 10, 20), amount: 1),
        );

        expect(await service.refreshIfStale(), RefreshOutcome.refreshed);

        expect((await store.load())!.idrPerUnit['USD'], 17880.55);
        final claude = (await bills.findById('claude'))!;
        expect(claude.amount, 357611);
        expect(claude.amountIsEstimate, isTrue);
        expect((await bills.findById('pln'))!.amount, 1);
        expect(changes, 1);
      },
    );

    test('fresh cache is not refetched; stale cache is', () async {
      await service.refreshIfStale();
      expect(await service.refreshIfStale(), RefreshOutcome.upToDate);
      expect(source.calls, 1);

      now = now.add(const Duration(hours: 13));
      source.result = rates(usdRate: 18000, fetchedAt: now);
      await saveClaude(amount: 357611);
      expect(await service.refreshIfStale(), RefreshOutcome.refreshed);
      expect((await bills.findById('claude'))!.amount, 360000);
    });

    test('offline keeps the last cached rates and changes nothing', () async {
      await service.refreshIfStale();
      source.result = null;
      now = now.add(const Duration(days: 2));

      expect(await service.refreshIfStale(), RefreshOutcome.failed);
      expect((await store.load())!.idrPerUnit['USD'], 17880.55);
      expect(changes, 0);
    });
  });

  group('price label', () {
    setUpAll(() => initializeDateFormatting('id'));

    test('foreign bills show the original price and the rupiah estimate', () {
      final f = Formatters('id');
      String est(String a) => '$a (perkiraan)';
      expect(
        f.price(
          currency: usd,
          rupiah: 357611,
          originalMinor: 2000,
          isEstimate: true,
          estimateLabel: est,
        ),
        'US\$20,00 ≈ Rp 357.611',
      );
      expect(
        f.price(
          currency: usd,
          rupiah: null,
          originalMinor: 2000,
          isEstimate: true,
          estimateLabel: est,
        ),
        'US\$20,00',
      );
      expect(
        f.price(
          currency: idr,
          rupiah: 150000,
          originalMinor: null,
          isEstimate: true,
          estimateLabel: est,
        ),
        'Rp 150.000 (perkiraan)',
      );
    });
  });
}
