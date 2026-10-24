import 'package:csv/csv.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../bills/domain/bill.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../currency/domain/money.dart';
import '../domain/backup_codec.dart';

/// Two spreadsheet-friendly files: bills and payment history.
class CsvExport {
  const CsvExport({required this.bills, required this.payments});

  final String bills;
  final String payments;
}

/// Builds the CSV export with localized headers and labels. Dates are ISO
/// (`2026-08-17`) so spreadsheets sort and parse them reliably.
CsvExport buildCsvExport(
  BackupData data,
  AppLocalizations l10n, {
  Currency main = idr,
}) {
  final names = {for (final b in data.bills) b.id: b.name};
  // Semicolons and a BOM: opens correctly in Excel with Indonesian regional
  // settings, where the comma is the decimal separator.
  final csv = Csv.excel();

  final bills = csv.encode([
    [
      l10n.csvName,
      l10n.csvCategory,
      l10n.csvAmount(main.code),
      l10n.csvCurrency,
      l10n.csvEstimate,
      l10n.csvDueDate,
      l10n.csvRecurrence,
      l10n.csvStatus,
      l10n.csvNotes,
      l10n.csvPaymentUrl,
    ],
    for (final b in data.bills.where((b) => !b.isDeleted))
      [
        b.name,
        b.category.label(l10n),
        _plain(b.amount, main),
        b.currency.code,
        b.amountIsEstimate || b.isForeign ? l10n.csvYes : '',
        b.dueDate.toIso(),
        b.recurrence.label(l10n),
        _status(l10n, b),
        b.notes ?? '',
        b.paymentUrl ?? '',
      ],
  ]);

  final payments = csv.encode([
    [
      l10n.csvName,
      l10n.csvPeriod,
      l10n.csvPaidOn,
      l10n.detailAmount,
      l10n.csvCurrency,
    ],
    for (final p in data.payments)
      [
        names[p.billId] ?? '',
        p.dueDate.toIso(),
        p.paidAt.toLocal().toIso8601String().substring(0, 10),
        _plain(p.amount, p.currency),
        p.currency.code,
      ],
  ]);

  return CsvExport(bills: bills, payments: payments);
}

/// A spreadsheet number: `150000` for rupiah, `20.5` for US\$20.50.
Object _plain(int? minorUnits, Currency currency) {
  if (minorUnits == null) return '';
  if (currency.decimals == 0) return minorUnits;
  return minorUnits / currency.minorPerUnit;
}

String _status(AppLocalizations l10n, Bill b) =>
    b.isArchived ? l10n.csvStatusDone : l10n.csvStatusActive;
