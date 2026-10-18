// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BillsTable extends Bills with TableInfo<$BillsTable, BillRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BillCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BillCategory>($BillsTable.$convertercategory);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountIsEstimateMeta = const VerificationMeta(
    'amountIsEstimate',
  );
  @override
  late final GeneratedColumn<bool> amountIsEstimate = GeneratedColumn<bool>(
    'amount_is_estimate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("amount_is_estimate" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> dueDate =
      GeneratedColumn<String>(
        'due_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($BillsTable.$converterdueDate);
  static const VerificationMeta _anchorDayMeta = const VerificationMeta(
    'anchorDay',
  );
  @override
  late final GeneratedColumn<int> anchorDay = GeneratedColumn<int>(
    'anchor_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceType, String>
  recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<RecurrenceType>($BillsTable.$converterrecurrence);
  static const VerificationMeta _intervalMonthsMeta = const VerificationMeta(
    'intervalMonths',
  );
  @override
  late final GeneratedColumn<int> intervalMonths = GeneratedColumn<int>(
    'interval_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>?, String>
  reminderOffsets = GeneratedColumn<String>(
    'reminder_offsets',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<int>?>($BillsTable.$converterreminderOffsetsn);
  static const VerificationMeta _reminderMinuteOfDayMeta =
      const VerificationMeta('reminderMinuteOfDay');
  @override
  late final GeneratedColumn<int> reminderMinuteOfDay = GeneratedColumn<int>(
    'reminder_minute_of_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentUrlMeta = const VerificationMeta(
    'paymentUrl',
  );
  @override
  late final GeneratedColumn<String> paymentUrl = GeneratedColumn<String>(
    'payment_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDR'),
  );
  static const VerificationMeta _originalAmountMinorMeta =
      const VerificationMeta('originalAmountMinor');
  @override
  late final GeneratedColumn<int> originalAmountMinor = GeneratedColumn<int>(
    'original_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardColorMeta = const VerificationMeta(
    'cardColor',
  );
  @override
  late final GeneratedColumn<int> cardColor = GeneratedColumn<int>(
    'card_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentTotalMeta = const VerificationMeta(
    'installmentTotal',
  );
  @override
  late final GeneratedColumn<int> installmentTotal = GeneratedColumn<int>(
    'installment_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    amount,
    amountIsEstimate,
    dueDate,
    anchorDay,
    recurrence,
    intervalMonths,
    reminderOffsets,
    reminderMinuteOfDay,
    notes,
    paymentUrl,
    createdAt,
    updatedAt,
    archivedAt,
    deletedAt,
    snoozedUntil,
    currency,
    originalAmountMinor,
    cardColor,
    installmentTotal,
    installmentNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('amount_is_estimate')) {
      context.handle(
        _amountIsEstimateMeta,
        amountIsEstimate.isAcceptableOrUnknown(
          data['amount_is_estimate']!,
          _amountIsEstimateMeta,
        ),
      );
    }
    if (data.containsKey('anchor_day')) {
      context.handle(
        _anchorDayMeta,
        anchorDay.isAcceptableOrUnknown(data['anchor_day']!, _anchorDayMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDayMeta);
    }
    if (data.containsKey('interval_months')) {
      context.handle(
        _intervalMonthsMeta,
        intervalMonths.isAcceptableOrUnknown(
          data['interval_months']!,
          _intervalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minute_of_day')) {
      context.handle(
        _reminderMinuteOfDayMeta,
        reminderMinuteOfDay.isAcceptableOrUnknown(
          data['reminder_minute_of_day']!,
          _reminderMinuteOfDayMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('payment_url')) {
      context.handle(
        _paymentUrlMeta,
        paymentUrl.isAcceptableOrUnknown(data['payment_url']!, _paymentUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('original_amount_minor')) {
      context.handle(
        _originalAmountMinorMeta,
        originalAmountMinor.isAcceptableOrUnknown(
          data['original_amount_minor']!,
          _originalAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('card_color')) {
      context.handle(
        _cardColorMeta,
        cardColor.isAcceptableOrUnknown(data['card_color']!, _cardColorMeta),
      );
    }
    if (data.containsKey('installment_total')) {
      context.handle(
        _installmentTotalMeta,
        installmentTotal.isAcceptableOrUnknown(
          data['installment_total']!,
          _installmentTotalMeta,
        ),
      );
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $BillsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      ),
      amountIsEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}amount_is_estimate'],
      )!,
      dueDate: $BillsTable.$converterdueDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date'],
        )!,
      ),
      anchorDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_day'],
      )!,
      recurrence: $BillsTable.$converterrecurrence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence'],
        )!,
      ),
      intervalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_months'],
      )!,
      reminderOffsets: $BillsTable.$converterreminderOffsetsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_offsets'],
        ),
      ),
      reminderMinuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute_of_day'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      paymentUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      originalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_minor'],
      ),
      cardColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_color'],
      ),
      installmentTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_total'],
      ),
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      ),
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }

  static TypeConverter<BillCategory, String> $convertercategory =
      const BillCategoryConverter();
  static TypeConverter<LocalDate, String> $converterdueDate =
      const LocalDateConverter();
  static JsonTypeConverter2<RecurrenceType, String, String>
  $converterrecurrence = const EnumNameConverter<RecurrenceType>(
    RecurrenceType.values,
  );
  static TypeConverter<List<int>, String> $converterreminderOffsets =
      const OffsetListConverter();
  static TypeConverter<List<int>?, String?> $converterreminderOffsetsn =
      NullAwareTypeConverter.wrap($converterreminderOffsets);
}

class BillRow extends DataClass implements Insertable<BillRow> {
  final String id;
  final String name;
  final BillCategory category;

  /// Whole rupiah; null when unknown.
  final int? amount;
  final bool amountIsEstimate;
  final LocalDate dueDate;
  final int anchorDay;
  final RecurrenceType recurrence;
  final int intervalMonths;

  /// JSON array of day offsets; null means "use the app default".
  final List<int>? reminderOffsets;

  /// Minutes after midnight; null means "use the app default".
  final int? reminderMinuteOfDay;
  final String? notes;
  final String? paymentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final DateTime? deletedAt;

  /// "Ingatkan besok": one extra reminder at this instant. Added in v2.
  final DateTime? snoozedUntil;

  /// ISO 4217 code of the bill's own currency. Added in v4.
  final String currency;

  /// Price in the currency's minor units; null for rupiah bills. Added in v4.
  final int? originalAmountMinor;

  /// Index into the wallet-card colours; null follows the category.
  /// Added in v5.
  final int? cardColor;

  /// Instalment plan: how many payments in total, and which one is due now
  /// (1-based). Both null for an open-ended bill. Added in v6.
  final int? installmentTotal;
  final int? installmentNumber;
  const BillRow({
    required this.id,
    required this.name,
    required this.category,
    this.amount,
    required this.amountIsEstimate,
    required this.dueDate,
    required this.anchorDay,
    required this.recurrence,
    required this.intervalMonths,
    this.reminderOffsets,
    this.reminderMinuteOfDay,
    this.notes,
    this.paymentUrl,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.deletedAt,
    this.snoozedUntil,
    required this.currency,
    this.originalAmountMinor,
    this.cardColor,
    this.installmentTotal,
    this.installmentNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $BillsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    map['amount_is_estimate'] = Variable<bool>(amountIsEstimate);
    {
      map['due_date'] = Variable<String>(
        $BillsTable.$converterdueDate.toSql(dueDate),
      );
    }
    map['anchor_day'] = Variable<int>(anchorDay);
    {
      map['recurrence'] = Variable<String>(
        $BillsTable.$converterrecurrence.toSql(recurrence),
      );
    }
    map['interval_months'] = Variable<int>(intervalMonths);
    if (!nullToAbsent || reminderOffsets != null) {
      map['reminder_offsets'] = Variable<String>(
        $BillsTable.$converterreminderOffsetsn.toSql(reminderOffsets),
      );
    }
    if (!nullToAbsent || reminderMinuteOfDay != null) {
      map['reminder_minute_of_day'] = Variable<int>(reminderMinuteOfDay);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || paymentUrl != null) {
      map['payment_url'] = Variable<String>(paymentUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || originalAmountMinor != null) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor);
    }
    if (!nullToAbsent || cardColor != null) {
      map['card_color'] = Variable<int>(cardColor);
    }
    if (!nullToAbsent || installmentTotal != null) {
      map['installment_total'] = Variable<int>(installmentTotal);
    }
    if (!nullToAbsent || installmentNumber != null) {
      map['installment_number'] = Variable<int>(installmentNumber);
    }
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      amountIsEstimate: Value(amountIsEstimate),
      dueDate: Value(dueDate),
      anchorDay: Value(anchorDay),
      recurrence: Value(recurrence),
      intervalMonths: Value(intervalMonths),
      reminderOffsets: reminderOffsets == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderOffsets),
      reminderMinuteOfDay: reminderMinuteOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinuteOfDay),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      paymentUrl: paymentUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      currency: Value(currency),
      originalAmountMinor: originalAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmountMinor),
      cardColor: cardColor == null && nullToAbsent
          ? const Value.absent()
          : Value(cardColor),
      installmentTotal: installmentTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentTotal),
      installmentNumber: installmentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentNumber),
    );
  }

  factory BillRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<BillCategory>(json['category']),
      amount: serializer.fromJson<int?>(json['amount']),
      amountIsEstimate: serializer.fromJson<bool>(json['amountIsEstimate']),
      dueDate: serializer.fromJson<LocalDate>(json['dueDate']),
      anchorDay: serializer.fromJson<int>(json['anchorDay']),
      recurrence: $BillsTable.$converterrecurrence.fromJson(
        serializer.fromJson<String>(json['recurrence']),
      ),
      intervalMonths: serializer.fromJson<int>(json['intervalMonths']),
      reminderOffsets: serializer.fromJson<List<int>?>(json['reminderOffsets']),
      reminderMinuteOfDay: serializer.fromJson<int?>(
        json['reminderMinuteOfDay'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      paymentUrl: serializer.fromJson<String?>(json['paymentUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      currency: serializer.fromJson<String>(json['currency']),
      originalAmountMinor: serializer.fromJson<int?>(
        json['originalAmountMinor'],
      ),
      cardColor: serializer.fromJson<int?>(json['cardColor']),
      installmentTotal: serializer.fromJson<int?>(json['installmentTotal']),
      installmentNumber: serializer.fromJson<int?>(json['installmentNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<BillCategory>(category),
      'amount': serializer.toJson<int?>(amount),
      'amountIsEstimate': serializer.toJson<bool>(amountIsEstimate),
      'dueDate': serializer.toJson<LocalDate>(dueDate),
      'anchorDay': serializer.toJson<int>(anchorDay),
      'recurrence': serializer.toJson<String>(
        $BillsTable.$converterrecurrence.toJson(recurrence),
      ),
      'intervalMonths': serializer.toJson<int>(intervalMonths),
      'reminderOffsets': serializer.toJson<List<int>?>(reminderOffsets),
      'reminderMinuteOfDay': serializer.toJson<int?>(reminderMinuteOfDay),
      'notes': serializer.toJson<String?>(notes),
      'paymentUrl': serializer.toJson<String?>(paymentUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'currency': serializer.toJson<String>(currency),
      'originalAmountMinor': serializer.toJson<int?>(originalAmountMinor),
      'cardColor': serializer.toJson<int?>(cardColor),
      'installmentTotal': serializer.toJson<int?>(installmentTotal),
      'installmentNumber': serializer.toJson<int?>(installmentNumber),
    };
  }

  BillRow copyWith({
    String? id,
    String? name,
    BillCategory? category,
    Value<int?> amount = const Value.absent(),
    bool? amountIsEstimate,
    LocalDate? dueDate,
    int? anchorDay,
    RecurrenceType? recurrence,
    int? intervalMonths,
    Value<List<int>?> reminderOffsets = const Value.absent(),
    Value<int?> reminderMinuteOfDay = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> paymentUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    String? currency,
    Value<int?> originalAmountMinor = const Value.absent(),
    Value<int?> cardColor = const Value.absent(),
    Value<int?> installmentTotal = const Value.absent(),
    Value<int?> installmentNumber = const Value.absent(),
  }) => BillRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    amount: amount.present ? amount.value : this.amount,
    amountIsEstimate: amountIsEstimate ?? this.amountIsEstimate,
    dueDate: dueDate ?? this.dueDate,
    anchorDay: anchorDay ?? this.anchorDay,
    recurrence: recurrence ?? this.recurrence,
    intervalMonths: intervalMonths ?? this.intervalMonths,
    reminderOffsets: reminderOffsets.present
        ? reminderOffsets.value
        : this.reminderOffsets,
    reminderMinuteOfDay: reminderMinuteOfDay.present
        ? reminderMinuteOfDay.value
        : this.reminderMinuteOfDay,
    notes: notes.present ? notes.value : this.notes,
    paymentUrl: paymentUrl.present ? paymentUrl.value : this.paymentUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    currency: currency ?? this.currency,
    originalAmountMinor: originalAmountMinor.present
        ? originalAmountMinor.value
        : this.originalAmountMinor,
    cardColor: cardColor.present ? cardColor.value : this.cardColor,
    installmentTotal: installmentTotal.present
        ? installmentTotal.value
        : this.installmentTotal,
    installmentNumber: installmentNumber.present
        ? installmentNumber.value
        : this.installmentNumber,
  );
  BillRow copyWithCompanion(BillsCompanion data) {
    return BillRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountIsEstimate: data.amountIsEstimate.present
          ? data.amountIsEstimate.value
          : this.amountIsEstimate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      anchorDay: data.anchorDay.present ? data.anchorDay.value : this.anchorDay,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      intervalMonths: data.intervalMonths.present
          ? data.intervalMonths.value
          : this.intervalMonths,
      reminderOffsets: data.reminderOffsets.present
          ? data.reminderOffsets.value
          : this.reminderOffsets,
      reminderMinuteOfDay: data.reminderMinuteOfDay.present
          ? data.reminderMinuteOfDay.value
          : this.reminderMinuteOfDay,
      notes: data.notes.present ? data.notes.value : this.notes,
      paymentUrl: data.paymentUrl.present
          ? data.paymentUrl.value
          : this.paymentUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      currency: data.currency.present ? data.currency.value : this.currency,
      originalAmountMinor: data.originalAmountMinor.present
          ? data.originalAmountMinor.value
          : this.originalAmountMinor,
      cardColor: data.cardColor.present ? data.cardColor.value : this.cardColor,
      installmentTotal: data.installmentTotal.present
          ? data.installmentTotal.value
          : this.installmentTotal,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('amountIsEstimate: $amountIsEstimate, ')
          ..write('dueDate: $dueDate, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('recurrence: $recurrence, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('reminderMinuteOfDay: $reminderMinuteOfDay, ')
          ..write('notes: $notes, ')
          ..write('paymentUrl: $paymentUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('currency: $currency, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('cardColor: $cardColor, ')
          ..write('installmentTotal: $installmentTotal, ')
          ..write('installmentNumber: $installmentNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    category,
    amount,
    amountIsEstimate,
    dueDate,
    anchorDay,
    recurrence,
    intervalMonths,
    reminderOffsets,
    reminderMinuteOfDay,
    notes,
    paymentUrl,
    createdAt,
    updatedAt,
    archivedAt,
    deletedAt,
    snoozedUntil,
    currency,
    originalAmountMinor,
    cardColor,
    installmentTotal,
    installmentNumber,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.amountIsEstimate == this.amountIsEstimate &&
          other.dueDate == this.dueDate &&
          other.anchorDay == this.anchorDay &&
          other.recurrence == this.recurrence &&
          other.intervalMonths == this.intervalMonths &&
          other.reminderOffsets == this.reminderOffsets &&
          other.reminderMinuteOfDay == this.reminderMinuteOfDay &&
          other.notes == this.notes &&
          other.paymentUrl == this.paymentUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt &&
          other.deletedAt == this.deletedAt &&
          other.snoozedUntil == this.snoozedUntil &&
          other.currency == this.currency &&
          other.originalAmountMinor == this.originalAmountMinor &&
          other.cardColor == this.cardColor &&
          other.installmentTotal == this.installmentTotal &&
          other.installmentNumber == this.installmentNumber);
}

class BillsCompanion extends UpdateCompanion<BillRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<BillCategory> category;
  final Value<int?> amount;
  final Value<bool> amountIsEstimate;
  final Value<LocalDate> dueDate;
  final Value<int> anchorDay;
  final Value<RecurrenceType> recurrence;
  final Value<int> intervalMonths;
  final Value<List<int>?> reminderOffsets;
  final Value<int?> reminderMinuteOfDay;
  final Value<String?> notes;
  final Value<String?> paymentUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> snoozedUntil;
  final Value<String> currency;
  final Value<int?> originalAmountMinor;
  final Value<int?> cardColor;
  final Value<int?> installmentTotal;
  final Value<int?> installmentNumber;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountIsEstimate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.reminderMinuteOfDay = const Value.absent(),
    this.notes = const Value.absent(),
    this.paymentUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.currency = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.cardColor = const Value.absent(),
    this.installmentTotal = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required String id,
    required String name,
    required BillCategory category,
    this.amount = const Value.absent(),
    this.amountIsEstimate = const Value.absent(),
    required LocalDate dueDate,
    required int anchorDay,
    required RecurrenceType recurrence,
    this.intervalMonths = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.reminderMinuteOfDay = const Value.absent(),
    this.notes = const Value.absent(),
    this.paymentUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.currency = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.cardColor = const Value.absent(),
    this.installmentTotal = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       dueDate = Value(dueDate),
       anchorDay = Value(anchorDay),
       recurrence = Value(recurrence),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BillRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<bool>? amountIsEstimate,
    Expression<String>? dueDate,
    Expression<int>? anchorDay,
    Expression<String>? recurrence,
    Expression<int>? intervalMonths,
    Expression<String>? reminderOffsets,
    Expression<int>? reminderMinuteOfDay,
    Expression<String>? notes,
    Expression<String>? paymentUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? snoozedUntil,
    Expression<String>? currency,
    Expression<int>? originalAmountMinor,
    Expression<int>? cardColor,
    Expression<int>? installmentTotal,
    Expression<int>? installmentNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (amountIsEstimate != null) 'amount_is_estimate': amountIsEstimate,
      if (dueDate != null) 'due_date': dueDate,
      if (anchorDay != null) 'anchor_day': anchorDay,
      if (recurrence != null) 'recurrence': recurrence,
      if (intervalMonths != null) 'interval_months': intervalMonths,
      if (reminderOffsets != null) 'reminder_offsets': reminderOffsets,
      if (reminderMinuteOfDay != null)
        'reminder_minute_of_day': reminderMinuteOfDay,
      if (notes != null) 'notes': notes,
      if (paymentUrl != null) 'payment_url': paymentUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (currency != null) 'currency': currency,
      if (originalAmountMinor != null)
        'original_amount_minor': originalAmountMinor,
      if (cardColor != null) 'card_color': cardColor,
      if (installmentTotal != null) 'installment_total': installmentTotal,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<BillCategory>? category,
    Value<int?>? amount,
    Value<bool>? amountIsEstimate,
    Value<LocalDate>? dueDate,
    Value<int>? anchorDay,
    Value<RecurrenceType>? recurrence,
    Value<int>? intervalMonths,
    Value<List<int>?>? reminderOffsets,
    Value<int?>? reminderMinuteOfDay,
    Value<String?>? notes,
    Value<String?>? paymentUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? snoozedUntil,
    Value<String>? currency,
    Value<int?>? originalAmountMinor,
    Value<int?>? cardColor,
    Value<int?>? installmentTotal,
    Value<int?>? installmentNumber,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      amountIsEstimate: amountIsEstimate ?? this.amountIsEstimate,
      dueDate: dueDate ?? this.dueDate,
      anchorDay: anchorDay ?? this.anchorDay,
      recurrence: recurrence ?? this.recurrence,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      reminderMinuteOfDay: reminderMinuteOfDay ?? this.reminderMinuteOfDay,
      notes: notes ?? this.notes,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      currency: currency ?? this.currency,
      originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
      cardColor: cardColor ?? this.cardColor,
      installmentTotal: installmentTotal ?? this.installmentTotal,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $BillsTable.$convertercategory.toSql(category.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (amountIsEstimate.present) {
      map['amount_is_estimate'] = Variable<bool>(amountIsEstimate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(
        $BillsTable.$converterdueDate.toSql(dueDate.value),
      );
    }
    if (anchorDay.present) {
      map['anchor_day'] = Variable<int>(anchorDay.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(
        $BillsTable.$converterrecurrence.toSql(recurrence.value),
      );
    }
    if (intervalMonths.present) {
      map['interval_months'] = Variable<int>(intervalMonths.value);
    }
    if (reminderOffsets.present) {
      map['reminder_offsets'] = Variable<String>(
        $BillsTable.$converterreminderOffsetsn.toSql(reminderOffsets.value),
      );
    }
    if (reminderMinuteOfDay.present) {
      map['reminder_minute_of_day'] = Variable<int>(reminderMinuteOfDay.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (paymentUrl.present) {
      map['payment_url'] = Variable<String>(paymentUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (originalAmountMinor.present) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor.value);
    }
    if (cardColor.present) {
      map['card_color'] = Variable<int>(cardColor.value);
    }
    if (installmentTotal.present) {
      map['installment_total'] = Variable<int>(installmentTotal.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('amountIsEstimate: $amountIsEstimate, ')
          ..write('dueDate: $dueDate, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('recurrence: $recurrence, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('reminderMinuteOfDay: $reminderMinuteOfDay, ')
          ..write('notes: $notes, ')
          ..write('paymentUrl: $paymentUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('currency: $currency, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('cardColor: $cardColor, ')
          ..write('installmentTotal: $installmentTotal, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(AppSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> dueDate =
      GeneratedColumn<String>(
        'due_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($PaymentsTable.$converterdueDate);
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    billId,
    dueDate,
    paidAt,
    amount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      )!,
      dueDate: $PaymentsTable.$converterdueDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date'],
        )!,
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdueDate =
      const LocalDateConverter();
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final String billId;

  /// The due date of the period that was paid.
  final LocalDate dueDate;
  final DateTime paidAt;

  /// Whole rupiah, copied from the bill at payment time.
  final int? amount;
  final DateTime createdAt;
  const PaymentRow({
    required this.id,
    required this.billId,
    required this.dueDate,
    required this.paidAt,
    this.amount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bill_id'] = Variable<String>(billId);
    {
      map['due_date'] = Variable<String>(
        $PaymentsTable.$converterdueDate.toSql(dueDate),
      );
    }
    map['paid_at'] = Variable<DateTime>(paidAt);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      billId: Value(billId),
      dueDate: Value(dueDate),
      paidAt: Value(paidAt),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      billId: serializer.fromJson<String>(json['billId']),
      dueDate: serializer.fromJson<LocalDate>(json['dueDate']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      amount: serializer.fromJson<int?>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'billId': serializer.toJson<String>(billId),
      'dueDate': serializer.toJson<LocalDate>(dueDate),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'amount': serializer.toJson<int?>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentRow copyWith({
    String? id,
    String? billId,
    LocalDate? dueDate,
    DateTime? paidAt,
    Value<int?> amount = const Value.absent(),
    DateTime? createdAt,
  }) => PaymentRow(
    id: id ?? this.id,
    billId: billId ?? this.billId,
    dueDate: dueDate ?? this.dueDate,
    paidAt: paidAt ?? this.paidAt,
    amount: amount.present ? amount.value : this.amount,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      billId: data.billId.present ? data.billId.value : this.billId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('dueDate: $dueDate, ')
          ..write('paidAt: $paidAt, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, billId, dueDate, paidAt, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.billId == this.billId &&
          other.dueDate == this.dueDate &&
          other.paidAt == this.paidAt &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<String> billId;
  final Value<LocalDate> dueDate;
  final Value<DateTime> paidAt;
  final Value<int?> amount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.billId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String billId,
    required LocalDate dueDate,
    required DateTime paidAt,
    this.amount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       billId = Value(billId),
       dueDate = Value(dueDate),
       paidAt = Value(paidAt),
       createdAt = Value(createdAt);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<String>? billId,
    Expression<String>? dueDate,
    Expression<DateTime>? paidAt,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billId != null) 'bill_id': billId,
      if (dueDate != null) 'due_date': dueDate,
      if (paidAt != null) 'paid_at': paidAt,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? billId,
    Value<LocalDate>? dueDate,
    Value<DateTime>? paidAt,
    Value<int?>? amount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(
        $PaymentsTable.$converterdueDate.toSql(dueDate.value),
      );
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('dueDate: $dueDate, ')
          ..write('paidAt: $paidAt, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarLinksTable extends CalendarLinks
    with TableInfo<$CalendarLinksTable, CalendarLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id)',
    ),
  );
  static const VerificationMeta _calendarIdMeta = const VerificationMeta(
    'calendarId',
  );
  @override
  late final GeneratedColumn<String> calendarId = GeneratedColumn<String>(
    'calendar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> dueDate =
      GeneratedColumn<String>(
        'due_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($CalendarLinksTable.$converterdueDate);
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    billId,
    calendarId,
    eventId,
    dueDate,
    fingerprint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarLinkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('calendar_id')) {
      context.handle(
        _calendarIdMeta,
        calendarId.isAcceptableOrUnknown(data['calendar_id']!, _calendarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_calendarIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {billId};
  @override
  CalendarLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarLinkRow(
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      )!,
      calendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      dueDate: $CalendarLinksTable.$converterdueDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date'],
        )!,
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
    );
  }

  @override
  $CalendarLinksTable createAlias(String alias) {
    return $CalendarLinksTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdueDate =
      const LocalDateConverter();
}

class CalendarLinkRow extends DataClass implements Insertable<CalendarLinkRow> {
  final String billId;
  final String calendarId;
  final String eventId;

  /// The due date the event was created for.
  final LocalDate dueDate;

  /// Hash of the event's contents; a change means the event is stale.
  final String fingerprint;
  const CalendarLinkRow({
    required this.billId,
    required this.calendarId,
    required this.eventId,
    required this.dueDate,
    required this.fingerprint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bill_id'] = Variable<String>(billId);
    map['calendar_id'] = Variable<String>(calendarId);
    map['event_id'] = Variable<String>(eventId);
    {
      map['due_date'] = Variable<String>(
        $CalendarLinksTable.$converterdueDate.toSql(dueDate),
      );
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    return map;
  }

  CalendarLinksCompanion toCompanion(bool nullToAbsent) {
    return CalendarLinksCompanion(
      billId: Value(billId),
      calendarId: Value(calendarId),
      eventId: Value(eventId),
      dueDate: Value(dueDate),
      fingerprint: Value(fingerprint),
    );
  }

  factory CalendarLinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarLinkRow(
      billId: serializer.fromJson<String>(json['billId']),
      calendarId: serializer.fromJson<String>(json['calendarId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      dueDate: serializer.fromJson<LocalDate>(json['dueDate']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'billId': serializer.toJson<String>(billId),
      'calendarId': serializer.toJson<String>(calendarId),
      'eventId': serializer.toJson<String>(eventId),
      'dueDate': serializer.toJson<LocalDate>(dueDate),
      'fingerprint': serializer.toJson<String>(fingerprint),
    };
  }

  CalendarLinkRow copyWith({
    String? billId,
    String? calendarId,
    String? eventId,
    LocalDate? dueDate,
    String? fingerprint,
  }) => CalendarLinkRow(
    billId: billId ?? this.billId,
    calendarId: calendarId ?? this.calendarId,
    eventId: eventId ?? this.eventId,
    dueDate: dueDate ?? this.dueDate,
    fingerprint: fingerprint ?? this.fingerprint,
  );
  CalendarLinkRow copyWithCompanion(CalendarLinksCompanion data) {
    return CalendarLinkRow(
      billId: data.billId.present ? data.billId.value : this.billId,
      calendarId: data.calendarId.present
          ? data.calendarId.value
          : this.calendarId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarLinkRow(')
          ..write('billId: $billId, ')
          ..write('calendarId: $calendarId, ')
          ..write('eventId: $eventId, ')
          ..write('dueDate: $dueDate, ')
          ..write('fingerprint: $fingerprint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(billId, calendarId, eventId, dueDate, fingerprint);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarLinkRow &&
          other.billId == this.billId &&
          other.calendarId == this.calendarId &&
          other.eventId == this.eventId &&
          other.dueDate == this.dueDate &&
          other.fingerprint == this.fingerprint);
}

class CalendarLinksCompanion extends UpdateCompanion<CalendarLinkRow> {
  final Value<String> billId;
  final Value<String> calendarId;
  final Value<String> eventId;
  final Value<LocalDate> dueDate;
  final Value<String> fingerprint;
  final Value<int> rowid;
  const CalendarLinksCompanion({
    this.billId = const Value.absent(),
    this.calendarId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarLinksCompanion.insert({
    required String billId,
    required String calendarId,
    required String eventId,
    required LocalDate dueDate,
    required String fingerprint,
    this.rowid = const Value.absent(),
  }) : billId = Value(billId),
       calendarId = Value(calendarId),
       eventId = Value(eventId),
       dueDate = Value(dueDate),
       fingerprint = Value(fingerprint);
  static Insertable<CalendarLinkRow> custom({
    Expression<String>? billId,
    Expression<String>? calendarId,
    Expression<String>? eventId,
    Expression<String>? dueDate,
    Expression<String>? fingerprint,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (billId != null) 'bill_id': billId,
      if (calendarId != null) 'calendar_id': calendarId,
      if (eventId != null) 'event_id': eventId,
      if (dueDate != null) 'due_date': dueDate,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarLinksCompanion copyWith({
    Value<String>? billId,
    Value<String>? calendarId,
    Value<String>? eventId,
    Value<LocalDate>? dueDate,
    Value<String>? fingerprint,
    Value<int>? rowid,
  }) {
    return CalendarLinksCompanion(
      billId: billId ?? this.billId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      dueDate: dueDate ?? this.dueDate,
      fingerprint: fingerprint ?? this.fingerprint,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (calendarId.present) {
      map['calendar_id'] = Variable<String>(calendarId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(
        $CalendarLinksTable.$converterdueDate.toSql(dueDate.value),
      );
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarLinksCompanion(')
          ..write('billId: $billId, ')
          ..write('calendarId: $calendarId, ')
          ..write('eventId: $eventId, ')
          ..write('dueDate: $dueDate, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRatesTable extends CachedRates
    with TableInfo<$CachedRatesTable, ExchangeRateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idrPerUnitMeta = const VerificationMeta(
    'idrPerUnit',
  );
  @override
  late final GeneratedColumn<double> idrPerUnit = GeneratedColumn<double>(
    'idr_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> rateDate =
      GeneratedColumn<String>(
        'rate_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($CachedRatesTable.$converterrateDate);
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    currency,
    idrPerUnit,
    rateDate,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('idr_per_unit')) {
      context.handle(
        _idrPerUnitMeta,
        idrPerUnit.isAcceptableOrUnknown(
          data['idr_per_unit']!,
          _idrPerUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idrPerUnitMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {currency};
  @override
  ExchangeRateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateRow(
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      idrPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}idr_per_unit'],
      )!,
      rateDate: $CachedRatesTable.$converterrateDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rate_date'],
        )!,
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedRatesTable createAlias(String alias) {
    return $CachedRatesTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterrateDate =
      const LocalDateConverter();
}

class ExchangeRateRow extends DataClass implements Insertable<ExchangeRateRow> {
  final String currency;
  final double idrPerUnit;

  /// Publication date of the rate (yyyy-MM-dd).
  final LocalDate rateDate;
  final DateTime fetchedAt;
  const ExchangeRateRow({
    required this.currency,
    required this.idrPerUnit,
    required this.rateDate,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['currency'] = Variable<String>(currency);
    map['idr_per_unit'] = Variable<double>(idrPerUnit);
    {
      map['rate_date'] = Variable<String>(
        $CachedRatesTable.$converterrateDate.toSql(rateDate),
      );
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedRatesCompanion toCompanion(bool nullToAbsent) {
    return CachedRatesCompanion(
      currency: Value(currency),
      idrPerUnit: Value(idrPerUnit),
      rateDate: Value(rateDate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ExchangeRateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateRow(
      currency: serializer.fromJson<String>(json['currency']),
      idrPerUnit: serializer.fromJson<double>(json['idrPerUnit']),
      rateDate: serializer.fromJson<LocalDate>(json['rateDate']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'currency': serializer.toJson<String>(currency),
      'idrPerUnit': serializer.toJson<double>(idrPerUnit),
      'rateDate': serializer.toJson<LocalDate>(rateDate),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ExchangeRateRow copyWith({
    String? currency,
    double? idrPerUnit,
    LocalDate? rateDate,
    DateTime? fetchedAt,
  }) => ExchangeRateRow(
    currency: currency ?? this.currency,
    idrPerUnit: idrPerUnit ?? this.idrPerUnit,
    rateDate: rateDate ?? this.rateDate,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ExchangeRateRow copyWithCompanion(CachedRatesCompanion data) {
    return ExchangeRateRow(
      currency: data.currency.present ? data.currency.value : this.currency,
      idrPerUnit: data.idrPerUnit.present
          ? data.idrPerUnit.value
          : this.idrPerUnit,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateRow(')
          ..write('currency: $currency, ')
          ..write('idrPerUnit: $idrPerUnit, ')
          ..write('rateDate: $rateDate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(currency, idrPerUnit, rateDate, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateRow &&
          other.currency == this.currency &&
          other.idrPerUnit == this.idrPerUnit &&
          other.rateDate == this.rateDate &&
          other.fetchedAt == this.fetchedAt);
}

class CachedRatesCompanion extends UpdateCompanion<ExchangeRateRow> {
  final Value<String> currency;
  final Value<double> idrPerUnit;
  final Value<LocalDate> rateDate;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedRatesCompanion({
    this.currency = const Value.absent(),
    this.idrPerUnit = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRatesCompanion.insert({
    required String currency,
    required double idrPerUnit,
    required LocalDate rateDate,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : currency = Value(currency),
       idrPerUnit = Value(idrPerUnit),
       rateDate = Value(rateDate),
       fetchedAt = Value(fetchedAt);
  static Insertable<ExchangeRateRow> custom({
    Expression<String>? currency,
    Expression<double>? idrPerUnit,
    Expression<String>? rateDate,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (currency != null) 'currency': currency,
      if (idrPerUnit != null) 'idr_per_unit': idrPerUnit,
      if (rateDate != null) 'rate_date': rateDate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRatesCompanion copyWith({
    Value<String>? currency,
    Value<double>? idrPerUnit,
    Value<LocalDate>? rateDate,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedRatesCompanion(
      currency: currency ?? this.currency,
      idrPerUnit: idrPerUnit ?? this.idrPerUnit,
      rateDate: rateDate ?? this.rateDate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (idrPerUnit.present) {
      map['idr_per_unit'] = Variable<double>(idrPerUnit.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<String>(
        $CachedRatesTable.$converterrateDate.toSql(rateDate.value),
      );
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRatesCompanion(')
          ..write('currency: $currency, ')
          ..write('idrPerUnit: $idrPerUnit, ')
          ..write('rateDate: $rateDate, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $CalendarLinksTable calendarLinks = $CalendarLinksTable(this);
  late final $CachedRatesTable cachedRates = $CachedRatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bills,
    appSettings,
    payments,
    calendarLinks,
    cachedRates,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$BillsTableCreateCompanionBuilder = BillsCompanion Function({
  required String id,
  required String name,
  required BillCategory category,
  Value<int?> amount,
  Value<bool> amountIsEstimate,
  required LocalDate dueDate,
  required int anchorDay,
  required RecurrenceType recurrence,
  Value<int> intervalMonths,
  Value<List<int>?> reminderOffsets,
  Value<int?> reminderMinuteOfDay,
  Value<String?> notes,
  Value<String?> paymentUrl,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> snoozedUntil,
  Value<String> currency,
  Value<int?> originalAmountMinor,
  Value<int?> cardColor,
  Value<int?> installmentTotal,
  Value<int?> installmentNumber,
  Value<int> rowid,
});
typedef $$BillsTableUpdateCompanionBuilder = BillsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<BillCategory> category,
  Value<int?> amount,
  Value<bool> amountIsEstimate,
  Value<LocalDate> dueDate,
  Value<int> anchorDay,
  Value<RecurrenceType> recurrence,
  Value<int> intervalMonths,
  Value<List<int>?> reminderOffsets,
  Value<int?> reminderMinuteOfDay,
  Value<String?> notes,
  Value<String?> paymentUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> snoozedUntil,
  Value<String> currency,
  Value<int?> originalAmountMinor,
  Value<int?> cardColor,
  Value<int?> installmentTotal,
  Value<int?> installmentNumber,
  Value<int> rowid,
});

final class $$BillsTableReferences
    extends BaseReferences<_$AppDatabase, $BillsTable, BillRow> {
  $$BillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'bills__id__payments__bill_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.billId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CalendarLinksTable, List<CalendarLinkRow>>
  _calendarLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarLinks,
    aliasName: 'bills__id__calendar_links__bill_id',
  );

  $$CalendarLinksTableProcessedTableManager get calendarLinksRefs {
    final manager = $$CalendarLinksTableTableManager(
      $_db,
      $_db.calendarLinks,
    ).filter((f) => f.billId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BillCategory, BillCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get amountIsEstimate => $composableBuilder(
    column: $table.amountIsEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get dueDate =>
      $composableBuilder(
        column: $table.dueDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecurrenceType, RecurrenceType, String>
  get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>?, List<int>, String>
  get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get reminderMinuteOfDay => $composableBuilder(
    column: $table.reminderMinuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentUrl => $composableBuilder(
    column: $table.paymentUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardColor => $composableBuilder(
    column: $table.cardColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentTotal => $composableBuilder(
    column: $table.installmentTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> calendarLinksRefs(
    Expression<bool> Function($$CalendarLinksTableFilterComposer f) f,
  ) {
    final $$CalendarLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableFilterComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get amountIsEstimate => $composableBuilder(
    column: $table.amountIsEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinuteOfDay => $composableBuilder(
    column: $table.reminderMinuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentUrl => $composableBuilder(
    column: $table.paymentUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardColor => $composableBuilder(
    column: $table.cardColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentTotal => $composableBuilder(
    column: $table.installmentTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BillCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get amountIsEstimate => $composableBuilder(
    column: $table.amountIsEstimate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get anchorDay =>
      $composableBuilder(column: $table.anchorDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurrenceType, String> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumn<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>?, String> get reminderOffsets =>
      $composableBuilder(
        column: $table.reminderOffsets,
        builder: (column) => column,
      );

  GeneratedColumn<int> get reminderMinuteOfDay => $composableBuilder(
    column: $table.reminderMinuteOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get paymentUrl => $composableBuilder(
    column: $table.paymentUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardColor =>
      $composableBuilder(column: $table.cardColor, builder: (column) => column);

  GeneratedColumn<int> get installmentTotal => $composableBuilder(
    column: $table.installmentTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> calendarLinksRefs<T extends Object>(
    Expression<T> Function($$CalendarLinksTableAnnotationComposer a) f,
  ) {
    final $$CalendarLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          BillRow,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (BillRow, $$BillsTableReferences),
          BillRow,
          PrefetchHooks Function({bool paymentsRefs, bool calendarLinksRefs})
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<BillCategory> category = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<bool> amountIsEstimate = const Value.absent(),
                Value<LocalDate> dueDate = const Value.absent(),
                Value<int> anchorDay = const Value.absent(),
                Value<RecurrenceType> recurrence = const Value.absent(),
                Value<int> intervalMonths = const Value.absent(),
                Value<List<int>?> reminderOffsets = const Value.absent(),
                Value<int?> reminderMinuteOfDay = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> paymentUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<int?> cardColor = const Value.absent(),
                Value<int?> installmentTotal = const Value.absent(),
                Value<int?> installmentNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                name: name,
                category: category,
                amount: amount,
                amountIsEstimate: amountIsEstimate,
                dueDate: dueDate,
                anchorDay: anchorDay,
                recurrence: recurrence,
                intervalMonths: intervalMonths,
                reminderOffsets: reminderOffsets,
                reminderMinuteOfDay: reminderMinuteOfDay,
                notes: notes,
                paymentUrl: paymentUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                snoozedUntil: snoozedUntil,
                currency: currency,
                originalAmountMinor: originalAmountMinor,
                cardColor: cardColor,
                installmentTotal: installmentTotal,
                installmentNumber: installmentNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required BillCategory category,
                Value<int?> amount = const Value.absent(),
                Value<bool> amountIsEstimate = const Value.absent(),
                required LocalDate dueDate,
                required int anchorDay,
                required RecurrenceType recurrence,
                Value<int> intervalMonths = const Value.absent(),
                Value<List<int>?> reminderOffsets = const Value.absent(),
                Value<int?> reminderMinuteOfDay = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> paymentUrl = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<int?> cardColor = const Value.absent(),
                Value<int?> installmentTotal = const Value.absent(),
                Value<int?> installmentNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                name: name,
                category: category,
                amount: amount,
                amountIsEstimate: amountIsEstimate,
                dueDate: dueDate,
                anchorDay: anchorDay,
                recurrence: recurrence,
                intervalMonths: intervalMonths,
                reminderOffsets: reminderOffsets,
                reminderMinuteOfDay: reminderMinuteOfDay,
                notes: notes,
                paymentUrl: paymentUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                snoozedUntil: snoozedUntil,
                currency: currency,
                originalAmountMinor: originalAmountMinor,
                cardColor: cardColor,
                installmentTotal: installmentTotal,
                installmentNumber: installmentNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BillsTable, BillRow>(table),
                  $$BillsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({paymentsRefs = false, calendarLinksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsRefs) db.payments,
                    if (calendarLinksRefs) db.calendarLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          BillRow,
                          $BillsTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$BillsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.billId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (calendarLinksRefs)
                        await $_getPrefetchedData<
                          BillRow,
                          $BillsTable,
                          CalendarLinkRow
                        >(
                          currentTable: table,
                          referencedTable: $$BillsTableReferences
                              ._calendarLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillsTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.billId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      BillRow,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (BillRow, $$BillsTableReferences),
      BillRow,
      PrefetchHooks Function({bool paymentsRefs, bool calendarLinksRefs})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          SettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      SettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String billId,
  required LocalDate dueDate,
  required DateTime paidAt,
  Value<int?> amount,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> billId,
  Value<LocalDate> dueDate,
  Value<DateTime> paidAt,
  Value<int?> amount,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BillsTable _billIdTable(_$AppDatabase db) =>
      db.bills.createAlias('payments__bill_id__bills__id');

  $$BillsTableProcessedTableManager get billId {
    final $_column = $_itemColumn<String>('bill_id')!;

    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_billIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get dueDate =>
      $composableBuilder(
        column: $table.dueDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BillsTableAnnotationComposer get billId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool billId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> billId = const Value.absent(),
                Value<LocalDate> dueDate = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                billId: billId,
                dueDate: dueDate,
                paidAt: paidAt,
                amount: amount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String billId,
                required LocalDate dueDate,
                required DateTime paidAt,
                Value<int?> amount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                billId: billId,
                dueDate: dueDate,
                paidAt: paidAt,
                amount: amount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, PaymentRow>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({billId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (billId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.billId,
                        referencedTable: $$PaymentsTableReferences._billIdTable(
                          db,
                        ),
                        referencedColumn: $$PaymentsTableReferences
                            ._billIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool billId})
    >;
typedef $$CalendarLinksTableCreateCompanionBuilder =
    CalendarLinksCompanion Function({
      required String billId,
      required String calendarId,
      required String eventId,
      required LocalDate dueDate,
      required String fingerprint,
      Value<int> rowid,
    });
typedef $$CalendarLinksTableUpdateCompanionBuilder =
    CalendarLinksCompanion Function({
      Value<String> billId,
      Value<String> calendarId,
      Value<String> eventId,
      Value<LocalDate> dueDate,
      Value<String> fingerprint,
      Value<int> rowid,
    });

final class $$CalendarLinksTableReferences
    extends
        BaseReferences<_$AppDatabase, $CalendarLinksTable, CalendarLinkRow> {
  $$CalendarLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BillsTable _billIdTable(_$AppDatabase db) =>
      db.bills.createAlias('calendar_links__bill_id__bills__id');

  $$BillsTableProcessedTableManager get billId {
    final $_column = $_itemColumn<String>('bill_id')!;

    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_billIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CalendarLinksTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarLinksTable> {
  $$CalendarLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get dueDate =>
      $composableBuilder(
        column: $table.dueDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarLinksTable> {
  $$CalendarLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarLinksTable> {
  $$CalendarLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  $$BillsTableAnnotationComposer get billId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarLinksTable,
          CalendarLinkRow,
          $$CalendarLinksTableFilterComposer,
          $$CalendarLinksTableOrderingComposer,
          $$CalendarLinksTableAnnotationComposer,
          $$CalendarLinksTableCreateCompanionBuilder,
          $$CalendarLinksTableUpdateCompanionBuilder,
          (CalendarLinkRow, $$CalendarLinksTableReferences),
          CalendarLinkRow,
          PrefetchHooks Function({bool billId})
        > {
  $$CalendarLinksTableTableManager(_$AppDatabase db, $CalendarLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> billId = const Value.absent(),
                Value<String> calendarId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<LocalDate> dueDate = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarLinksCompanion(
                billId: billId,
                calendarId: calendarId,
                eventId: eventId,
                dueDate: dueDate,
                fingerprint: fingerprint,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String billId,
                required String calendarId,
                required String eventId,
                required LocalDate dueDate,
                required String fingerprint,
                Value<int> rowid = const Value.absent(),
              }) => CalendarLinksCompanion.insert(
                billId: billId,
                calendarId: calendarId,
                eventId: eventId,
                dueDate: dueDate,
                fingerprint: fingerprint,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarLinksTable, CalendarLinkRow>(table),
                  $$CalendarLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({billId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (billId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.billId,
                        referencedTable: $$CalendarLinksTableReferences
                            ._billIdTable(db),
                        referencedColumn: $$CalendarLinksTableReferences
                            ._billIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CalendarLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarLinksTable,
      CalendarLinkRow,
      $$CalendarLinksTableFilterComposer,
      $$CalendarLinksTableOrderingComposer,
      $$CalendarLinksTableAnnotationComposer,
      $$CalendarLinksTableCreateCompanionBuilder,
      $$CalendarLinksTableUpdateCompanionBuilder,
      (CalendarLinkRow, $$CalendarLinksTableReferences),
      CalendarLinkRow,
      PrefetchHooks Function({bool billId})
    >;
typedef $$CachedRatesTableCreateCompanionBuilder =
    CachedRatesCompanion Function({
      required String currency,
      required double idrPerUnit,
      required LocalDate rateDate,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedRatesTableUpdateCompanionBuilder =
    CachedRatesCompanion Function({
      Value<String> currency,
      Value<double> idrPerUnit,
      Value<LocalDate> rateDate,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedRatesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRatesTable> {
  $$CachedRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get idrPerUnit => $composableBuilder(
    column: $table.idrPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get rateDate =>
      $composableBuilder(
        column: $table.rateDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRatesTable> {
  $$CachedRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get idrPerUnit => $composableBuilder(
    column: $table.idrPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRatesTable> {
  $$CachedRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get idrPerUnit => $composableBuilder(
    column: $table.idrPerUnit,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate, String> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRatesTable,
          ExchangeRateRow,
          $$CachedRatesTableFilterComposer,
          $$CachedRatesTableOrderingComposer,
          $$CachedRatesTableAnnotationComposer,
          $$CachedRatesTableCreateCompanionBuilder,
          $$CachedRatesTableUpdateCompanionBuilder,
          (
            ExchangeRateRow,
            BaseReferences<_$AppDatabase, $CachedRatesTable, ExchangeRateRow>,
          ),
          ExchangeRateRow,
          PrefetchHooks Function()
        > {
  $$CachedRatesTableTableManager(_$AppDatabase db, $CachedRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> currency = const Value.absent(),
                Value<double> idrPerUnit = const Value.absent(),
                Value<LocalDate> rateDate = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRatesCompanion(
                currency: currency,
                idrPerUnit: idrPerUnit,
                rateDate: rateDate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String currency,
                required double idrPerUnit,
                required LocalDate rateDate,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedRatesCompanion.insert(
                currency: currency,
                idrPerUnit: idrPerUnit,
                rateDate: rateDate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedRatesTable, ExchangeRateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedRatesTable,
                    ExchangeRateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRatesTable,
      ExchangeRateRow,
      $$CachedRatesTableFilterComposer,
      $$CachedRatesTableOrderingComposer,
      $$CachedRatesTableAnnotationComposer,
      $$CachedRatesTableCreateCompanionBuilder,
      $$CachedRatesTableUpdateCompanionBuilder,
      (
        ExchangeRateRow,
        BaseReferences<_$AppDatabase, $CachedRatesTable, ExchangeRateRow>,
      ),
      ExchangeRateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$CalendarLinksTableTableManager get calendarLinks =>
      $$CalendarLinksTableTableManager(_db, _db.calendarLinks);
  $$CachedRatesTableTableManager get cachedRates =>
      $$CachedRatesTableTableManager(_db, _db.cachedRates);
}
