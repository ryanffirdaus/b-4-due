import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/presentation/bill_labels.dart';
import '../domain/payment.dart';

/// All recorded payments, newest first, grouped by the month they were paid.
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: switch (history) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.historyEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: context.palette.textSecondary),
            ),
          ),
        ),
        AsyncData(:final value) => _HistoryList(entries: value),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
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
    final theme = Theme.of(context);

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        for (final key in groups.keys) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
            child: Semantics(
              header: true,
              child: Text(
                labels[key]!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < groups[key]!.length; i++) ...[
                  if (i > 0) const Divider(indent: 16),
                  _PaymentTile(entry: groups[key]![i]),
                ],
              ],
            ),
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

    return ListTile(
      title: Text(entry.billName),
      subtitle: Text(
        '${l10n.historyPaidOn(format.longDate(paidOn))}\n'
        '${l10n.historyPeriod(format.longDate(payment.dueDate))}',
      ),
      isThreeLine: true,
      trailing: amount == null
          ? null
          : Text(
              format.rupiah(amount),
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
    );
  }
}
