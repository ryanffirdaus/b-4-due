import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/database/app_database.dart';
import '../../../core/format/formatters.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/data/drift_bill_repository.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../currency/data/exchange_rate_data.dart';
import '../../currency/domain/money.dart';
import '../../home/domain/home_summary.dart';
import '../../payments/data/drift_payment_repository.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/widget_snapshot.dart';

/// The Android widget class (android/.../BillWidgetProvider.kt).
const billWidgetAndroidName = 'io.github.ryanffirdaus.b4due.BillWidgetProvider';

/// Where a tap on the widget leads: a bill, or Beranda.
abstract final class WidgetLinks {
  static const scheme = 'b4due';

  static Uri bill(String id) => Uri(scheme: scheme, host: 'bill', path: '/$id');

  static final home = Uri(scheme: scheme, host: 'home');

  /// The bill id in a widget link, or null for Beranda.
  static String? billId(Uri? uri) {
    if (uri == null || uri.scheme != scheme || uri.host != 'bill') {
      return null;
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty);
    return segments.isEmpty ? null : segments.first;
  }
}

/// The widget link the app was opened from, if any (Android only).
Future<Uri?> launchedFromHomeWidget() async {
  if (kIsWeb || !Platform.isAndroid) return null;
  try {
    return await HomeWidget.initiallyLaunchedFromHomeWidget();
  } on Object {
    return null;
  }
}

/// Taps on the widget while the app is already running.
Stream<Uri?> homeWidgetTaps() => kIsWeb || !Platform.isAndroid
    ? const Stream.empty()
    : HomeWidget.widgetClicked;

/// Every value the widget layout reads, by key. Plain strings so the native
/// side only places them.
Map<String, Object> widgetFields(
  AppLocalizations l10n,
  WidgetSnapshot snapshot,
  LocalDate today, {
  Currency main = idr,
}) {
  final format = Formatters.cached(l10n.localeName);
  String money(int minor) => format.money(main, minor);
  final next = snapshot.next;
  return {
    'title': l10n.homeLeftThisMonth,
    'remaining': money(snapshot.remaining),
    'paidOf':
        '${l10n.homePaidShort(money(snapshot.paid))} · '
        '${l10n.homeOfTotal(money(snapshot.total))}',
    'percent': snapshot.percentPaid,
    'hasNext': next != null,
    'nextName': next?.name ?? '',
    'nextDue': next == null ? '' : relativeDueLabel(l10n, next.dueDate, today),
    'nextOverdue': next != null && next.dueDate.isBefore(today),
    'nextPrice': next == null
        ? ''
        : billPrice(l10n, format, next, main: main) ?? '',
    'nextLink': (next == null ? WidgetLinks.home : WidgetLinks.bill(next.id))
        .toString(),
    'empty': l10n.homeNoUpcoming,
  };
}

/// Pushes the current numbers to the home-screen widget. Safe to call from
/// any isolate (UI, workmanager, notification actions); does nothing off
/// Android or when no widget is placed.
class HomeWidgetGateway {
  HomeWidgetGateway(this._l10n);

  final AppLocalizations _l10n;

  Future<void> refresh(AppDatabase db, LocalDate today) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final bills = await DriftBillRepository(db).getActive();
      final payments = await DriftPaymentRepository(db)
          .watchForDueMonth(today.year, today.month)
          .first;
      final main = await SettingsRepository(db).mainCurrency();
      final rates = await DriftExchangeRateStore(db).load();
      final snapshot = WidgetSnapshot.from(
        HomeSummary.build(
          bills: bills,
          today: today,
          paymentsThisMonth: payments,
          money: MoneyConverter(main, rates),
        ),
      );
      for (final MapEntry(:key, :value) in widgetFields(
        _l10n,
        snapshot,
        today,
        main: main,
      ).entries) {
        await HomeWidget.saveWidgetData<Object>(key, value);
      }
      await HomeWidget.updateWidget(
        qualifiedAndroidName: billWidgetAndroidName,
      );
    } on Object catch (error) {
      // The widget is a convenience; never let it break a sync.
      debugPrint('Home widget refresh failed: $error');
    }
  }
}
