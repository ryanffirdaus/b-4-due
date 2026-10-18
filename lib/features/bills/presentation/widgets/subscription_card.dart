import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/bill.dart';
import '../bill_labels.dart';
import 'bill_wallet_card.dart';

/// Swipe colours: darker than the status dots so white text stays AA
/// (6.5:1 and 6.7:1).
const _swipePaid = Color(0xFF067647);
const _swipeDelete = Color(0xFFB42318);

/// A bill in a list: a compact wallet card. Swipe right to mark paid (with
/// Batalkan), left to delete (confirmed first).
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
    final card = BillWalletCard(bill: bill, today: today, compact: true);
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await markBillPaid(context, ref, bill);
          // The list updates itself from the database; never remove the
          // card here.
          return false;
        }
        return _delete(context, ref);
      },
      child: card,
    );
  }
}

/// The category icon on a small circle in the bill's card colours.
class CategoryLogo extends StatelessWidget {
  const CategoryLogo({required this.bill, this.size = 48, super.key});

  final Bill bill;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: bill.cardColors.gradient,
      shape: BoxShape.circle,
    ),
    child: Icon(
      bill.category.icon,
      size: size * 0.48,
      color: B4WalletCard.foreground,
    ),
  );
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
