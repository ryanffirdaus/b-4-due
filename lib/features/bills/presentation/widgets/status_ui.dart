import 'package:flutter/widgets.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/bill_status.dart';

extension BillStatusUi on BillStatus {
  /// Dot colour (calendar, legend).
  Color color(Palette p) => switch (this) {
    BillStatus.paid => p.success,
    BillStatus.upcoming => p.neutral,
    BillStatus.dueSoon => p.warning,
    BillStatus.today => p.today,
    BillStatus.overdue => p.danger,
    BillStatus.cancelled => p.muted,
  };

  /// Text colour with AA contrast on [softColor].
  Color textColor(Palette p) => switch (this) {
    BillStatus.paid => p.successText,
    BillStatus.upcoming => p.neutralText,
    BillStatus.dueSoon => p.warningText,
    BillStatus.today => p.todayText,
    BillStatus.overdue => p.dangerText,
    BillStatus.cancelled => p.textSecondary,
  };

  /// Chip background.
  Color softColor(Palette p) => switch (this) {
    BillStatus.paid => p.successSoft,
    BillStatus.upcoming => p.neutralSoft,
    BillStatus.dueSoon => p.warningSoft,
    BillStatus.today => p.todaySoft,
    BillStatus.overdue => p.dangerSoft,
    BillStatus.cancelled => p.surfaceVariant,
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

/// Small pill with a status dot and text. Colour is never the only signal:
/// the text always says what the status is.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, required this.text, super.key});

  final BillStatus status;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 10, 3),
      decoration: BoxDecoration(
        color: status.softColor(p),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color(p),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: context.text.labelMedium.copyWith(
                color: status.textColor(p),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
