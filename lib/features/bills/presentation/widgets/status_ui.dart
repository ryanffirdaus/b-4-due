import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/bill_status.dart';

extension BillStatusUi on BillStatus {
  /// Fill colour for dots and tinted chips (the spec colours).
  Color color(Palette p) => switch (this) {
    BillStatus.paid => p.success,
    BillStatus.upcoming => p.info,
    BillStatus.dueSoon => p.warning,
    BillStatus.today => p.today,
    BillStatus.overdue => p.danger,
    BillStatus.cancelled => p.muted,
  };

  /// Text colour with AA contrast on the card.
  Color textColor(Palette p) => switch (this) {
    BillStatus.paid => p.successText,
    BillStatus.upcoming => p.infoText,
    BillStatus.dueSoon => p.warningText,
    BillStatus.today => p.todayText,
    BillStatus.overdue => p.dangerText,
    BillStatus.cancelled => p.textSecondary,
  };

  String label(AppLocalizations l10n) => switch (this) {
    BillStatus.paid => l10n.statusPaid,
    BillStatus.upcoming => l10n.statusUpcoming,
    BillStatus.dueSoon => l10n.statusDueSoon,
    BillStatus.today => l10n.statusToday,
    BillStatus.overdue => l10n.statusOverdue,
    BillStatus.cancelled => l10n.statusCancelled,
  };
}

/// Small rounded label tinted with the status colour.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, required this.text, super.key});

  final BillStatus status;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color(p).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: status.textColor(p), fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Section title with an optional trailing action ("Lihat semua").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.sectionGap, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
