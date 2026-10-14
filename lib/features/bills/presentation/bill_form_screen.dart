import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/format/formatters.dart';
import '../../../core/format/rupiah_input_formatter.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../currency/currency_providers.dart';
import '../../currency/domain/money.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../../templates/domain/bill_template.dart';
import '../domain/bill.dart';
import '../domain/bill_category.dart';
import '../domain/bill_draft.dart';
import '../domain/recurrence.dart';
import 'bill_labels.dart';

/// Offsets offered as chips when a bill has its own reminder schedule.
const _offsetChoices = [30, 14, 7, 3, 2, 1, 0];

/// Create or edit a bill. Pass [bill] to edit, or an optional [templateKey]
/// to prefill a new one.
class BillFormScreen extends ConsumerStatefulWidget {
  const BillFormScreen({this.bill, this.templateKey, super.key});

  final Bill? bill;
  final String? templateKey;

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late final TextEditingController _url;
  late final TextEditingController _months;

  late BillCategory _category;
  late LocalDate _dueDate;
  late RecurrenceType _recurrenceType;
  late bool _amountIsEstimate;
  late Currency _currency;

  /// null = use app defaults.
  List<int>? _offsets;
  int? _minuteOfDay;

  bool _saving = false;
  bool _initialized = false;

  bool get _isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    final bill = widget.bill;
    final template = billTemplates.firstWhereOrNull(
      (t) => t.key == widget.templateKey,
    );
    final today = ref.read(todayProvider);

    _name = TextEditingController(text: bill?.name ?? template?.name ?? '');
    _amount = TextEditingController();
    _notes = TextEditingController(text: bill?.notes ?? template?.hint ?? '');
    _url = TextEditingController(text: bill?.paymentUrl ?? '');
    final recurrence =
        bill?.recurrence ?? template?.recurrence ?? const Recurrence.monthly();
    _months = TextEditingController(
      text: recurrence.type == RecurrenceType.everyNMonths
          ? recurrence.intervalMonths.toString()
          : '3',
    );
    _recurrenceType = recurrence.type;
    _category = bill?.category ?? template?.category ?? BillCategory.other;
    _dueDate =
        bill?.dueDate ?? template?.suggestedDueDate(today) ?? today.addDays(7);
    _amountIsEstimate = bill?.amountIsEstimate ?? false;
    _currency = bill?.currency ?? template?.currency ?? idr;
    if (_currency != idr) _ensureRates();
    _offsets = bill?.reminderOffsets;
    _minuteOfDay = bill?.reminderMinuteOfDay;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The amount needs the locale's grouping, which is only known here.
    if (!_initialized) {
      final bill = widget.bill;
      final original = bill?.originalAmountMinor;
      if (bill != null && bill.isForeign && original != null) {
        _amount.text = context.formatters.plainAmount(bill.currency, original);
      } else if (bill?.amount case final amount?) {
        _amount.text = context.formatters.groupedNumber(amount);
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _notes.dispose();
    _url.dispose();
    _months.dispose();
    super.dispose();
  }

  Recurrence? _recurrence() => switch (_recurrenceType) {
    RecurrenceType.once => const Recurrence.once(),
    RecurrenceType.monthly => const Recurrence.monthly(),
    RecurrenceType.yearly => const Recurrence.yearly(),
    RecurrenceType.every5Years => const Recurrence.every5Years(),
    RecurrenceType.everyNMonths => _customRecurrence(),
  };

  Recurrence? _customRecurrence() {
    final months = int.tryParse(_months.text.trim());
    if (months == null || months < 1 || months > Recurrence.maxCustomInterval) {
      return null;
    }
    return Recurrence.everyNMonths(months);
  }

  /// Fetches today's rates once if none are cached yet (first foreign bill).
  void _ensureRates() {
    final service = ref.read(exchangeRateServiceProvider);
    Future.microtask(service.refreshIfStale);
  }

  /// Price typed in the selected currency, in minor units.
  int? _originalMinor() => _currency == idr
      ? parseRupiah(_amount.text)
      : parseForeignAmount(_amount.text, _currency);

  /// Rupiah for the draft: typed directly, or converted at the cached rate
  /// (null until rates are available; filled in when they arrive).
  int? _rupiah(ExchangeRates? rates) {
    final original = _originalMinor();
    if (original == null) return null;
    if (_currency == idr) return original;
    return rates?.toIdr(_currency, original);
  }

  BillDraft _draft() => BillDraft(
    name: _name.text,
    category: _category,
    dueDate: _dueDate,
    recurrence: _recurrence() ?? const Recurrence.monthly(),
    amount: _rupiah(ref.read(exchangeRatesProvider).value),
    amountIsEstimate: _amountIsEstimate,
    currency: _currency,
    originalAmountMinor: _currency == idr ? null : _originalMinor(),
    reminderOffsets: _offsets,
    reminderMinuteOfDay: _offsets == null ? null : _minuteOfDay,
    notes: _notes.text,
    paymentUrl: _url.text.trim().isEmpty ? null : _url.text,
  );

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_offsets != null && _offsets!.isEmpty) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final service = ref.read(billServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final existing = widget.bill;
      final saved = existing == null
          ? await service.create(_draft())
          : await service.update(existing, _draft());
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.formSaved)));
      if (_isEditing) {
        context.pop();
      } else {
        context.pushReplacement(Routes.billDetail(saved.id));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final today = ref.read(todayProvider);
    final first = today.addDays(-365 * 2);
    final initial = _dueDate.isBefore(first) ? first : _dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.toUtcDateTime(),
      firstDate: first.toUtcDateTime(),
      lastDate: today.addMonths(12 * 10).toUtcDateTime(),
    );
    if (picked != null) {
      setState(() => _dueDate = LocalDate.fromDateTime(picked));
    }
  }

  Future<void> _pickTime(int currentMinute) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinute ~/ 60,
        minute: currentMinute % 60,
      ),
    );
    if (picked != null) {
      setState(() => _minuteOfDay = picked.hour * 60 + picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final theme = Theme.of(context);
    final defaults =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.formEditTitle : l10n.formNewTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              maxLength: BillDraft.maxNameLength,
              decoration: InputDecoration(
                labelText: l10n.formName,
                hintText: l10n.formNameHint,
                counterText: '',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return l10n.formErrorNameEmpty;
                if (text.length > BillDraft.maxNameLength) {
                  return l10n.formErrorNameTooLong;
                }
                return null;
              },
            ),
            const _Gap(),
            DropdownButtonFormField<BillCategory>(
              initialValue: _category,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.formCategory),
              items: [
                for (final category in BillCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, size: 22),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            category.label(l10n),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _category = value!),
            ),
            const _Gap(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 112,
                  child: DropdownButtonFormField<Currency>(
                    initialValue: _currency,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.formCurrency),
                    items: [
                      for (final c in supportedCurrencies)
                        DropdownMenuItem(value: c, child: Text(c.code)),
                    ],
                    onChanged: (value) => setState(() {
                      if (value == null || value == _currency) return;
                      _currency = value;
                      _amount.clear();
                      if (value != idr) _ensureRates();
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _currency == idr
                        ? [RupiahInputFormatter(format)]
                        : [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                    decoration: InputDecoration(
                      labelText: l10n.formAmountIn(_currency.code),
                      hintText: l10n.formAmountHint,
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return null;
                      return _originalMinor() == null
                          ? l10n.formErrorAmount
                          : null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            if (_currency != idr)
              _ConversionHint(
                currency: _currency,
                minorUnits: _originalMinor(),
                onRetry: () => ref
                    .read(exchangeRateServiceProvider)
                    .refreshIfStale(force: true),
              ),
            if (_amount.text.isNotEmpty && _currency == idr)
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(l10n.formAmountEstimate),
                value: _amountIsEstimate,
                onChanged: (v) => setState(() => _amountIsEstimate = v),
              ),
            const _Gap(),
            _FieldButton(
              label: l10n.formDueDate,
              value: format.longDateWithDay(_dueDate),
              icon: Icons.event_outlined,
              onTap: _pickDate,
            ),
            const _Gap(),
            _SectionLabel(l10n.formRecurrence),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in RecurrenceType.values)
                  ChoiceChip(
                    label: Text(_recurrenceLabel(l10n, type)),
                    selected: _recurrenceType == type,
                    onSelected: (_) => setState(() => _recurrenceType = type),
                  ),
              ],
            ),
            if (_recurrenceType == RecurrenceType.everyNMonths) ...[
              const _Gap(),
              TextFormField(
                controller: _months,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(labelText: l10n.formEveryNMonths),
                validator: (_) =>
                    _customRecurrence() == null ? l10n.formErrorMonths : null,
              ),
            ],
            const _Gap(),
            _SectionLabel(l10n.formReminders),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(l10n.formRemindersUseDefault),
              subtitle: Text(
                remindersSummary(
                  l10n,
                  format,
                  defaults.defaultOffsets,
                  defaults.defaultMinuteOfDay,
                ),
              ),
              value: _offsets == null,
              onChanged: (useDefault) => setState(() {
                _offsets = useDefault ? null : [...defaults.defaultOffsets];
                _minuteOfDay = useDefault ? null : _minuteOfDay;
              }),
            ),
            if (_offsets != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final offset in _offsetChoices)
                    FilterChip(
                      label: Text(offsetLabel(l10n, offset)),
                      selected: _offsets!.contains(offset),
                      onSelected: (on) => setState(() {
                        _offsets = ReminderSettings.normalizeOffsets(
                          on
                              ? [..._offsets!, offset]
                              : _offsets!.where((o) => o != offset),
                        );
                      }),
                    ),
                ],
              ),
              if (_offsets!.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.formRemindersPickAtLeastOne,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.palette.dangerText,
                    ),
                  ),
                ),
              const _Gap(),
              _FieldButton(
                label: l10n.formReminderTime,
                value: format.timeOfDay(
                  _minuteOfDay ?? defaults.defaultMinuteOfDay,
                ),
                icon: Icons.schedule_outlined,
                onTap: () =>
                    _pickTime(_minuteOfDay ?? defaults.defaultMinuteOfDay),
              ),
            ],
            const _Gap(),
            TextFormField(
              controller: _notes,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.formNotes,
                hintText: l10n.formNotesHint,
              ),
            ),
            const _Gap(),
            TextFormField(
              controller: _url,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.formPaymentUrl,
                hintText: l10n.formPaymentUrlHint,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                return BillDraft.normalizePaymentUrl(text) == null
                    ? l10n.formErrorUrl
                    : null;
              },
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  String _recurrenceLabel(AppLocalizations l10n, RecurrenceType type) =>
      switch (type) {
        RecurrenceType.once => l10n.recurrenceOnce,
        RecurrenceType.monthly => l10n.recurrenceMonthly,
        RecurrenceType.yearly => l10n.recurrenceYearly,
        RecurrenceType.every5Years => l10n.recurrenceEvery5Years,
        RecurrenceType.everyNMonths => l10n.recurrenceCustom,
      };
}

/// "≈ Rp357.611 · 1 USD = Rp17.880 (9 Oktober 2026)" under a foreign price.
class _ConversionHint extends ConsumerWidget {
  const _ConversionHint({
    required this.currency,
    required this.minorUnits,
    required this.onRetry,
  });

  final Currency currency;
  final int? minorUnits;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final theme = Theme.of(context);
    final rates = ref.watch(exchangeRatesProvider).value;
    final rate = rates?.rateFor(currency);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (rates == null || rate == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Row(
          children: [
            Expanded(child: Text(l10n.formRateUnavailable, style: style)),
            TextButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
          ],
        ),
      );
    }
    final rupiah = minorUnits == null
        ? null
        : rates.toIdr(currency, minorUnits!);
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rupiah != null)
            Text(
              l10n.formApproxRupiah(format.rupiah(rupiah)),
              style: theme.textTheme.titleMedium?.copyWith(
                color: context.palette.primaryText,
              ),
            ),
          Text(
            l10n.formRateLine(
              currency.code,
              format.rupiah(rate.round()),
              format.longDate(rates.rateDate),
            ),
            style: style,
          ),
        ],
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 16);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: context.palette.textSecondary),
      ),
    );
  }
}

/// A tappable, input-styled row that opens a picker.
class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, suffixIcon: Icon(icon)),
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
