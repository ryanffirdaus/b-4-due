import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../currency/domain/money.dart';
import 'bill.dart';
import 'bill_category.dart';
import 'recurrence.dart';

/// Problems the form can report. Mapped to localized text in the UI.
enum BillDraftError { nameEmpty, nameTooLong, amountNegative, invalidUrl }

/// What the bill form edits: a [Bill] minus identity and bookkeeping.
@immutable
class BillDraft {
  const BillDraft({
    required this.name,
    required this.category,
    required this.dueDate,
    required this.recurrence,
    this.amount,
    this.amountIsEstimate = false,
    this.currency = idr,
    this.originalAmountMinor,
    this.cardColor,
    this.reminderOffsets,
    this.reminderMinuteOfDay,
    this.notes,
    this.paymentUrl,
  });

  factory BillDraft.fromBill(Bill bill) => BillDraft(
    name: bill.name,
    category: bill.category,
    dueDate: bill.dueDate,
    recurrence: bill.recurrence,
    amount: bill.amount,
    amountIsEstimate: bill.amountIsEstimate,
    currency: bill.currency,
    originalAmountMinor: bill.originalAmountMinor,
    cardColor: bill.cardColor,
    reminderOffsets: bill.reminderOffsets,
    reminderMinuteOfDay: bill.reminderMinuteOfDay,
    notes: bill.notes,
    paymentUrl: bill.paymentUrl,
  );

  static const maxNameLength = 120;

  final String name;
  final BillCategory category;
  final LocalDate dueDate;
  final Recurrence recurrence;
  final int? amount;
  final bool amountIsEstimate;

  /// The bill's own currency; [amount] stays in rupiah (the estimate).
  final Currency currency;

  /// Price in [currency]'s minor units, for foreign-currency bills.
  final int? originalAmountMinor;

  /// Chosen wallet-card colour; null follows the category.
  final int? cardColor;
  final List<int>? reminderOffsets;
  final int? reminderMinuteOfDay;
  final String? notes;
  final String? paymentUrl;

  /// Validation problems, empty when the draft can be saved.
  Set<BillDraftError> validate() {
    final trimmed = name.trim();
    return {
      if (trimmed.isEmpty) BillDraftError.nameEmpty,
      if (trimmed.length > maxNameLength) BillDraftError.nameTooLong,
      if ((amount ?? 0) < 0 || (originalAmountMinor ?? 0) < 0)
        BillDraftError.amountNegative,
      if (paymentUrl != null &&
          paymentUrl!.trim().isNotEmpty &&
          normalizePaymentUrl(paymentUrl!) == null)
        BillDraftError.invalidUrl,
    };
  }

  /// Accepts "bayar.example.com/x" or a full http(s) URL; returns the URL to
  /// store, or null if it is not a usable web address. Other schemes are
  /// rejected so a stored link can never launch arbitrary intents.
  static String? normalizePaymentUrl(String input) {
    var text = input.trim();
    if (text.isEmpty) return null;
    if (!text.contains('://')) text = 'https://$text';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !(uri.scheme == 'https' || uri.scheme == 'http') ||
        uri.host.isEmpty ||
        !uri.host.contains('.')) {
      return null;
    }
    return uri.toString();
  }
}
