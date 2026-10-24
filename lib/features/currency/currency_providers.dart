import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'data/exchange_rate_data.dart';
import 'domain/exchange_rate_service.dart';
import 'domain/main_currency_service.dart';
import 'domain/money.dart';

final exchangeRateStoreProvider = Provider<ExchangeRateStore>(
  (ref) => DriftExchangeRateStore(ref.watch(databaseProvider)),
);

final exchangeRateSourceProvider = Provider<ExchangeRateSource>(
  (ref) => FrankfurterRateSource(clock: ref.watch(clockProvider)),
);

final exchangeRateServiceProvider = Provider<ExchangeRateService>(
  (ref) => ExchangeRateService(
    source: ref.watch(exchangeRateSourceProvider),
    store: ref.watch(exchangeRateStoreProvider),
    bills: ref.watch(billRepositoryProvider),
    clock: ref.watch(clockProvider),
    onChanged: ref.watch(onBillsChangedProvider),
    mainCurrency: ref.watch(settingsRepositoryProvider).mainCurrency,
  ),
);

/// The cached rates, updating as soon as fresh ones are saved.
final exchangeRatesProvider = StreamProvider<ExchangeRates?>(
  (ref) => ref.watch(exchangeRateStoreProvider).watch(),
);

/// Main currency read before `runApp`, so the first frame shows the right
/// currency. Overridden in `main`.
final initialMainCurrencyProvider = Provider<Currency>((ref) => idr);

/// The currency of totals, the budget and statistics.
final mainCurrencyProvider = NotifierProvider<MainCurrencyController, Currency>(
  MainCurrencyController.new,
);

/// Converts bills and payments in other currencies for totals.
final moneyConverterProvider = Provider<MoneyConverter>(
  (ref) => MoneyConverter(
    ref.watch(mainCurrencyProvider),
    ref.watch(exchangeRatesProvider).value,
  ),
);

final mainCurrencyServiceProvider = Provider<MainCurrencyService>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return MainCurrencyService(
    bills: ref.watch(billRepositoryProvider),
    transaction: ref.watch(databaseProvider).writeTransaction,
    current: settings.mainCurrency,
    store: settings.setMainCurrency,
    budget: settings.getMonthlyBudget,
    storeBudget: settings.setMonthlyBudget,
    rates: ref.watch(exchangeRateServiceProvider).cached,
    clock: ref.watch(clockProvider),
    onChanged: ref.watch(onBillsChangedProvider),
  );
});

class MainCurrencyController extends Notifier<Currency> {
  @override
  Currency build() => ref.watch(initialMainCurrencyProvider);

  /// Picks up a main currency written behind the controller's back (a
  /// restored backup).
  Future<void> reload() async {
    state = await ref.read(settingsRepositoryProvider).mainCurrency();
  }

  /// Switches to [currency], fetching today's rates first when needed.
  Future<MainCurrencyChange> change(Currency currency) async {
    if (currency == state) return MainCurrencyChange.unchanged;
    await ref.read(exchangeRateServiceProvider).refreshIfStale();
    final outcome = await ref
        .read(mainCurrencyServiceProvider)
        .change(currency);
    if (outcome == MainCurrencyChange.changed) state = currency;
    return outcome;
  }
}
