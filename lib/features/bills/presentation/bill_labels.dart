import 'package:flutter/widgets.dart';

import '../../../core/format/formatters.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../currency/domain/money.dart';
import '../../currency/presentation/main_currency_scope.dart';
import '../domain/bill.dart';
import '../domain/bill_category.dart';
import '../domain/recurrence.dart';

extension BillCategoryUi on BillCategory {
  IconData get icon => switch (this) {
    BillCategory.electricity => RemixIcons.flashlightLine,
    BillCategory.water => RemixIcons.dropLine,
    BillCategory.internet => RemixIcons.wifiLine,
    BillCategory.phone => RemixIcons.smartphoneLine,
    BillCategory.health => RemixIcons.shieldCrossLine,
    BillCategory.vehicleTax => RemixIcons.motorbikeLine,
    BillCategory.installment => RemixIcons.bankCardLine,
    BillCategory.insurance => RemixIcons.shieldCheckLine,
    BillCategory.subscription => RemixIcons.playCircleLine,
    BillCategory.housing => RemixIcons.home4Line,
    BillCategory.education => RemixIcons.graduationCapLine,
    BillCategory.other => RemixIcons.fileList3Line,
  };

  /// Index into [Palette.walletCards] used when a bill has no colour of
  /// its own.
  int get defaultCardColor => switch (this) {
    BillCategory.electricity => 4,
    BillCategory.water => 3,
    BillCategory.internet => 7,
    BillCategory.phone => 0,
    BillCategory.health => 2,
    BillCategory.vehicleTax => 5,
    BillCategory.installment => 6,
    BillCategory.insurance => 1,
    BillCategory.subscription => 0,
    BillCategory.housing => 1,
    BillCategory.education => 3,
    BillCategory.other => 5,
  };

  String label(AppLocalizations l10n) => switch (this) {
    BillCategory.electricity => l10n.categoryElectricity,
    BillCategory.water => l10n.categoryWater,
    BillCategory.internet => l10n.categoryInternet,
    BillCategory.phone => l10n.categoryPhone,
    BillCategory.health => l10n.categoryHealth,
    BillCategory.vehicleTax => l10n.categoryVehicleTax,
    BillCategory.installment => l10n.categoryInstallment,
    BillCategory.insurance => l10n.categoryInsurance,
    BillCategory.subscription => l10n.categorySubscription,
    BillCategory.housing => l10n.categoryHousing,
    BillCategory.education => l10n.categoryEducation,
    BillCategory.other => l10n.categoryOther,
  };
}

extension RecurrenceUi on Recurrence {
  String label(AppLocalizations l10n) => switch (type) {
    RecurrenceType.once => l10n.recurrenceOnce,
    RecurrenceType.monthly => l10n.recurrenceMonthly,
    RecurrenceType.yearly => l10n.recurrenceYearly,
    RecurrenceType.every5Years => l10n.recurrenceEvery5Years,
    RecurrenceType.everyNMonths => l10n.recurrenceEveryNMonths(intervalMonths),
  };
}

/// "Hari ini", "Besok", "3 hari lagi", "Terlambat 2 hari".
String relativeDueLabel(AppLocalizations l10n, LocalDate due, LocalDate today) {
  final days = due.differenceInDays(today);
  if (days < 0) return l10n.overdueByDays(-days);
  if (days == 0) return l10n.dueToday;
  if (days == 1) return l10n.dueTomorrow;
  return l10n.dueInDays(days);
}

/// "H-7" or "Hari-H".
String offsetLabel(AppLocalizations l10n, int days) =>
    days == 0 ? l10n.offsetDueDay : l10n.offsetDays(days);

/// "H-7, H-3, H-1, Hari-H, pukul 09.00".
String remindersSummary(
  AppLocalizations l10n,
  Formatters format,
  List<int> offsets,
  int minuteOfDay,
) {
  final sorted = [...offsets]..sort((a, b) => b.compareTo(a));
  return l10n.remindersSummary(
    sorted.map((o) => offsetLabel(l10n, o)).join(', '),
    format.timeOfDay(minuteOfDay),
  );
}

/// Access to [Formatters] and the main currency for the current context.
extension FormattersContext on BuildContext {
  Formatters get formatters =>
      Formatters.cached(Localizations.localeOf(this).toLanguageTag());

  /// The currency of totals, the budget and statistics.
  Currency get mainCurrency => MainCurrencyScope.of(this);

  /// [minorUnits] of the main currency: `Rp 150.000`, `US$12.50`.
  String money(int minorUnits) => formatters.money(mainCurrency, minorUnits);
}

/// `Rp 150.000`, `Rp 487.500 (perkiraan)` or `US$20,00 ≈ Rp 357.611`.
String? billPrice(
  AppLocalizations l10n,
  Formatters format,
  Bill bill, {
  Currency main = idr,
}) => format.price(
  currency: bill.currency,
  amount: bill.amount,
  originalMinor: bill.originalAmountMinor,
  isEstimate: bill.amountIsEstimate,
  estimateLabel: l10n.detailAmountEstimate,
  main: main,
);

/// The wallet-card colours at [index], or the [category]'s own when the
/// index is null or out of range.
WalletCardColors walletCardColors(int? index, BillCategory category) {
  const cards = Palette.walletCards;
  final i = index != null && index >= 0 && index < cards.length
      ? index
      : category.defaultCardColor;
  return cards[i];
}

extension BillCardColors on Bill {
  WalletCardColors get cardColors => walletCardColors(cardColor, category);
}

/// Spoken names of [Palette.walletCards], in order.
List<String> cardColorNames(AppLocalizations l10n) => [
  l10n.cardColorViolet,
  l10n.cardColorGreen,
  l10n.cardColorRed,
  l10n.cardColorBlue,
  l10n.cardColorOrange,
  l10n.cardColorSlate,
  l10n.cardColorMagenta,
  l10n.cardColorTeal,
];
