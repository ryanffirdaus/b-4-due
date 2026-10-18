import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
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
      AsyncData() => B4Scaffold(
        topBar: const B4TopBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.detailNotFound, textAlign: TextAlign.center),
          ),
        ),
      ),
      AsyncError(:final error) => B4Scaffold(
        topBar: const B4TopBar(),
        body: Center(child: Text('$error')),
      ),
      _ => const B4Scaffold(body: B4LoadingView()),
    };
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.bill});

  final Bill bill;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final toast = B4Toast.of(context);
    final confirmed = await showB4Confirm(
      context: context,
      title: l10n.detailDeleteTitle,
      body: l10n.detailDeleteBody,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(billServiceProvider).delete(bill.id);
    toast.show(l10n.detailDeleted);
    if (context.mounted) context.pop();
  }

  Future<void> _markPaid(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final toast = B4Toast.of(context);
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
    toast.show(
      message,
      kind: result.outcome == PayOutcome.alreadyHandled
          ? B4ToastKind.info
          : B4ToastKind.success,
      duration: const Duration(seconds: 6),
      actionLabel: result.outcome == PayOutcome.alreadyHandled
          ? null
          : l10n.actionUndo,
      onAction: () => payBill.undo(result),
    );
    // A paid one-off bill is archived; there is nothing left to show.
    if (result.outcome == PayOutcome.archived && context.mounted) context.pop();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context);
    final toast = B4Toast.of(context);
    // Always hand the link to the user's browser.
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((Object _) => false);
    if (!ok) toast.error(l10n.detailOpenLinkFailed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final text = context.text;
    final p = context.palette;
    final today = ref.watch(todayProvider);
    final defaults =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();
    final url = bill.paymentUrl;
    final price = billPrice(l10n, format, bill);

    return B4Scaffold(
      topBar: B4TopBar(
        actions: [
          B4IconButton(
            icon: RemixIcons.pencilLine,
            label: l10n.actionEdit,
            onPressed: () => context.push(Routes.editBill(bill.id)),
          ),
          B4IconButton(
            icon: RemixIcons.deleteBin6Line,
            label: l10n.actionDelete,
            color: p.dangerText,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Tokens.pagePadding,
          4,
          Tokens.pagePadding,
          32,
        ),
        children: [
          B4WalletCard(
            colors: bill.cardColors,
            padding: const EdgeInsets.fromLTRB(22, 18, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(bill.category.icon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bill.category.label(l10n),
                        style: text.bodyMedium.copyWith(
                          color: B4WalletCard.foreground,
                        ),
                      ),
                    ),
                    B4CardBadge(relativeDueLabel(l10n, bill.dueDate, today)),
                  ],
                ),
                const SizedBox(height: 36),
                Semantics(
                  header: true,
                  child: Text(
                    bill.name,
                    style: text.headlineLarge.copyWith(
                      color: B4WalletCard.foreground,
                    ),
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      price,
                      style: text.displayMedium.copyWith(
                        color: B4WalletCard.foreground,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          B4Button(
            icon: RemixIcons.checkLine,
            label: l10n.detailMarkPaid,
            onPressed: () => _markPaid(context, ref),
          ),
          const SizedBox(height: Tokens.cardGap),
          B4Card(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoRow(
                  icon: RemixIcons.calendarEventLine,
                  label: l10n.detailDueDate,
                  value: format.longDateWithDay(bill.dueDate),
                ),
                const B4Divider(indent: 56),
                _InfoRow(
                  icon: RemixIcons.handCoinLine,
                  label: l10n.detailAmount,
                  value: price ?? l10n.detailAmountUnknown,
                ),
                const B4Divider(indent: 56),
                _InfoRow(
                  icon: RemixIcons.refreshLine,
                  label: l10n.detailRecurrence,
                  value: bill.recurrence.label(l10n),
                ),
                const B4Divider(indent: 56),
                _InfoRow(
                  icon: RemixIcons.notification3Line,
                  label: l10n.detailReminders,
                  value: remindersSummary(
                    l10n,
                    format,
                    bill.reminderOffsets ?? defaults.defaultOffsets,
                    bill.reminderMinuteOfDay ?? defaults.defaultMinuteOfDay,
                  ),
                ),
                if (bill.notes != null) ...[
                  const B4Divider(indent: 56),
                  _InfoRow(
                    icon: RemixIcons.fileList3Line,
                    label: l10n.detailNotes,
                    value: bill.notes!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Tokens.cardGap),
          CalendarCard(bill: bill),
          if (url != null) ...[
            const SizedBox(height: Tokens.cardGap),
            B4Button.outline(
              icon: RemixIcons.externalLinkLine,
              label: l10n.detailOpenPaymentLink,
              onPressed: () => _openLink(context, url),
            ),
          ],
        ],
      ),
    );
  }
}

/// Label and value; long-press copies the value (e.g. a customer number in
/// the notes).
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Pressable(
      onTap: null,
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        HapticFeedback.lightImpact();
        B4Toast.of(context).info(l10n.textCopied);
      },
      button: false,
      pressedScale: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 22, color: p.textSecondary),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.text.bodySmall),
                  const SizedBox(height: 2),
                  Text(value, style: context.text.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
