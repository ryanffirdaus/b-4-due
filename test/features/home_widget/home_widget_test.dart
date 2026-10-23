import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/domain/bill.dart';
import 'package:b4due/features/home/domain/home_summary.dart';
import 'package:b4due/features/home_widget/data/home_widget_gateway.dart';
import 'package:b4due/features/home_widget/domain/widget_snapshot.dart';
import 'package:b4due/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../support/fixtures.dart';

void main() {
  final today = LocalDate(2026, 8, 10);
  final l10n = lookupAppLocalizations(const Locale('id'));

  setUpAll(() => initializeDateFormatting('id'));

  WidgetSnapshot snapshotFor(List<Bill> bills) =>
      WidgetSnapshot.from(HomeSummary.build(bills: bills, today: today));

  test('the most urgent bill comes first: overdue before due today', () {
    final snapshot = snapshotFor([
      testBill('pln', due: LocalDate(2026, 8, 10), amount: 487500),
      testBill('bpjs', due: LocalDate(2026, 8, 8), amount: 150000),
      testBill('wifi', due: LocalDate(2026, 8, 20), amount: 330000),
    ]);
    expect(snapshot.next?.id, 'bpjs');
    expect(snapshot.total, snapshot.remaining);
  });

  test(
    'fields carry the remaining total, countdown and a link to the bill',
    () {
      final fields = widgetFields(
        l10n,
        snapshotFor([
          testBill('bpjs', due: LocalDate(2026, 8, 8), amount: 150000),
        ]),
        today,
      );
      expect(fields['title'], 'Sisa tagihan bulan ini');
      expect(fields['remaining'], 'Rp 150.000');
      expect(fields['hasNext'], isTrue);
      expect(fields['nextDue'], 'Terlambat 2 hari');
      expect(fields['nextOverdue'], isTrue);
      expect(fields['nextPrice'], 'Rp 150.000');
      expect(
        WidgetLinks.billId(Uri.parse(fields['nextLink']! as String)),
        'bpjs',
      );
    },
  );

  test('no bills: an empty message and a link to Beranda', () {
    final fields = widgetFields(l10n, snapshotFor(const []), today);
    expect(fields['hasNext'], isFalse);
    expect(fields['percent'], 0);
    expect(
      WidgetLinks.billId(Uri.parse(fields['nextLink']! as String)),
      isNull,
    );
    expect(fields['empty'], isNotEmpty);
  });

  test('widget links round-trip and ignore anything else', () {
    expect(WidgetLinks.billId(WidgetLinks.bill('a-b-c')), 'a-b-c');
    expect(WidgetLinks.billId(WidgetLinks.home), isNull);
    expect(WidgetLinks.billId(Uri.parse('https://example.org/bill/x')), isNull);
    expect(WidgetLinks.billId(null), isNull);
  });
}
