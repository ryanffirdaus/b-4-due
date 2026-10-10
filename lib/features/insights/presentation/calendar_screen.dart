import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../app/shell.dart';
import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => _DaySheet(day: day, entries: entries),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final theme = Theme.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider);
    final entries = calendarMonth(
      bills: ref.watch(activeBillsProvider).value ?? const [],
      payments: ref.watch(paymentHistoryProvider).value ?? const [],
      month: _month,
      today: today,
    );

    // Monday-first grid, as on Indonesian calendars.
    final leading = (DateTime.utc(_month.year, _month.month).weekday - 1) % 7;
    final days = LocalDate.daysInMonth(_month.year, _month.month);
    final weekdays = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(Localizations.localeOf(context).toLanguageTag())
            .format(DateTime.utc(2024, 1, 1 + i)), // 1 Jan 2024 was a Monday
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: Tokens.sectionGap),
          children: [
            TabTitle(l10n.navCalendar),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Tokens.pagePadding,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: l10n.calendarPrevMonth,
                            onPressed: () => _shift(-1),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                          Expanded(
                            child: Text(
                              format.monthYear(_month),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.calendarNextMonth,
                            onPressed: () => _shift(1),
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final w in weekdays)
                            Expanded(
                              child: Text(
                                w,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leading + days,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 0.82,
                            ),
                        itemBuilder: (context, index) {
                          if (index < leading) return const SizedBox.shrink();
                          final day = LocalDate(
                            _month.year,
                            _month.month,
                            index - leading + 1,
                          );
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
            ),
            const SizedBox(height: Tokens.cardGap),
            const _Legend(),
          ],
        ),
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
    final theme = Theme.of(context);
    final format = context.formatters;
    return Semantics(
      button: true,
      label: '${format.longDate(day)}, ${entries.length}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? p.primary : null,
              ),
              child: Text(
                '${day.day}',
                style: theme.textTheme.bodyLarge?.copyWith(
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
      padding: const EdgeInsets.symmetric(horizontal: Tokens.pagePadding),
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
                Text(
                  s.label(l10n),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
    final theme = Theme.of(context);
    final p = context.palette;
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

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          Tokens.pagePadding,
          0,
          Tokens.pagePadding,
          Tokens.pagePadding,
        ),
        children: [
          Text(
            format.longDateWithDay(day),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: Tokens.listGap),
          if (entries.isEmpty)
            Text(
              l10n.calendarNothing,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: p.textSecondary,
              ),
            ),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: Tokens.listGap),
              child: Card(
                child: InkWell(
                  onTap: e.bill == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          context.push(Routes.billDetail(e.billId));
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.name,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            StatusChip(
                              status: e.status,
                              text: e.status.label(l10n),
                            ),
                          ],
                        ),
                        if (e.bill case final bill?
                            when billPrice(l10n, format, bill) != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            billPrice(l10n, format, bill)!,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ] else if (e.amount != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            format.rupiah(e.amount!),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                        if (e.bill != null && e.status != BillStatus.paid) ...[
                          const SizedBox(height: 6),
                          Text(
                            l10n.calendarReminderTimes(reminderTimes(e)),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
