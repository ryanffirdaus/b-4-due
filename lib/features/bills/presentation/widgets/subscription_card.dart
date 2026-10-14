import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/providers.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../payments/domain/pay_bill.dart';
import '../../domain/bill.dart';
import '../../domain/bill_status.dart';
import '../bill_labels.dart';
import 'status_ui.dart';

/// The core card: category "logo", name, category, price, renewal date and
/// a countdown in the status colour. Swipe right to mark paid, left to
/// delete; both can be undone from the snackbar.
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
    final messenger = ScaffoldMessenger.of(context);
    final payBill = ref.read(payBillProvider);
    final result = await payBill(bill.id, expectedDueDate: bill.dueDate);
    final next = bill.recurrence.nextDueDate(
      bill.dueDate,
      anchorDay: bill.anchorDay,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result.outcome) {
          PayOutcome.paid => l10n.detailPaidNext(format.longDate(next!)),
          PayOutcome.archived => l10n.detailPaidArchived,
          PayOutcome.alreadyHandled => l10n.detailPaidAlready,
        }),
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
    // The list updates itself from the database; never remove the tile here.
    return false;
  }

  Future<bool> _delete(BuildContext context, WidgetRef ref) async {
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
    if (confirmed == true) {
      await ref.read(billServiceProvider).delete(bill.id);
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final theme = Theme.of(context);
    final p = context.palette;
    final status = BillStatus.of(bill, today);
    final price = billPrice(l10n, format, bill);

    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.billDetail(bill.id)),
        child: Padding(
          padding: const EdgeInsets.all(Tokens.pagePadding),
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
                        Text(bill.name, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          bill.category.label(l10n),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: p.textSecondary),
                ],
              ),
              const SizedBox(height: 14),
              if (price != null)
                Text(
                  price,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                  Text(
                    format.longDate(bill.dueDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!swipeable) return card;
    return Dismissible(
      key: ValueKey('${bill.id}-${bill.dueDate}'),
      // Darker green/red than the status dots so white text stays AA.
      background: _SwipeBackground(
        color: const Color(0xFF15803D),
        icon: Icons.check_circle_rounded,
        label: l10n.swipePaid,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBackground(
        color: const Color(0xFFDC2626),
        icon: Icons.delete_rounded,
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

/// Rounded square with the category icon, tinted with the brand colour.
class CategoryLogo extends StatelessWidget {
  const CategoryLogo({required this.bill, this.size = 48, super.key});

  final Bill bill;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(bill.category.icon, color: p.primaryText, size: size / 2),
    );
  }
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
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
