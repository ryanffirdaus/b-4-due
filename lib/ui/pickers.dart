import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/time/local_date.dart';
import '../l10n/generated/app_localizations.dart';
import 'buttons.dart';
import 'controls.dart';
import 'icons.dart';
import 'overlays.dart';
import 'pressable.dart';
import 'surfaces.dart';
import 'theme.dart';
import 'tokens.dart';

/// Input-styled button that shows a value and opens a picker.
class B4FieldButton extends StatelessWidget {
  const B4FieldButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.leading,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  /// Trailing icon hinting at the picker (calendar, clock, chevron).
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(Tokens.controlRadius);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: context.text.labelMedium.copyWith(color: p.textSecondary),
            ),
          ),
        ),
        Pressable(
          onTap: onTap,
          semanticLabel: '$label, $value',
          excludeChildSemantics: true,
          borderRadius: radius,
          pressedScale: 0.99,
          child: Container(
            constraints: const BoxConstraints(minHeight: Tokens.controlHeight),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: p.surfaceVariant,
              borderRadius: radius,
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(child: Text(value, style: context.text.bodyLarge)),
                Icon(icon ?? RemixIcons.arrowDownSLine, color: p.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class B4Option<T> {
  const B4Option(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Dropdown replacement: a field that opens a sheet listing [options].
class B4SelectField<T> extends StatelessWidget {
  const B4SelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.sheetTitle,
    super.key,
  });

  final String label;
  final T value;
  final List<B4Option<T>> options;
  final ValueChanged<T> onChanged;
  final String? sheetTitle;

  @override
  Widget build(BuildContext context) {
    final current = options.firstWhere((o) => o.value == value);
    return B4FieldButton(
      label: label,
      value: current.label,
      leading: current.icon == null
          ? null
          : Icon(current.icon, color: context.palette.primaryText),
      onTap: () async {
        final picked = await showB4OptionSheet<T>(
          context: context,
          title: sheetTitle ?? label,
          options: options,
          selected: value,
        );
        if (picked != null) onChanged(picked.value);
      },
    );
  }
}

/// Sheet with one row per option; resolves to the tapped option. Wrapped
/// in a record so a nullable [T] can be picked.
Future<({T value})?> showB4OptionSheet<T>({
  required BuildContext context,
  required String title,
  required List<B4Option<T>> options,
  required T? selected,
}) {
  return showB4Sheet<({T value})>(
    context: context,
    title: title,
    builder: (context) => ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        for (final o in options)
          B4ListRow(
            title: o.label,
            icon: o.icon,
            selected: o.value == selected,
            padding: const EdgeInsets.symmetric(
              horizontal: Tokens.pagePadding,
              vertical: 10,
            ),
            onTap: () => Navigator.of(context).pop((value: o.value)),
          ),
      ],
    ),
  );
}

/// A Monday-first month grid, as on Indonesian calendars. [dayBuilder]
/// draws each day; leading blanks are left empty.
class B4MonthGrid extends StatelessWidget {
  const B4MonthGrid({
    required this.month,
    required this.dayBuilder,
    this.cellAspectRatio = 0.82,
    super.key,
  });

  /// Any date in the month to show.
  final LocalDate month;
  final Widget Function(BuildContext context, LocalDate day) dayBuilder;
  final double cellAspectRatio;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final leading = (DateTime.utc(month.year, month.month).weekday - 1) % 7;
    final days = LocalDate.daysInMonth(month.year, month.month);
    final weekdays = [
      for (var i = 0; i < 7; i++)
        // 1 January 2024 was a Monday.
        DateFormat.E(locale).format(DateTime.utc(2024, 1, 1 + i)),
    ];
    final rows = ((leading + days) / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = constraints.maxWidth / 7;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                for (final w in weekdays)
                  SizedBox(
                    width: cell,
                    child: ExcludeSemantics(
                      child: Text(
                        w,
                        textAlign: TextAlign.center,
                        style: context.text.labelMedium.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            for (var r = 0; r < rows; r++)
              Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    SizedBox(
                      width: cell,
                      height: cell / cellAspectRatio,
                      child: switch (r * 7 + c - leading + 1) {
                        final d when d >= 1 && d <= days => dayBuilder(
                          context,
                          LocalDate(month.year, month.month, d),
                        ),
                        _ => null,
                      },
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// Month title with previous/next buttons; tapping the title calls
/// [onTitleTap] (e.g. to pick a year).
class B4MonthHeader extends StatelessWidget {
  const B4MonthHeader({
    required this.title,
    required this.onPrevious,
    required this.onNext,
    this.onTitleTap,
    this.titleExpanded = false,
    super.key,
  });

  final String title;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTitleTap;
  final bool titleExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleText = Text(
      title,
      textAlign: TextAlign.center,
      style: context.text.headlineMedium,
    );
    return Row(
      children: [
        B4IconButton(
          icon: RemixIcons.arrowLeftSLine,
          label: l10n.calendarPrevMonth,
          onPressed: onPrevious,
        ),
        Expanded(
          child: onTitleTap == null
              ? titleText
              : Pressable(
                  onTap: onTitleTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: titleText),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: titleExpanded ? 0.5 : 0,
                          duration: Tokens.motion,
                          child: Icon(
                            RemixIcons.arrowDownSLine,
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        B4IconButton(
          icon: RemixIcons.arrowRightSLine,
          label: l10n.calendarNextMonth,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Picks a date between [first] and [last] (inclusive).
Future<LocalDate?> showB4DatePicker({
  required BuildContext context,
  required LocalDate initial,
  required LocalDate first,
  required LocalDate last,
  String? title,
}) {
  final l10n = AppLocalizations.of(context);
  return showB4Sheet<LocalDate>(
    context: context,
    title: title ?? l10n.pickerDateTitle,
    builder: (context) =>
        _DatePicker(initial: initial, first: first, last: last),
  );
}

class _DatePicker extends StatefulWidget {
  const _DatePicker({
    required this.initial,
    required this.first,
    required this.last,
  });

  final LocalDate initial;
  final LocalDate first;
  final LocalDate last;

  @override
  State<_DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<_DatePicker> {
  late LocalDate _selected = widget.initial;
  late LocalDate _month = LocalDate(
    widget.initial.year,
    widget.initial.month,
    1,
  );
  var _pickingYear = false;

  bool _inRange(LocalDate d) =>
      !d.isBefore(widget.first) && !d.isAfter(widget.last);

  bool get _canGoBack =>
      _month.isAfter(LocalDate(widget.first.year, widget.first.month, 1));

  bool get _canGoForward =>
      _month.isBefore(LocalDate(widget.last.year, widget.last.month, 1));

  void _shift(int months) =>
      setState(() => _month = _month.addMonths(months, preferredDay: 1));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthTitle = DateFormat.yMMMM(locale)
        .format(DateTime.utc(_month.year, _month.month));
    final selectedText = DateFormat.yMMMMEEEEd(locale)
        .format(_selected.toUtcDateTime());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Tokens.pagePadding,
        0,
        Tokens.pagePadding,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            selectedText,
            style: context.text.titleMedium.copyWith(color: p.primaryText),
          ),
          const SizedBox(height: 12),
          B4MonthHeader(
            title: monthTitle,
            titleExpanded: _pickingYear,
            onTitleTap: () => setState(() => _pickingYear = !_pickingYear),
            onPrevious: _canGoBack && !_pickingYear ? () => _shift(-1) : null,
            onNext: _canGoForward && !_pickingYear ? () => _shift(1) : null,
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: Tokens.motion,
            child: _pickingYear
                ? _YearGrid(
                    first: widget.first.year,
                    last: widget.last.year,
                    selected: _month.year,
                    onPick: (year) => setState(() {
                      var month = LocalDate(year, _month.month, 1);
                      final firstMonth = LocalDate(
                        widget.first.year,
                        widget.first.month,
                        1,
                      );
                      final lastMonth = LocalDate(
                        widget.last.year,
                        widget.last.month,
                        1,
                      );
                      if (month.isBefore(firstMonth)) month = firstMonth;
                      if (month.isAfter(lastMonth)) month = lastMonth;
                      _month = month;
                      _pickingYear = false;
                    }),
                  )
                : B4MonthGrid(
                    key: ValueKey(_month),
                    month: _month,
                    cellAspectRatio: 1,
                    dayBuilder: (context, day) => _DayButton(
                      day: day,
                      selected: day == _selected,
                      enabled: _inRange(day),
                      onTap: () => setState(() => _selected = day),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: B4Button.outline(
                  label: l10n.actionCancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: B4Button(
                  label: l10n.pickerChoose,
                  onPressed: () => Navigator.of(context).pop(_selected),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final LocalDate day;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Pressable(
      onTap: enabled ? onTap : null,
      selected: selected,
      semanticLabel: DateFormat.yMMMMd(locale).format(day.toUtcDateTime()),
      excludeChildSemantics: true,
      borderRadius: BorderRadius.circular(12),
      pressedScale: 0.9,
      child: Center(
        child: AnimatedContainer(
          duration: Tokens.motion,
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? p.primary : null,
          ),
          child: Text(
            '${day.day}',
            style: context.text.bodyLarge.copyWith(
              color: selected
                  ? p.onPrimary
                  : enabled
                  ? p.textPrimary
                  : p.textSecondary.withValues(alpha: 0.5),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _YearGrid extends StatelessWidget {
  const _YearGrid({
    required this.first,
    required this.last,
    required this.selected,
    required this.onPick,
  });

  final int first;
  final int last;
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var year = first; year <= last; year++)
          Pressable(
            onTap: () => onPick(year),
            selected: year == selected,
            borderRadius: BorderRadius.circular(Tokens.chipRadius),
            child: Container(
              width: 96,
              height: Tokens.minTouch,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: year == selected ? p.primary : p.surfaceVariant,
                borderRadius: BorderRadius.circular(Tokens.chipRadius),
              ),
              child: Text(
                '$year',
                style: context.text.labelLarge.copyWith(
                  color: year == selected ? p.onPrimary : p.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Picks a time of day as minutes after midnight: hour and minute steppers
/// plus a row of common reminder times.
Future<int?> showB4TimePicker({
  required BuildContext context,
  required int initialMinuteOfDay,
  String? title,
}) {
  final l10n = AppLocalizations.of(context);
  return showB4Sheet<int>(
    context: context,
    title: title ?? l10n.pickerTimeTitle,
    builder: (context) => _TimePicker(initial: initialMinuteOfDay),
  );
}

class _TimePicker extends StatefulWidget {
  const _TimePicker({required this.initial});

  final int initial;

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> {
  late int _hour = widget.initial ~/ 60;
  late int _minute = widget.initial % 60;

  /// Common reminder times, as minutes after midnight.
  static const _presets = [7 * 60, 9 * 60, 12 * 60, 17 * 60, 20 * 60];

  static String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final current = _hour * 60 + _minute;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Tokens.pagePadding,
        0,
        Tokens.pagePadding,
        16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _Stepper(
                  label: l10n.pickerHour,
                  value: _hour,
                  increased: (_hour + 1) % 24,
                  decreased: (_hour - 1) % 24,
                  format: _two,
                  onStep: (delta) =>
                      setState(() => _hour = (_hour + delta) % 24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '.',
                  style: context.text.displayMedium.copyWith(
                    color: p.primaryText,
                  ),
                ),
              ),
              Expanded(
                child: _Stepper(
                  label: l10n.pickerMinute,
                  value: _minute,
                  increased: _stepMinute(_minute, 1),
                  decreased: _stepMinute(_minute, -1),
                  format: _two,
                  onStep: (delta) =>
                      setState(() => _minute = _stepMinute(_minute, delta)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _presets)
                B4Chip(
                  label: '${_two(preset ~/ 60)}.${_two(preset % 60)}',
                  selected: preset == current,
                  onTap: () => setState(() {
                    _hour = preset ~/ 60;
                    _minute = preset % 60;
                  }),
                ),
            ],
          ),
          const SizedBox(height: Tokens.sectionGap),
          Row(
            children: [
              Expanded(
                child: B4Button.outline(
                  label: l10n.actionCancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: B4Button(
                  label: l10n.pickerChoose,
                  onPressed: () => Navigator.of(context).pop(current),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Moves [minute] to the next (or previous) multiple of five, wrapping
/// around the hour.
int _stepMinute(int minute, int delta) {
  if (delta > 0) return (minute ~/ 5 + 1) * 5 % 60;
  final down = minute % 5 == 0 ? minute - 5 : minute - minute % 5;
  return down % 60;
}

/// A large value between up and down buttons. Screen readers adjust it
/// with swipe up/down.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.increased,
    required this.decreased,
    required this.format,
    required this.onStep,
  });

  final String label;
  final int value;
  final int increased;
  final int decreased;
  final String Function(int) format;
  final ValueChanged<int> onStep;

  void _step(int delta) {
    HapticFeedback.selectionClick();
    onStep(delta);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: context.text.labelMedium.copyWith(color: p.textSecondary),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: p.surfaceVariant,
            borderRadius: BorderRadius.circular(Tokens.cardRadius),
          ),
          child: Column(
            children: [
              ExcludeSemantics(
                child: RotatedBox(
                  quarterTurns: 2,
                  child: B4IconButton(
                    icon: RemixIcons.arrowDownSLine,
                    label: label,
                    color: p.primaryText,
                    onPressed: () => _step(1),
                  ),
                ),
              ),
              Semantics(
                label: label,
                value: format(value),
                increasedValue: format(increased),
                decreasedValue: format(decreased),
                onIncrease: () => _step(1),
                onDecrease: () => _step(-1),
                child: ExcludeSemantics(
                  child: Text(
                    format(value),
                    style: context.text.displayLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ExcludeSemantics(
                child: B4IconButton(
                  icon: RemixIcons.arrowDownSLine,
                  label: label,
                  color: p.primaryText,
                  onPressed: () => _step(-1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
