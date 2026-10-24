import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../currency_providers.dart';
import '../domain/main_currency_service.dart';
import '../domain/money.dart';
import 'currency_labels.dart';

/// Pengaturan → Mata uang: the currency of totals, the budget and the
/// statistics, picked from the 31 ECB currencies.
class MainCurrencySection extends ConsumerWidget {
  const MainCurrencySection({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final toast = B4Toast.of(context);
    final current = ref.read(mainCurrencyProvider);
    final picked = await showB4OptionSheet<Currency>(
      context: context,
      title: l10n.settingsMainCurrency,
      selected: current,
      options: [
        for (final c in supportedCurrencies)
          B4Option(c, c.code, subtitle: currencyName(l10n, c)),
      ],
    );
    if (picked == null || picked.value == current) return;
    final outcome = await ref
        .read(mainCurrencyProvider.notifier)
        .change(picked.value);
    switch (outcome) {
      case MainCurrencyChange.changed:
        toast.show(l10n.settingsMainCurrencyChanged(picked.value.code));
      case MainCurrencyChange.needsRates:
        toast.error(l10n.settingsMainCurrencyNeedsRates);
      case MainCurrencyChange.unchanged:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final main = ref.watch(mainCurrencyProvider);
    return B4ListGroup(
      children: [
        B4ListRow(
          icon: RemixIcons.exchangeDollarLine,
          title: l10n.settingsMainCurrency,
          subtitle:
              '${main.code} · ${currencyName(l10n, main)}\n'
              '${l10n.settingsMainCurrencyHelp}',
          showChevron: true,
          onTap: () => _pick(context, ref),
        ),
      ],
    );
  }
}
