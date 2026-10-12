import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../bills/presentation/bill_labels.dart';
import '../domain/payment.dart';

/// All recorded payments, newest first, grouped by the month they were paid.
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(paymentHistoryProvider);

    return B4Scaffold(
      topBar: B4TopBar(title: l10n.historyTitle),
      body: switch (history) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.historyEmpty,
              textAlign: TextAlign.center,
              style: context.text.bodyLarge.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ),
        AsyncData(:final value) => _HistoryList(entries: value),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const B4LoadingView(),
      },
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.entries});

  final List<PaymentEntry> entries;

  @override
  Widget build(BuildContext context) {
    final format = context.formatters;

    // Group by the local month of payment, keeping newest-first order.
    final groups = <String, List<PaymentEntry>>{};
    final labels = <String, String>{};
    for (final entry in entries) {
      final paid = LocalDate.fromDateTime(entry.payment.paidAt.toLocal());
      final key = '${paid.year}-${paid.month}';
      groups.putIfAbsent(key, () => []).add(entry);
      labels[key] = format.monthYear(paid);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Tokens.pagePadding,
        0,
        Tokens.pagePadding,
        32,
      ),
      children: [
        for (final key in groups.keys) ...[
          B4GroupLabel(labels[key]!),
          B4ListGroup(
            children: [
              for (final entry in groups[key]!) _PaymentTile(entry: entry),
            ],
          ),
        ],
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.entry});

  final PaymentEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final payment = entry.payment;
    final amount = payment.amount;
    final paidOn = LocalDate.fromDateTime(payment.paidAt.toLocal());

    return B4ListRow(
      icon: RemixIcons.checkLine,
      tone: B4Tone.success,
      title: entry.billName,
      subtitle:
          '${l10n.historyPaidOn(format.longDate(paidOn))}\n'
          '${l10n.historyPeriod(format.longDate(payment.dueDate))}',
      trailing: amount == null
          ? null
          : Text(format.rupiah(amount), style: context.text.titleSmall),
    );
  }
}
