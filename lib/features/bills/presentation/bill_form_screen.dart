import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/format/formatters.dart';
import '../../../core/format/rupiah_input_formatter.dart';
import '../../../core/providers.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../currency/currency_providers.dart';
import '../../currency/domain/money.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../../templates/domain/bill_template.dart';
import '../domain/bill.dart';
import '../domain/bill_category.dart';
import '../domain/bill_draft.dart';
import '../domain/recurrence.dart';
import 'bill_labels.dart';
import 'widgets/card_color_picker.dart';

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
  late final TextEditingController _installmentTotal;
  late final TextEditingController _installmentNumber;

  late BillCategory _category;
  late LocalDate _dueDate;
  late RecurrenceType _recurrenceType;
  late bool _amountIsEstimate;
  late Currency _currency;
  int? _cardColor;
  late bool _installments;

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
    _cardColor = bill?.cardColor;
    _installments = bill?.hasInstallments ?? false;
    _installmentTotal = TextEditingController(
      text: bill?.installmentTotal?.toString() ?? '',
    );
    _installmentNumber = TextEditingController(
      text: bill?.installmentNumber?.toString() ?? '1',
    );
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
    _installmentTotal.dispose();
    _installmentNumber.dispose();
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
    cardColor: _cardColor,
    installmentTotal: _hasPlan ? _planTotal() : null,
    installmentNumber: _hasPlan ? _planNumber() : null,
    reminderOffsets: _offsets,
    reminderMinuteOfDay: _offsets == null ? null : _minuteOfDay,
    notes: _notes.text,
    paymentUrl: _url.text.trim().isEmpty ? null : _url.text,
  );

  /// An instalment plan only applies to repeating bills.
  bool get _hasPlan => _installments && _recurrenceType != RecurrenceType.once;

  int? _planTotal() {
    final total = int.tryParse(_installmentTotal.text.trim());
    return total != null && total >= 1 && total <= BillDraft.maxInstallments
        ? total
        : null;
  }

  int? _planNumber() {
    final number = int.tryParse(_installmentNumber.text.trim());
    final total = _planTotal();
    return number != null && number >= 1 && (total == null || number <= total)
        ? number
        : null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_offsets != null && _offsets!.isEmpty) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final service = ref.read(billServiceProvider);
    final toast = B4Toast.of(context);
    try {
      final existing = widget.bill;
      final saved = existing == null
          ? await service.create(_draft())
          : await service.update(existing, _draft());
      if (!mounted) return;
      toast.show(l10n.formSaved);
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
    final picked = await showB4DatePicker(
      context: context,
      title: AppLocalizations.of(context).formDueDate,
      initial: initial,
      first: first,
      last: today.addMonths(12 * 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime(int currentMinute) async {
    final picked = await showB4TimePicker(
      context: context,
      title: AppLocalizations.of(context).formReminderTime,
      initialMinuteOfDay: currentMinute,
    );
    if (picked != null) setState(() => _minuteOfDay = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final p = context.palette;
    final defaults =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();

    return B4Scaffold(
      topBar: B4TopBar(
        title: _isEditing ? l10n.formEditTitle : l10n.formNewTitle,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Tokens.pagePadding,
            8,
            Tokens.pagePadding,
            32,
          ),
          children: [
            B4TextFormField(
              controller: _name,
              label: l10n.formName,
              hint: l10n.formNameHint,
              textCapitalization: TextCapitalization.sentences,
              maxLength: BillDraft.maxNameLength,
              validator: (value) {
                final text = value.trim();
                if (text.isEmpty) return l10n.formErrorNameEmpty;
                if (text.length > BillDraft.maxNameLength) {
                  return l10n.formErrorNameTooLong;
                }
                return null;
              },
            ),
            const _Gap(),
            B4SelectField<BillCategory>(
              label: l10n.formCategory,
              value: _category,
              options: [
                for (final c in BillCategory.values)
                  B4Option(c, c.label(l10n), icon: c.icon),
              ],
              onChanged: (value) => setState(() => _category = value),
            ),
            const _Gap(),
            CardColorPicker(
              value: _cardColor,
              category: _category,
              onChanged: (value) => setState(() => _cardColor = value),
            ),
            const _Gap(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 116,
                  child: B4SelectField<Currency>(
                    label: l10n.formCurrency,
                    value: _currency,
                    options: [
                      for (final c in supportedCurrencies) B4Option(c, c.code),
                    ],
                    onChanged: (value) => setState(() {
                      if (value == _currency) return;
                      _currency = value;
                      _amount.clear();
                      if (value != idr) _ensureRates();
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: B4TextFormField(
                    controller: _amount,
                    label: l10n.formAmountIn(_currency.code),
                    hint: l10n.formAmountHint,
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
                    validator: (value) {
                      if (value.trim().isEmpty) return null;
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
            if (_amount.text.isNotEmpty && _currency == idr) ...[
              const SizedBox(height: 8),
              B4SwitchRow(
                title: l10n.formAmountEstimate,
                value: _amountIsEstimate,
                onChanged: (v) => setState(() => _amountIsEstimate = v),
              ),
            ],
            const _Gap(),
            B4FieldButton(
              label: l10n.formDueDate,
              value: format.longDateWithDay(_dueDate),
              icon: RemixIcons.calendarEventLine,
              onTap: _pickDate,
            ),
            const _Gap(),
            _SectionLabel(l10n.formRecurrence),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in RecurrenceType.values)
                  B4Chip(
                    label: _recurrenceLabel(l10n, type),
                    selected: _recurrenceType == type,
                    onTap: () => setState(() => _recurrenceType = type),
                  ),
              ],
            ),
            if (_recurrenceType == RecurrenceType.everyNMonths) ...[
              const _Gap(),
              B4TextFormField(
                controller: _months,
                label: l10n.formEveryNMonths,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (_) =>
                    _customRecurrence() == null ? l10n.formErrorMonths : null,
              ),
            ],
            if (_recurrenceType != RecurrenceType.once) ...[
              const _Gap(),
              B4Card(
                padding: EdgeInsets.zero,
                child: B4SwitchRow(
                  icon: RemixIcons.bankCardLine,
                  title: l10n.formInstallments,
                  subtitle: l10n.formInstallmentsHelp,
                  value: _installments,
                  onChanged: (on) => setState(() => _installments = on),
                ),
              ),
              if (_installments) ...[
                const _Gap(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: B4TextFormField(
                        controller: _installmentTotal,
                        label: l10n.formInstallmentTotal,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        validator: (_) => _planTotal() == null
                            ? l10n.formErrorInstallmentTotal
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: B4TextFormField(
                        controller: _installmentNumber,
                        label: l10n.formInstallmentNumber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        validator: (_) => _planNumber() == null
                            ? l10n.formErrorInstallmentNumber
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const _Gap(),
            _SectionLabel(l10n.formReminders),
            B4Card(
              padding: EdgeInsets.zero,
              child: B4SwitchRow(
                icon: RemixIcons.notification3Line,
                title: l10n.formRemindersUseDefault,
                subtitle: remindersSummary(
                  l10n,
                  format,
                  defaults.defaultOffsets,
                  defaults.defaultMinuteOfDay,
                ),
                value: _offsets == null,
                onChanged: (useDefault) => setState(() {
                  _offsets = useDefault ? null : [...defaults.defaultOffsets];
                  _minuteOfDay = useDefault ? null : _minuteOfDay;
                }),
              ),
            ),
            if (_offsets != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final offset in _offsetChoices)
                    B4Chip(
                      label: offsetLabel(l10n, offset),
                      selected: _offsets!.contains(offset),
                      onTap: () => setState(() {
                        final on = !_offsets!.contains(offset);
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
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    l10n.formRemindersPickAtLeastOne,
                    style: context.text.bodyMedium.copyWith(
                      color: p.dangerText,
                    ),
                  ),
                ),
              const _Gap(),
              B4FieldButton(
                label: l10n.formReminderTime,
                value: format.timeOfDay(
                  _minuteOfDay ?? defaults.defaultMinuteOfDay,
                ),
                icon: RemixIcons.timeLine,
                onTap: () =>
                    _pickTime(_minuteOfDay ?? defaults.defaultMinuteOfDay),
              ),
            ],
            const _Gap(),
            B4TextFormField(
              controller: _notes,
              label: l10n.formNotes,
              hint: l10n.formNotesHint,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 5,
            ),
            const _Gap(),
            B4TextFormField(
              controller: _url,
              label: l10n.formPaymentUrl,
              hint: l10n.formPaymentUrlHint,
              keyboardType: TextInputType.url,
              autocorrect: false,
              validator: (value) {
                final text = value.trim();
                if (text.isEmpty) return null;
                return BillDraft.normalizePaymentUrl(text) == null
                    ? l10n.formErrorUrl
                    : null;
              },
            ),
            const SizedBox(height: 28),
            B4Button(
              label: l10n.actionSave,
              loading: _saving,
              onPressed: _save,
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
    final rates = ref.watch(exchangeRatesProvider).value;
    final rate = rates?.rateFor(currency);
    final style = context.text.bodySmall;

    if (rates == null || rate == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Row(
          children: [
            Expanded(child: Text(l10n.formRateUnavailable, style: style)),
            B4Button.ghost(
              label: l10n.actionRetry,
              icon: RemixIcons.refreshLine,
              onPressed: onRetry,
            ),
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
              style: context.text.titleMedium.copyWith(
                color: context.palette.primaryText,
                fontWeight: FontWeight.w600,
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
        style: context.text.labelMedium.copyWith(
          color: context.palette.textSecondary,
        ),
      ),
    );
  }
}
