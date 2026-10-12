import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/providers.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../../payments/domain/pay_bill.dart';
import '../../domain/bill.dart';
import '../../domain/bill_status.dart';
import '../bill_labels.dart';
import 'status_ui.dart';

/// Swipe colours: darker than the status dots so white text stays AA
/// (6.5:1 and 6.7:1).
const _swipePaid = Color(0xFF067647);
const _swipeDelete = Color(0xFFB42318);

/// The core card: category "logo", name, category, price, renewal date and
/// a countdown in the status colour. Swipe right to mark paid, left to
/// delete; both can be undone or are confirmed first.
class SubscriptionCard extends ConsumerWidget {
  const SubscriptionCard({
    required this.bill,
    required this.today,
    this.swipeable = true,
    super.key,
  });

  final Bill bill;
  final LocalDate today;
  final bool swipeable;

  Future<bool> _markPaid(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final toast = B4Toast.of(context);
    final payBill = ref.read(payBillProvider);
    final result = await payBill(bill.id, expectedDueDate: bill.dueDate);
    final next = bill.recurrence.nextDueDate(
      bill.dueDate,
      anchorDay: bill.anchorDay,
    );
    toast.show(
      switch (result.outcome) {
        PayOutcome.paid => l10n.detailPaidNext(format.longDate(next!)),
        PayOutcome.archived => l10n.detailPaidArchived,
        PayOutcome.alreadyHandled => l10n.detailPaidAlready,
      },
      kind: result.outcome == PayOutcome.alreadyHandled
          ? B4ToastKind.info
          : B4ToastKind.success,
      actionLabel: result.outcome == PayOutcome.alreadyHandled
          ? null
          : l10n.actionUndo,
      onAction: () => payBill.undo(result),
      duration: const Duration(seconds: 6),
    );
    // The list updates itself from the database; never remove the tile here.
    return false;
  }

  Future<bool> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showB4Confirm(
      context: context,
      title: l10n.detailDeleteTitle,
      body: l10n.detailDeleteBody,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (confirmed) await ref.read(billServiceProvider).delete(bill.id);
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final text = context.text;
    final p = context.palette;
    final status = BillStatus.of(bill, today);
    final price = billPrice(l10n, format, bill);

    final card = B4Card(
      onTap: () => context.push(Routes.billDetail(bill.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryLogo(bill: bill),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.name, style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text(bill.category.label(l10n), style: text.bodySmall),
                  ],
                ),
              ),
              Icon(RemixIcons.arrowRightSLine, color: p.textSecondary),
            ],
          ),
          if (price != null) ...[
            const SizedBox(height: 14),
            Text(
              price,
              style: text.headlineMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(
                status: status,
                text: relativeDueLabel(l10n, bill.dueDate, today),
              ),
              Text(format.longDate(bill.dueDate), style: text.bodySmall),
            ],
          ),
        ],
      ),
    );

    if (!swipeable) return card;
    return Dismissible(
      key: ValueKey('${bill.id}-${bill.dueDate}'),
      background: _SwipeBackground(
        color: _swipePaid,
        icon: RemixIcons.checkboxCircleLine,
        label: l10n.swipePaid,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBackground(
        color: _swipeDelete,
        icon: RemixIcons.deleteBin6Line,
        label: l10n.swipeDelete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) => direction == DismissDirection.startToEnd
          ? _markPaid(context, ref)
          : _delete(context, ref),
      child: card,
    );
  }
}

/// Rounded square with the category icon, tinted Plum.
class CategoryLogo extends StatelessWidget {
  const CategoryLogo({required this.bill, this.size = 48, super.key});

  final Bill bill;
  final double size;

  @override
  Widget build(BuildContext context) =>
      B4IconTile(icon: bill.category.icon, size: size);
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: white),
          const SizedBox(width: 8),
          Text(label, style: context.text.labelLarge.copyWith(color: white)),
        ],
      ),
    );
  }
}
