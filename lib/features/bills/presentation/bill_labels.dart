import 'package:flutter/widgets.dart';

import '../../../core/format/formatters.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
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

/// Access to [Formatters] for the current locale.
extension FormattersContext on BuildContext {
  Formatters get formatters =>
      Formatters.cached(Localizations.localeOf(this).toLanguageTag());
}

/// `Rp 150.000`, `Rp 487.500 (perkiraan)` or `US$20,00 ≈ Rp 357.611`.
String? billPrice(AppLocalizations l10n, Formatters format, Bill bill) =>
    format.price(
      currency: bill.currency,
      rupiah: bill.amount,
      originalMinor: bill.originalAmountMinor,
      isEstimate: bill.amountIsEstimate,
      estimateLabel: l10n.detailAmountEstimate,
    );
