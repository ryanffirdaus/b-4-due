import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/format/formatters.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/currency/domain/exchange_rate_service.dart';
import 'package:b4due/features/currency/domain/main_currency_service.dart';
import 'package:b4due/features/currency/domain/money.dart';
import 'package:b4due/features/home/domain/home_summary.dart';
import 'package:b4due/features/payments/data/drift_payment_repository.dart';
import 'package:b4due/features/payments/domain/pay_bill.dart';
import 'package:b4due/features/payments/domain/payment.dart';
import 'package:b4due/features/settings/data/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../support/fixtures.dart';

/// 1 USD = Rp 17.880,55, 1 EUR = Rp 20.036,94, 1 JPY = Rp 112,99.
final _rates = ExchangeRates(
  idrPerUnit: const {'USD': 17880.55, 'EUR': 20036.94, 'JPY': 112.99},
  rateDate: LocalDate(2026, 10, 9),
  fetchedAt: DateTime.utc(2026, 10, 10),
);

final _eur = currencyByCode('EUR');
final _jpy = currencyByCode('JPY');

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
    await initializeDateFormatting('en');
  });

  group('supported currencies', () {
    test('are the 31 ECB currencies, each once', () {
      final codes = supportedCurrencies.map((c) => c.code).toSet();
      expect(codes, hasLength(31));
      expect(codes, containsAll(['IDR', 'USD', 'EUR', 'BRL', 'ZAR', 'ISK']));
      expect(supportedCurrencies.first, idr);
    });

    test('a fresh install picks the currency of the phone region', () {
      expect(currencyForRegion('US'), usd);
      expect(currencyForRegion('de'), _eur);
      expect(currencyForRegion('ID'), idr);
      expect(currencyForRegion('JP'), _jpy);
      expect(currencyForRegion('AR'), isNull);
      expect(currencyForRegion(null), isNull);
    });
  });

  group('ExchangeRates.convert', () {
    test('converts between any two currencies through the rupiah table', () {
      // US$20.00 -> Rp 357.611
      expect(_rates.convert(2000, usd, idr), 357611);
      // Rp 357.611 -> US$20.00
      expect(_rates.convert(357611, idr, usd), 2000);
      // €10.00 -> US$11.21 (20036.94 / 17880.55 * 10)
      expect(_rates.convert(1000, _eur, usd), 1121);
      // ¥1.000 (no minor units) -> US$6.32
      expect(_rates.convert(1000, _jpy, usd), 632);
      expect(_rates.convert(500, usd, usd), 500);
    });

    test('is null when a rate is missing', () {
      expect(_rates.convert(100, currencyByCode('BRL'), usd), isNull);
    });
  });

  group('rebasedBill', () {
    final pln = testBill('pln', due: LocalDate(2026, 10, 20), amount: 487500);
    final claude = testBill(
      'claude',
      due: LocalDate(2026, 10, 12),
      amount: 357611,
    ).copyWith(currency: usd, originalAmountMinor: () => 2000);

    test('a rupiah bill keeps its price and gets a dollar estimate', () {
      final rebased = rebasedBill(pln, from: idr, to: usd, rates: _rates);
      expect(rebased.currency, idr);
      expect(rebased.originalAmountMinor, 487500);
      expect(rebased.amount, 2726); // US$27.26
      expect(rebased.isForeign, isTrue);
    });

    test('a dollar bill becomes a plain bill in dollars', () {
      final rebased = rebasedBill(claude, from: idr, to: usd, rates: _rates);
      expect(rebased.currency, usd);
      expect(rebased.originalAmountMinor, isNull);
      expect(rebased.amount, 2000);
      expect(rebased.isForeign, isFalse);
    });

    test('a round trip gives back the exact prices', () {
      final there = rebasedBill(pln, from: idr, to: usd, rates: _rates);
      final back = rebasedBill(there, from: usd, to: idr, rates: _rates);
      expect(back.amount, 487500);
      expect(back.originalAmountMinor, isNull);
    });

    test('an unknown amount stays unknown', () {
      final unknown = testBill('pkb', due: LocalDate(2026, 11, 2));
      final rebased = rebasedBill(unknown, from: idr, to: usd, rates: _rates);
      expect(rebased.amount, isNull);
      expect(rebased.originalAmountMinor, isNull);
    });

    test('without rates the estimate waits for them', () {
      final rebased = rebasedBill(pln, from: idr, to: usd);
      expect(rebased.originalAmountMinor, 487500);
      expect(rebased.amount, isNull);
      expect(repriced(rebased, _rates, main: usd)!.amount, 2726);
    });
  });

  group('MainCurrencyService', () {
    late AppDatabase db;
    late DriftBillRepository bills;
    late SettingsRepository settings;
    late int changes;
    ExchangeRates? rates;

    MainCurrencyService service() => MainCurrencyService(
      bills: bills,
      transaction: db.writeTransaction,
      current: settings.mainCurrency,
      store: settings.setMainCurrency,
      budget: settings.getMonthlyBudget,
      storeBudget: settings.setMonthlyBudget,
      rates: () async => rates,
      clock: () => DateTime.utc(2026, 10, 10),
      onChanged: () async => changes++,
    );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      bills = DriftBillRepository(db);
      settings = SettingsRepository(db);
      changes = 0;
      rates = _rates;
      await bills.save(
        testBill('pln', due: LocalDate(2026, 10, 20), amount: 487500),
      );
    });

    tearDown(() => db.close());

    test('switches bills, the budget and the setting together', () async {
      await settings.setMonthlyBudget(3000000);

      expect(await service().change(usd), MainCurrencyChange.changed);

      expect(await settings.mainCurrency(), usd);
      final pln = (await bills.findById('pln'))!;
      expect(pln.originalAmountMinor, 487500);
      expect(pln.amount, 2726);
      // Rp 3.000.000 = US$167.78, rounded to whole dollars.
      expect(await settings.getMonthlyBudget(), 16800);
      expect(changes, 1);
    });

    test('refuses without rates instead of losing amounts', () async {
      rates = null;
      expect(await service().change(usd), MainCurrencyChange.needsRates);
      expect(await settings.mainCurrency(), idr);
      expect((await bills.findById('pln'))!.amount, 487500);
      expect(changes, 0);
    });

    test('the same currency changes nothing', () async {
      expect(await service().change(idr), MainCurrencyChange.unchanged);
      expect(changes, 0);
    });
  });

  test('payments in an earlier main currency count in the new one', () {
    final summary = HomeSummary.build(
      bills: [testBill('netflix', due: LocalDate(2026, 10, 25), amount: 1500)]
          .map((b) => b.copyWith(currency: usd))
          .toList(),
      today: LocalDate(2026, 10, 10),
      paymentsThisMonth: [
        Payment(
          id: 'p1',
          billId: 'pln',
          dueDate: LocalDate(2026, 10, 3),
          paidAt: DateTime.utc(2026, 10, 3),
          createdAt: DateTime.utc(2026, 10, 3),
          amount: 357611, // paid while the main currency was rupiah
        ),
      ],
      money: MoneyConverter(usd, _rates),
    );
    expect(summary.monthPaidTotal, 2000);
    expect(summary.monthTotal, 3500);
  });

  test('a payment records the main currency of its amount', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final bills = DriftBillRepository(db);
    final payments = DriftPaymentRepository(db);
    await bills.save(
      testBill(
        'claude',
        due: LocalDate(2026, 10, 12),
        amount: 2000,
      ).copyWith(currency: usd),
    );
    await PayBill(
      bills: bills,
      payments: payments,
      transaction: db.writeTransaction,
      clock: () => DateTime.utc(2026, 10, 12),
      onChanged: () async {},
      mainCurrency: () async => usd,
    )('claude');
    final paid = (await payments.getAll()).single;
    expect(paid.amount, 2000);
    expect(paid.currency, usd);
  });

  test('prices read naturally with a dollar main currency', () {
    final f = Formatters('en');
    String est(String a) => '$a (estimate)';
    expect(
      f.price(
        currency: idr,
        amount: 2726,
        originalMinor: 487500,
        isEstimate: false,
        estimateLabel: est,
        main: usd,
      ),
      'Rp 487,500 ≈ US\$27.26',
    );
    expect(
      f.price(
        currency: usd,
        amount: 2000,
        originalMinor: null,
        isEstimate: false,
        estimateLabel: est,
        main: usd,
      ),
      'US\$20.00',
    );
  });

  group('first main currency', () {
    late AppDatabase db;
    late SettingsRepository settings;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      settings = SettingsRepository(db);
    });

    tearDown(() => db.close());

    test('a fresh install follows the phone region', () async {
      expect(await settings.ensureMainCurrency(regionCode: 'US'), usd);
      expect(await settings.getMainCurrency(), usd);
    });

    test('an unsupported region falls back to rupiah', () async {
      expect(await settings.ensureMainCurrency(regionCode: 'AR'), idr);
    });

    test('an install from before main currencies keeps rupiah', () async {
      await settings.setOnboardingCompleted(completed: true);
      expect(await settings.ensureMainCurrency(regionCode: 'US'), idr);
    });

    test('a stored choice is never replaced', () async {
      await settings.setMainCurrency(_eur);
      expect(await settings.ensureMainCurrency(regionCode: 'US'), _eur);
    });
  });
}
