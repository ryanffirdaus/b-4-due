import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../bills/domain/bill_status.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../bills/presentation/widgets/status_ui.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../domain/insights.dart';

/// Month grid with a coloured dot per bill; tapping a day opens a sheet
/// with that day's bills, their amounts and reminder times.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late LocalDate _month = () {
    final today = ref.read(todayProvider);
    return LocalDate(today.year, today.month, 1);
  }();

  void _shift(int months) =>
      setState(() => _month = _month.addMonths(months, preferredDay: 1));

  Future<void> _openDay(LocalDate day, List<CalendarEntry> entries) {
    return showB4Sheet<void>(
      context: context,
      title: context.formatters.longDateWithDay(day),
      builder: (context) => _DaySheet(day: day, entries: entries),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final today = ref.watch(todayProvider);
    final entries = calendarMonth(
      bills: ref.watch(activeBillsProvider).value ?? const [],
      payments: ref.watch(paymentHistoryProvider).value ?? const [],
      month: _month,
      today: today,
    );

    return B4Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: Tokens.fabClearance),
        children: [
          B4PageTitle(l10n.navCalendar),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Tokens.pagePadding,
              vertical: 8,
            ),
            child: B4Card(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Column(
                children: [
                  B4MonthHeader(
                    title: format.monthYear(_month),
                    onPrevious: () => _shift(-1),
                    onNext: () => _shift(1),
                  ),
                  const SizedBox(height: 8),
                  B4MonthGrid(
                    month: _month,
                    dayBuilder: (context, day) {
                      final dayEntries = entries[day] ?? const [];
                      return _DayCell(
                        day: day,
                        isToday: day == today,
                        entries: dayEntries,
                        onTap: () => _openDay(day, dayEntries),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _Legend(),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.entries,
    required this.onTap,
  });

  final LocalDate day;
  final bool isToday;
  final List<CalendarEntry> entries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final format = context.formatters;
    return Pressable(
      onTap: onTap,
      semanticLabel: '${format.longDate(day)}, ${entries.length}',
      excludeChildSemantics: true,
      borderRadius: BorderRadius.circular(14),
      pressedScale: 0.92,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isToday ? p.primary : null,
            ),
            child: Text(
              '${day.day}',
              style: context.text.bodyLarge.copyWith(
                color: isToday ? p.onPrimary : p.textPrimary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final e in entries.take(3))
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: e.status.color(p),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tokens.pagePadding + 4),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          for (final s in [
            BillStatus.overdue,
            BillStatus.today,
            BillStatus.dueSoon,
            BillStatus.upcoming,
            BillStatus.paid,
          ])
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color(p),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(s.label(l10n), style: context.text.bodyMedium),
              ],
            ),
        ],
      ),
    );
  }
}

class _DaySheet extends ConsumerWidget {
  const _DaySheet({required this.day, required this.entries});

  final LocalDate day;
  final List<CalendarEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final text = context.text;
    final defaults =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();

    String reminderTimes(CalendarEntry e) {
      final bill = e.bill!;
      final minute = bill.reminderMinuteOfDay ?? defaults.defaultMinuteOfDay;
      final offsets = ReminderSettings.normalizeOffsets(
        bill.reminderOffsets ?? defaults.defaultOffsets,
      );
      return offsets
          .map(
            (o) =>
                '${format.shortDate(e.date.addDays(-o))} ${format.timeOfDay(minute)}',
          )
          .join(', ');
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        Tokens.pagePadding,
        4,
        Tokens.pagePadding,
        Tokens.pagePadding,
      ),
      children: [
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.calendarNothing,
              style: text.bodyLarge.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.listGap),
            child: _DayEntryCard(
              entry: e,
              price: switch (e.bill) {
                final bill? => billPrice(l10n, format, bill),
                null => e.amount == null ? null : format.rupiah(e.amount!),
              },
              reminders: e.bill != null && e.status != BillStatus.paid
                  ? l10n.calendarReminderTimes(reminderTimes(e))
                  : null,
              onTap: e.bill == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      context.push(Routes.billDetail(e.billId));
                    },
            ),
          ),
      ],
    );
  }
}

/// One bill on the day sheet as a small wallet card in the bill's colours;
/// a bill that no longer exists keeps a neutral panel.
class _DayEntryCard extends StatelessWidget {
  const _DayEntryCard({
    required this.entry,
    required this.price,
    required this.reminders,
    required this.onTap,
  });

  final CalendarEntry entry;
  final String? price;
  final String? reminders;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;
    final bill = entry.bill;
    const white = B4WalletCard.foreground;
    final soft = white.withValues(alpha: 0.86);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (bill != null) ...[
              Icon(bill.category.icon, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                entry.name,
                style: text.titleSmall.copyWith(
                  color: bill == null ? null : white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (bill != null)
              B4CardBadge(entry.status.label(l10n))
            else
              StatusChip(status: entry.status, text: entry.status.label(l10n)),
          ],
        ),
        if (price != null) ...[
          const SizedBox(height: 10),
          Text(
            price!,
            style: text.headlineMedium.copyWith(
              color: bill == null ? null : white,
            ),
          ),
        ],
        if (reminders != null) ...[
          const SizedBox(height: 4),
          Text(reminders!, style: text.bodySmall.copyWith(color: soft)),
        ],
      ],
    );
    if (bill == null) {
      return B4Card(
        color: context.palette.surfaceVariant,
        padding: const EdgeInsets.all(16),
        child: body,
      );
    }
    return B4WalletCard(
      colors: bill.cardColors,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 16),
      child: body,
    );
  }
}
