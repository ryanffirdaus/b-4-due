import 'package:uuid/uuid.dart';

import '../../currency/domain/money.dart';
import 'bill.dart';
import 'bill_draft.dart';
import 'bill_repository.dart';

/// Called after any change that affects reminders, so they can be
/// rescheduled. Wired to the reminder sync in the app; a no-op in tests.
typedef OnBillsChanged = Future<void> Function();

/// Create, update and delete use cases for bills.
class BillService {
  BillService({
    required this._repository,
    required this._clock,
    required this._onChanged,
    String Function()? newId,
  }) : _newId = newId ?? const Uuid().v4;

  final BillRepository _repository;
  final DateTime Function() _clock;
  final OnBillsChanged _onChanged;
  final String Function() _newId;

  Future<Bill> create(BillDraft draft) async {
    _ensureValid(draft);
    final now = _clock().toUtc();
    final bill = Bill(
      id: _newId(),
      name: draft.name.trim(),
      category: draft.category,
      amount: draft.amount,
      amountIsEstimate: _isEstimate(draft),
      currency: draft.currency,
      originalAmountMinor: _original(draft),
      dueDate: draft.dueDate,
      anchorDay: draft.dueDate.day,
      recurrence: draft.recurrence,
      reminderOffsets: draft.reminderOffsets,
      reminderMinuteOfDay: draft.reminderMinuteOfDay,
      notes: _blankToNull(draft.notes),
      paymentUrl: _url(draft.paymentUrl),
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(bill);
    await _onChanged();
    return bill;
  }

  Future<Bill> update(Bill existing, BillDraft draft) async {
    _ensureValid(draft);
    // A new due date chosen by the user also becomes the new anchor day;
    // otherwise keep the original anchor (e.g. 31 while due on 28 Feb).
    final anchorDay = draft.dueDate == existing.dueDate
        ? existing.anchorDay
        : draft.dueDate.day;
    final updated = existing.copyWith(
      name: draft.name.trim(),
      category: draft.category,
      amount: () => draft.amount,
      amountIsEstimate: _isEstimate(draft),
      currency: draft.currency,
      originalAmountMinor: () => _original(draft),
      dueDate: draft.dueDate,
      anchorDay: anchorDay,
      recurrence: draft.recurrence,
      reminderOffsets: () => draft.reminderOffsets,
      reminderMinuteOfDay: () => draft.reminderMinuteOfDay,
      notes: () => _blankToNull(draft.notes),
      paymentUrl: () => _url(draft.paymentUrl),
      updatedAt: _clock().toUtc(),
    );
    await _repository.save(updated);
    await _onChanged();
    return updated;
  }

  Future<void> delete(String id) async {
    await _repository.softDelete(id, at: _clock().toUtc());
    await _onChanged();
  }

  static void _ensureValid(BillDraft draft) {
    final errors = draft.validate();
    if (errors.isNotEmpty) throw InvalidBillDraft(errors);
  }

  /// Rupiah converted from another currency is always an estimate.
  static bool _isEstimate(BillDraft draft) =>
      draft.amount != null && (draft.amountIsEstimate || draft.currency != idr);

  static int? _original(BillDraft draft) =>
      draft.currency == idr ? null : draft.originalAmountMinor;

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static String? _url(String? value) =>
      value == null ? null : BillDraft.normalizePaymentUrl(value);
}

class InvalidBillDraft implements Exception {
  InvalidBillDraft(this.errors);
  final Set<BillDraftError> errors;

  @override
  String toString() => 'InvalidBillDraft($errors)';
}
