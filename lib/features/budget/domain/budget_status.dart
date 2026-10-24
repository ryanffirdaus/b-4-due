import 'package:meta/meta.dart';

/// This month's bills measured against the monthly budget.
@immutable
class BudgetStatus {
  const BudgetStatus({required this.budget, required this.planned});

  /// The budget set in Pengaturan, in rupiah.
  final int budget;

  /// Everything due this month, paid or not (the Beranda month total).
  final int planned;

  bool get isOver => planned > budget;

  /// Room left under the budget, or how far over it is.
  int get difference => (budget - planned).abs();
}
