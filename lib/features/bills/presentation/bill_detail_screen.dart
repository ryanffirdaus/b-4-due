import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../calendar/presentation/calendar_card.dart';
import '../../payments/domain/pay_bill.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../domain/bill.dart';
import 'bill_labels.dart';

class BillDetailScreen extends ConsumerWidget {
  const BillDetailScreen({required this.billId, super.key});

  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bill = ref.watch(billByIdProvider(billId));

    return switch (bill) {
      AsyncData(:final value?) when value.isActive => _DetailBody(bill: value),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.detailNotFound, textAlign: TextAlign.center),
          ),
        ),
      ),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$error')),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.bill});

  final Bill bill;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.detailDeleteTitle),
        content: Text(l10n.detailDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.palette.dangerText,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(billServiceProvider).delete(bill.id);
    messenger.showSnackBar(SnackBar(content: Text(l10n.detailDeleted)));
    if (context.mounted) context.pop();
  }

  Future<void> _markPaid(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final messenger = ScaffoldMessenger.of(context);
    final payBill = ref.read(payBillProvider);
    final result = await payBill(bill.id, expectedDueDate: bill.dueDate);
    final message = switch (result.outcome) {
      PayOutcome.paid => l10n.detailPaidNext(
        format.longDate(
          bill.recurrence.nextDueDate(bill.dueDate, anchorDay: bill.anchorDay)!,
        ),
      ),
      PayOutcome.archived => l10n.detailPaidArchived,
      PayOutcome.alreadyHandled => l10n.detailPaidAlready,
    };
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
        // Auto-hide even with an undo button (Flutter keeps those by default).
        persist: false,
        action: result.outcome == PayOutcome.alreadyHandled
            ? null
            : SnackBarAction(
                label: l10n.actionUndo,
                onPressed: () => payBill.undo(result),
              ),
      ),
    );
    // A paid one-off bill is archived; there is nothing left to show.
    if (result.outcome == PayOutcome.archived && context.mounted) context.pop();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Always hand the link to the user's browser: the app itself has no
    // network access.
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((Object _) => false);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailOpenLinkFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);
    final defaults =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();
    final url = bill.paymentUrl;
    final days = bill.dueDate.differenceInDays(today);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.actionEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Routes.editBill(bill.id)),
          ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Row(
            children: [
              Icon(bill.category.icon, color: context.palette.textSecondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  bill.category.label(l10n),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(bill.name, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            relativeDueLabel(l10n, bill.dueDate, today),
            style: theme.textTheme.titleMedium?.copyWith(
              color: days < 0
                  ? context.palette.dangerText
                  : context.palette.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _markPaid(context, ref),
            icon: const Icon(Icons.check),
            label: Text(l10n.detailMarkPaid),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoRow(
                  label: l10n.detailDueDate,
                  value: format.longDateWithDay(bill.dueDate),
                ),
                const Divider(indent: 16),
                _InfoRow(
                  label: l10n.detailAmount,
                  value:
                      billPrice(l10n, format, bill) ?? l10n.detailAmountUnknown,
                ),
                const Divider(indent: 16),
                _InfoRow(
                  label: l10n.detailRecurrence,
                  value: bill.recurrence.label(l10n),
                ),
                const Divider(indent: 16),
                _InfoRow(
                  label: l10n.detailReminders,
                  value: remindersSummary(
                    l10n,
                    format,
                    bill.reminderOffsets ?? defaults.defaultOffsets,
                    bill.reminderMinuteOfDay ?? defaults.defaultMinuteOfDay,
                  ),
                ),
                if (bill.notes != null) ...[
                  const Divider(indent: 16),
                  _InfoRow(label: l10n.detailNotes, value: bill.notes!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          CalendarCard(bill: bill),
          if (url != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openLink(context, url),
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.detailOpenPaymentLink),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
