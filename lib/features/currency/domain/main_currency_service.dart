import '../../bills/domain/bill_repository.dart';
import '../../bills/domain/bill_service.dart';
import '../../payments/domain/payment_repository.dart';
import 'exchange_rate_service.dart';
import 'money.dart';

enum MainCurrencyChange { changed, unchanged, needsRates }

/// Changes the currency that totals, the budget and statistics use.
///
/// Every bill keeps its own price; only the estimate in the main currency
/// is recomputed ([rebasedBill]). Payments keep the currency they were paid
/// in, so history is never rewritten. The budget is converted and rounded
/// to whole units.
class MainCurrencyService {
  MainCurrencyService({
    required this._bills,
    required this._transaction,
    required this._current,
    required this._store,
    required this._budget,
    required this._storeBudget,
    required this._rates,
    required this._clock,
    required this._onChanged,
  });

  final BillRepository _bills;
  final UnitOfWork _transaction;
  final Future<Currency> Function() _current;
  final Future<void> Function(Currency currency) _store;
  final Future<int?> Function() _budget;
  final Future<void> Function(int? minorUnits) _storeBudget;
  final Future<ExchangeRates?> Function() _rates;
  final DateTime Function() _clock;
  final OnBillsChanged _onChanged;

  Future<MainCurrencyChange> change(Currency to) async {
    final from = await _current();
    if (from == to) return MainCurrencyChange.unchanged;
    final rates = await _rates();
    final bills = await _bills.getAll();
    final budget = await _budget();

    // Converting needs both rates; refuse rather than lose amounts.
    final needsRates =
        budget != null ||
        bills.any((b) => b.currency != to && (b.amount ?? 0) > 0);
    final hasRates = rates?.rateFor(from) != null && rates?.rateFor(to) != null;
    if (needsRates && !hasRates) return MainCurrencyChange.needsRates;

    await _transaction(() async {
      final now = _clock().toUtc();
      for (final bill in bills) {
        final rebased = rebasedBill(bill, from: from, to: to, rates: rates);
        await _bills.save(rebased.copyWith(updatedAt: now));
      }
      if (budget != null) {
        await _storeBudget(
          convertBudget(budget, from: from, to: to, rates: rates!),
        );
      }
      await _store(to);
      return null;
    });
    await _onChanged();
    return MainCurrencyChange.changed;
  }
}

/// [budget] in [to], rounded to whole units (a budget is a round target,
/// not an exact amount). Never below one unit.
int convertBudget(
  int budget, {
  required Currency from,
  required Currency to,
  required ExchangeRates rates,
}) {
  final converted = rates.convert(budget, from, to) ?? budget;
  final units = (converted / to.minorPerUnit).round();
  return (units < 1 ? 1 : units) * to.minorPerUnit;
}
