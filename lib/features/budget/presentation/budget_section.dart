import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/format/whole_amount_input_formatter.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../bills/presentation/bill_labels.dart';

/// Pengaturan → Anggaran: the monthly budget, set or changed in a sheet.
class BudgetSection extends ConsumerWidget {
  const BudgetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budget = ref.watch(monthlyBudgetProvider).value;
    return B4ListGroup(
      children: [
        B4ListRow(
          icon: RemixIcons.handCoinLine,
          title: l10n.settingsBudget,
          subtitle: budget == null
              ? l10n.settingsBudgetNone
              : context.money(budget),
          showChevron: true,
          onTap: () => showB4Sheet<void>(
            context: context,
            title: l10n.settingsBudget,
            builder: (context) => _BudgetSheet(current: budget),
          ),
        ),
      ],
    );
  }
}

class _BudgetSheet extends ConsumerStatefulWidget {
  const _BudgetSheet({required this.current});

  final int? current;

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  late final _amount = TextEditingController();
  var _filled = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(int? minorUnits) async {
    await ref.read(settingsRepositoryProvider).setMonthlyBudget(minorUnits);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = widget.current;
    if (!_filled && current != null) {
      // The budget is a round target: edited in whole units.
      final units = current ~/ context.mainCurrency.minorPerUnit;
      _amount.text = context.formatters.groupedNumber(units);
    }
    _filled = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final main = context.mainCurrency;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Tokens.pagePadding,
        0,
        Tokens.pagePadding,
        Tokens.pagePadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.settingsBudgetHelp, style: context.text.bodySmall),
          const SizedBox(height: Tokens.cardGap),
          B4TextField(
            controller: _amount,
            label: l10n.settingsBudgetAmount(main.code),
            errorText: _error,
            keyboardType: TextInputType.number,
            inputFormatters: [WholeAmountInputFormatter(context.formatters)],
            autofocus: true,
          ),
          const SizedBox(height: Tokens.cardGap),
          B4Button(
            label: l10n.actionSave,
            onPressed: () {
              final units = parseWholeAmount(_amount.text);
              if (units == null || units <= 0) {
                HapticFeedback.lightImpact();
                setState(() => _error = l10n.settingsBudgetError);
                return;
              }
              _save(units * main.minorPerUnit);
            },
          ),
          if (widget.current != null) ...[
            const SizedBox(height: 8),
            B4Button.ghost(
              label: l10n.settingsBudgetRemove,
              destructive: true,
              onPressed: () => _save(null),
            ),
          ],
        ],
      ),
    );
  }
}
