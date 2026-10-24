import '../../../l10n/generated/app_localizations.dart';
import '../domain/money.dart';

/// The currency's name in the app's language ("US dollar", "Euro").
String currencyName(AppLocalizations l10n, Currency currency) =>
    switch (currency.code) {
      'IDR' => l10n.currencyIDR,
      'USD' => l10n.currencyUSD,
      'EUR' => l10n.currencyEUR,
      'SGD' => l10n.currencySGD,
      'MYR' => l10n.currencyMYR,
      'JPY' => l10n.currencyJPY,
      'GBP' => l10n.currencyGBP,
      'AUD' => l10n.currencyAUD,
      'CNY' => l10n.currencyCNY,
      'HKD' => l10n.currencyHKD,
      'KRW' => l10n.currencyKRW,
      'THB' => l10n.currencyTHB,
      'PHP' => l10n.currencyPHP,
      'INR' => l10n.currencyINR,
      'CAD' => l10n.currencyCAD,
      'CHF' => l10n.currencyCHF,
      'NZD' => l10n.currencyNZD,
      'BRL' => l10n.currencyBRL,
      'MXN' => l10n.currencyMXN,
      'TRY' => l10n.currencyTRY,
      'ILS' => l10n.currencyILS,
      'ZAR' => l10n.currencyZAR,
      'SEK' => l10n.currencySEK,
      'NOK' => l10n.currencyNOK,
      'DKK' => l10n.currencyDKK,
      'ISK' => l10n.currencyISK,
      'PLN' => l10n.currencyPLN,
      'CZK' => l10n.currencyCZK,
      'HUF' => l10n.currencyHUF,
      'RON' => l10n.currencyRON,
      'BGN' => l10n.currencyBGN,
      _ => currency.code,
    };
