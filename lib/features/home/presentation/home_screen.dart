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
import '../../bills/presentation/widgets/bill_wallet_card.dart';
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

/// How many cards the wallet stack shows; the rest are under "Semua (n)".
const _stackLimit = 4;

const _pagePadding = EdgeInsets.fromLTRB(
  Tokens.pagePadding,
  Tokens.cardGap,
  Tokens.pagePadding,
  Tokens.fabClearance,
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
    final allActive =
        summary.overdue.length +
        summary.dueThisWeek.length +
        summary.later.length;
    final recent =
        (ref.watch(paymentHistoryProvider).value ?? const <PaymentEntry>[])
            .take(3)
            .toList();
    final stack = upcoming.take(_stackLimit).toList();
    // Large system fonts need a taller card; the peeking strip grows too.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);

    return ListView(
      padding: _pagePadding,
      children: [
        _Greeting(today: today),
        const SizedBox(height: Tokens.sectionGap),
        _MonthSummary(summary: summary),
        B4SectionHeader(
          title: l10n.homeCards,
          actionLabel: l10n.homeSeeAllCount(allActive),
          onAction: () => context.go(Routes.subscriptions),
        ),
        if (stack.isEmpty)
          _Hint(l10n.homeNoUpcoming)
        else
          B4WalletStack(
            cardHeight: BillWalletCard.height * scale,
            peek: 56 * scale,
            cards: [
              for (var i = 0; i < stack.length; i++)
                BillWalletCard(
                  bill: stack[i],
                  today: today,
                  peeking: i > 0,
                  raised: i == 0 && stack.length > 1,
                ),
            ],
          ),
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
              Text(
                context.formatters.longDateWithDay(today),
                style: context.text.bodyMedium.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text(greeting, style: context.text.headlineLarge),
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

/// What is still to pay this month, in large type, over a paid/remaining
/// bar.
class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.summary});

  final HomeSummary summary;

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

    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.homeLeftThisMonth,
            style: text.bodyLarge.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(format.rupiah(remaining), style: text.displayLarge),
          ),
          const SizedBox(height: 14),
          ExcludeSemantics(child: B4ProgressBar(value: progress)),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            children: [
              Text(
                l10n.homePaidShort(format.rupiah(paid)),
                style: text.bodySmall,
              ),
              Text(
                l10n.homeOfTotal(format.rupiah(total)),
                style: text.bodySmall,
              ),
            ],
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
