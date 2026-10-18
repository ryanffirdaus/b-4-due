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
import '../bill_labels.dart';

/// Marks [bill] paid and shows a toast with Batalkan.
Future<void> markBillPaid(
  BuildContext context,
  WidgetRef ref,
  Bill bill,
) async {
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
}

/// A bill as a wallet card. The full card shows the status, the first line
/// of the notes (often the customer number), the due date, the price and a
/// Bayar button; the peeking card in a stack shows only its top row.
class BillWalletCard extends ConsumerWidget {
  const BillWalletCard({
    required this.bill,
    required this.today,
    this.peeking = false,
    this.raised = false,
    this.compact = false,
    super.key,
  });

  final Bill bill;
  final LocalDate today;

  /// Only the top row is visible (behind another card).
  final bool peeking;
  final bool raised;

  /// A shorter card without the note line, for lists.
  final bool compact;

  /// Height of a full card at the default text size.
  static const height = 212.0;
  static const compactHeight = 160.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final text = context.text;
    final colors = bill.cardColors;
    final price = billPrice(l10n, format, bill);
    final due = relativeDueLabel(l10n, bill.dueDate, today);
    final note = compact ? null : bill.notes?.split('\n').first.trim();
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    const white = B4WalletCard.foreground;
    final soft = white.withValues(alpha: 0.86);

    final top = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(bill.category.icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            bill.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall.copyWith(color: white),
          ),
        ),
        const SizedBox(width: 8),
        B4CardBadge(due),
      ],
    );

    return B4WalletCard(
      colors: colors,
      raised: raised,
      height: peeking ? null : (compact ? compactHeight : height) * scale,
      semanticLabel: [bill.name, due, ?price].join(', '),
      onTap: () => context.push(Routes.billDetail(bill.id)),
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
      child: peeking
          ? Align(alignment: Alignment.topCenter, child: top)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                top,
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium.copyWith(color: soft),
                  ),
                ],
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.cardDueOn(format.shortDate(bill.dueDate)),
                            style: text.bodyMedium.copyWith(color: soft),
                          ),
                          if (price != null)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                price,
                                style: text.headlineLarge.copyWith(
                                  color: white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _PayButton(
                      color: colors.end,
                      onPressed: () => markBillPaid(context, ref, bill),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.color, required this.onPressed});

  /// The card's darker colour, used for the label on the white pill.
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Pressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      pressedScale: 0.94,
      child: Container(
        height: Tokens.minTouch,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: B4WalletCard.foreground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          l10n.cardPay,
          style: context.text.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
