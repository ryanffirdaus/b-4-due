import 'dart:convert';

import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../bills/domain/bill.dart';
import '../../bills/domain/bill_category.dart';
import '../../bills/domain/recurrence.dart';
import '../../currency/domain/money.dart';
import '../../payments/domain/payment.dart';

/// Everything that moves between phones.
@immutable
class BackupData {
  const BackupData({
    required this.bills,
    required this.payments,
    required this.settings,
    required this.exportedAt,
  });

  final List<Bill> bills;
  final List<Payment> payments;

  /// Only keys accepted by [BackupCodec.isPortableSetting].
  final Map<String, String> settings;
  final DateTime exportedAt;
}

/// Thrown for files that are not a usable B4Due backup. [reason] is a
/// stable code the UI maps to a friendly message.
class BackupFormatException implements Exception {
  const BackupFormatException(this.reason, [this.detail]);

  final BackupFormatError reason;
  final String? detail;

  @override
  String toString() =>
      'BackupFormatException($reason${detail == null ? '' : ': $detail'})';
}

enum BackupFormatError { notJson, notB4Due, newerVersion, invalidData }

/// JSON backup format, version 1.
///
/// The format is documented in docs/BACKUP_FORMAT.md and is independent of
/// the database schema: fields are mapped explicitly, so a schema migration
/// never silently changes what a backup contains.
abstract final class BackupCodec {
  static const formatId = 'b4due-backup';
  static const version = 1;

  /// Settings that make sense on another phone. App-lock secrets and
  /// onboarding state stay on the device they were created on.
  static bool isPortableSetting(String key) =>
      key.startsWith('reminder.') || key == 'appearance.theme';

  static String encode(BackupData data) {
    final json = {
      'format': formatId,
      'version': version,
      'exportedAt': data.exportedAt.toUtc().toIso8601String(),
      'bills': [for (final b in data.bills) _billToJson(b)],
      'payments': [for (final p in data.payments) _paymentToJson(p)],
      'settings': {
        for (final e in data.settings.entries)
          if (isPortableSetting(e.key)) e.key: e.value,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  static BackupData decode(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      throw BackupFormatException(BackupFormatError.notJson, e.message);
    }
    if (json is! Map<String, dynamic> || json['format'] != formatId) {
      throw const BackupFormatException(BackupFormatError.notB4Due);
    }
    final fileVersion = json['version'];
    if (fileVersion is! int) {
      throw const BackupFormatException(BackupFormatError.notB4Due);
    }
    if (fileVersion > version) {
      throw BackupFormatException(
        BackupFormatError.newerVersion,
        'file v$fileVersion, app reads v$version',
      );
    }
    try {
      final bills = [
        for (final b in json['bills'] as List<dynamic>)
          _billFromJson(b as Map<String, dynamic>),
      ];
      final billIds = bills.map((b) => b.id).toSet();
      final payments = [
        for (final p in json['payments'] as List<dynamic>)
          _paymentFromJson(p as Map<String, dynamic>),
      ];
      final orphan = payments.where((p) => !billIds.contains(p.billId));
      if (orphan.isNotEmpty) {
        throw FormatException(
          'payment for unknown bill ${orphan.first.billId}',
        );
      }
      final rawSettings = (json['settings'] as Map<String, dynamic>?) ?? {};
      return BackupData(
        bills: bills,
        payments: payments,
        settings: {
          for (final e in rawSettings.entries)
            if (isPortableSetting(e.key)) e.key: e.value as String,
        },
        exportedAt: DateTime.parse(json['exportedAt'] as String),
      );
    } on BackupFormatException {
      rethrow;
    } on Object catch (e) {
      // TypeError, FormatException, ArgumentError from bad field values.
      throw BackupFormatException(BackupFormatError.invalidData, '$e');
    }
  }

  static Map<String, Object?> _billToJson(Bill b) => {
    'id': b.id,
    'name': b.name,
    'category': b.category.name,
    'amount': b.amount,
    'amountIsEstimate': b.amountIsEstimate,
    'currency': b.currency.code,
    'originalAmountMinor': b.originalAmountMinor,
    'cardColor': b.cardColor,
    'dueDate': b.dueDate.toIso(),
    'anchorDay': b.anchorDay,
    'recurrence': b.recurrence.type.name,
    'intervalMonths': b.recurrence.intervalMonths,
    'reminderOffsets': b.reminderOffsets,
    'reminderMinuteOfDay': b.reminderMinuteOfDay,
    'notes': b.notes,
    'paymentUrl': b.paymentUrl,
    'createdAt': _instant(b.createdAt),
    'updatedAt': _instant(b.updatedAt),
    'archivedAt': _instantOrNull(b.archivedAt),
    'deletedAt': _instantOrNull(b.deletedAt),
    'snoozedUntil': _instantOrNull(b.snoozedUntil),
  };

  static Bill _billFromJson(Map<String, dynamic> j) {
    final name = (j['name'] as String).trim();
    if (name.isEmpty) throw const FormatException('empty bill name');
    final dueDate = LocalDate.parse(j['dueDate'] as String);
    final anchorDay = j['anchorDay'] as int;
    if (anchorDay < 1 || anchorDay > 31) {
      throw FormatException('anchorDay out of range: $anchorDay');
    }
    final type = RecurrenceType.values.byName(j['recurrence'] as String);
    final amount = j['amount'] as int?;
    if (amount != null && amount < 0) {
      throw FormatException('negative amount: $amount');
    }
    return Bill(
      id: _uuid(j['id']),
      name: name,
      category: BillCategory.fromName(j['category'] as String),
      amount: amount,
      amountIsEstimate: j['amountIsEstimate'] as bool? ?? false,
      currency: currencyByCode(j['currency'] as String? ?? 'IDR'),
      originalAmountMinor: j['originalAmountMinor'] as int?,
      cardColor: j['cardColor'] as int?,
      dueDate: dueDate,
      anchorDay: anchorDay,
      recurrence: Recurrence.fromStorage(type, j['intervalMonths'] as int?),
      reminderOffsets: (j['reminderOffsets'] as List<dynamic>?)?.cast<int>(),
      reminderMinuteOfDay: j['reminderMinuteOfDay'] as int?,
      notes: j['notes'] as String?,
      paymentUrl: j['paymentUrl'] as String?,
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
      archivedAt: _parseOrNull(j['archivedAt']),
      deletedAt: _parseOrNull(j['deletedAt']),
      snoozedUntil: _parseOrNull(j['snoozedUntil']),
    );
  }

  static Map<String, Object?> _paymentToJson(Payment p) => {
    'id': p.id,
    'billId': p.billId,
    'dueDate': p.dueDate.toIso(),
    'paidAt': _instant(p.paidAt),
    'amount': p.amount,
    'createdAt': _instant(p.createdAt),
  };

  static Payment _paymentFromJson(Map<String, dynamic> j) => Payment(
    id: _uuid(j['id']),
    billId: _uuid(j['billId']),
    dueDate: LocalDate.parse(j['dueDate'] as String),
    paidAt: DateTime.parse(j['paidAt'] as String),
    amount: j['amount'] as int?,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );

  static String _instant(DateTime t) => t.toUtc().toIso8601String();

  static String? _instantOrNull(DateTime? t) => t == null ? null : _instant(t);

  static DateTime? _parseOrNull(Object? value) =>
      value == null ? null : DateTime.parse(value as String).toUtc();

  static final _idPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  /// IDs are UUIDs in practice; accept any short, safe identifier so test
  /// fixtures and hand-made demo files still import.
  static String _uuid(Object? value) {
    final id = value as String;
    if (!_idPattern.hasMatch(id)) throw FormatException('invalid id: $id');
    return id;
  }
}
