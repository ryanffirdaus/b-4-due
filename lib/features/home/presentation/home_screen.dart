import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/domain/bill.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../bills/presentation/widgets/status_ui.dart';
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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (summary) {
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
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
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
        SectionHeader(title: l10n.homeQuickActions),
        const _QuickActions(),
        SectionHeader(
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
        SectionHeader(
          title: l10n.homeRecentPayments,
          actionLabel: recent.isEmpty ? null : l10n.homeSeeAll,
          onAction: () => context.push(Routes.history),
        ),
        if (recent.isEmpty)
          _Hint(l10n.homeNoPayments)
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0) const Divider(indent: 20, endIndent: 20),
                  _RecentPaymentTile(entry: recent[i]),
                ],
              ],
            ),
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
    final theme = Theme.of(context);
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
              Text(greeting, style: theme.textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(
                context.formatters.longDateWithDay(today),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.historyTitle,
          onPressed: () => context.push(Routes.history),
          icon: const Icon(Icons.history_rounded),
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
    final theme = Theme.of(context);
    final p = context.palette;
    final total = summary.monthTotal;
    final paid = summary.monthPaidTotal;
    final remaining = (total - paid).clamp(0, total);
    final progress = total == 0 ? 0.0 : paid / total;
    final percent = '${(progress * 100).round()}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.pagePadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.homeMonthlySpending} · ${format.monthYear(today)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      format.rupiah(total),
                      style: theme.textTheme.displayLarge,
                    ),
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
                      l10n.homeMonthUnknownCount(
                        summary.monthUnknownAmountCount,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Read as the visible percentage only; the ring is decoration.
            Semantics(
              container: true,
              child: SizedBox.square(
                dimension: 84,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ExcludeSemantics(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        color: p.success,
                        backgroundColor: p.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    Center(
                      child: Text(percent, style: theme.textTheme.titleSmall),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        Flexible(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
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
      (Icons.add_rounded, l10n.quickAdd, () => context.push(Routes.addBill)),
      (
        Icons.calendar_month_rounded,
        l10n.navCalendar,
        () => context.go(Routes.calendar),
      ),
      (
        Icons.receipt_long_rounded,
        l10n.quickHistory,
        () => context.push(Routes.history),
      ),
      (
        Icons.insights_rounded,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Tokens.controlRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(Tokens.controlRadius),
                border: Border.all(color: p.outline.withValues(alpha: 0.6)),
              ),
              child: Icon(icon, color: p.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPaymentTile extends StatelessWidget {
  const _RecentPaymentTile({required this.entry});

  final PaymentEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final p = context.palette;
    final amount = entry.payment.amount;
    final paidOn = LocalDate.fromDateTime(entry.payment.paidAt.toLocal());
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: p.success.withValues(alpha: 0.14),
        child: Icon(Icons.check_rounded, color: p.successText),
      ),
      title: Text(entry.billName),
      subtitle: Text(l10n.historyPaidOn(format.longDate(paidOn))),
      trailing: amount == null
          ? null
          : Text(
              format.rupiah(amount),
              style: Theme.of(context).textTheme.titleSmall,
            ),
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
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: context.palette.textSecondary),
      ),
    );
  }
}

/// Spec empty state: illustration, title, description, primary button.
class EmptyBills extends StatelessWidget {
  const EmptyBills({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: p.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.event_available_rounded,
            size: 52,
            color: p.primaryText,
          ),
        ),
        const SizedBox(height: Tokens.sectionGap),
        Text(
          l10n.homeEmptyTitle,
          style: theme.textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.homeEmptyBody,
          style: theme.textTheme.bodyLarge?.copyWith(color: p.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Tokens.sectionGap),
        FilledButton.icon(
          onPressed: () => context.push(Routes.addBill),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.homeAddBill),
        ),
      ],
    );
  }
}
