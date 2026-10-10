import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'data/exchange_rate_data.dart';
import 'domain/exchange_rate_service.dart';
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
  ),
);

/// The cached rates, updating as soon as fresh ones are saved.
final exchangeRatesProvider = StreamProvider<ExchangeRates?>(
  (ref) => ref.watch(exchangeRateStoreProvider).watch(),
);
