import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../bills/domain/bill.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../bills/presentation/widgets/subscription_card.dart';
import '../../payments/domain/payment.dart';
import '../domain/home_summary.dart';

final homeSummaryProvider = Provider<AsyncValue<HomeSummary>>((ref) {
  final today = ref.watch(todayProvider);
  final payments = ref.watch(paymentsThisMonthProvider).value ?? const [];
  return ref
      .watch(activeBillsProvider)
      .whenData(
        (bills) => HomeSummary.build(
          bills: bills,
          today: today,
          paymentsThisMonth: payments,
        ),
      );
});

/// How many upcoming bills the home screen shows before "Lihat semua".
const _upcomingLimit = 4;

const _pagePadding = EdgeInsets.fromLTRB(
  Tokens.pagePadding,
  Tokens.cardGap,
  Tokens.pagePadding,
  Tokens.sectionGap,
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final today = ref.watch(todayProvider);

    return B4Scaffold(
      body: switch (summary) {
        AsyncData(:final value) when value.isEmpty => ListView(
          padding: _pagePadding,
          children: [
            _Greeting(today: today),
            const SizedBox(height: 48),
            const EmptyBills(),
          ],
        ),
        AsyncData(:final value) => _HomeContent(summary: value, today: today),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const B4LoadingView(),
      },
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.summary, required this.today});

  final HomeSummary summary;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final horizon = today.addDays(30);
    final upcoming = <Bill>[
      ...summary.overdue,
      ...summary.dueThisWeek,
      ...summary.later.where((b) => !b.dueDate.isAfter(horizon)),
    ];
    final recent =
        (ref.watch(paymentHistoryProvider).value ?? const <PaymentEntry>[])
            .take(3)
            .toList();

    return ListView(
      padding: _pagePadding,
      children: [
        _Greeting(today: today),
        const SizedBox(height: Tokens.cardGap),
        _MonthlySpendingCard(summary: summary, today: today),
        B4SectionHeader(title: l10n.homeQuickActions),
        const _QuickActions(),
        B4SectionHeader(
          title: l10n.homeUpcoming,
          actionLabel: upcoming.length > _upcomingLimit
              ? l10n.homeSeeAll
              : null,
          onAction: () => context.go(Routes.subscriptions),
        ),
        if (upcoming.isEmpty)
          _Hint(l10n.homeNoUpcoming)
        else
          for (final bill in upcoming.take(_upcomingLimit)) ...[
            SubscriptionCard(bill: bill, today: today),
            const SizedBox(height: Tokens.listGap),
          ],
        B4SectionHeader(
          title: l10n.homeRecentPayments,
          actionLabel: recent.isEmpty ? null : l10n.homeSeeAll,
          onAction: () => context.push(Routes.history),
        ),
        if (recent.isEmpty)
          _Hint(l10n.homeNoPayments)
        else
          B4ListGroup(
            children: [
              for (final entry in recent) _RecentPaymentRow(entry: entry),
            ],
          ),
      ],
    );
  }
}

class _Greeting extends ConsumerWidget {
  const _Greeting({required this.today});

  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hour = ref.watch(clockProvider)().hour;
    final greeting = switch (hour) {
      < 11 => l10n.greetingMorning,
      < 15 => l10n.greetingAfternoon,
      < 18 => l10n.greetingEvening,
      _ => l10n.greetingNight,
    };
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(greeting, style: context.text.displayMedium),
              ),
              const SizedBox(height: 4),
              Text(
                context.formatters.longDateWithDay(today),
                style: context.text.bodyLarge.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        B4IconButton(
          icon: RemixIcons.historyLine,
          label: l10n.historyTitle,
          filled: true,
          onPressed: () => context.push(Routes.history),
        ),
      ],
    );
  }
}

/// Large monthly total with a ring showing how much is already paid.
class _MonthlySpendingCard extends StatelessWidget {
  const _MonthlySpendingCard({required this.summary, required this.today});

  final HomeSummary summary;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final text = context.text;
    final p = context.palette;
    final total = summary.monthTotal;
    final paid = summary.monthPaidTotal;
    final remaining = (total - paid).clamp(0, total);
    final progress = total == 0 ? 0.0 : paid / total;
    final percent = '${(progress * 100).round()}%';

    return B4Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.homeMonthlySpending} · ${format.monthYear(today)}',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(format.rupiah(total), style: text.displayLarge),
                ),
                const SizedBox(height: 10),
                _Legend(
                  color: p.success,
                  text: l10n.homePaidShort(format.rupiah(paid)),
                ),
                const SizedBox(height: 4),
                _Legend(
                  color: p.primary,
                  text: l10n.homeRemaining(format.rupiah(remaining)),
                ),
                if (summary.monthUnknownAmountCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeMonthUnknownCount(summary.monthUnknownAmountCount),
                    style: text.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Read as the visible percentage only; the ring is decoration.
          Semantics(
            container: true,
            child: B4ProgressRing(
              value: progress,
              color: p.success,
              trackColor: p.primarySoft,
              child: Text(percent, style: text.titleSmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: context.text.bodyMedium)),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = [
      (RemixIcons.addLine, l10n.quickAdd, () => context.push(Routes.addBill)),
      (
        RemixIcons.calendar2Line,
        l10n.navCalendar,
        () => context.go(Routes.calendar),
      ),
      (
        RemixIcons.historyLine,
        l10n.quickHistory,
        () => context.push(Routes.history),
      ),
      (
        RemixIcons.pieChart2Line,
        l10n.navStatistics,
        () => context.go(Routes.statistics),
      ),
    ];
    // Large system fonts get two per row so labels never break mid-word.
    final columns = MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 2 : 4;
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        children: [
          for (final (icon, label, onTap) in actions)
            SizedBox(
              width: constraints.maxWidth / columns,
              child: _QuickAction(icon: icon, label: label, onTap: onTap),
            ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Tokens.controlRadius),
      pressedOverlay: const Color(0x00000000),
      pressedScale: 0.94,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(Tokens.controlRadius + 2),
                border: Border.all(color: p.outline),
              ),
              child: Icon(icon, color: p.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: context.text.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPaymentRow extends StatelessWidget {
  const _RecentPaymentRow({required this.entry});

  final PaymentEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final amount = entry.payment.amount;
    final paidOn = LocalDate.fromDateTime(entry.payment.paidAt.toLocal());
    return B4ListRow(
      icon: RemixIcons.checkLine,
      tone: B4Tone.success,
      title: entry.billName,
      subtitle: l10n.historyPaidOn(format.longDate(paidOn)),
      trailing: amount == null
          ? null
          : Text(format.rupiah(amount), style: context.text.titleSmall),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: context.text.bodyLarge.copyWith(
          color: context.palette.textSecondary,
        ),
      ),
    );
  }
}

/// Empty state: illustration, title, description, primary button.
class EmptyBills extends StatelessWidget {
  const EmptyBills({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return B4EmptyState(
      icon: RemixIcons.calendarCheckLine,
      title: l10n.homeEmptyTitle,
      body: l10n.homeEmptyBody,
      action: B4Button(
        icon: RemixIcons.addLine,
        label: l10n.homeAddBill,
        onPressed: () => context.push(Routes.addBill),
      ),
    );
  }
}
