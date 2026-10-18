import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/providers.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/presentation/bill_form_screen.dart';
import 'package:b4due/features/bills/presentation/widgets/bill_wallet_card.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../goldens/demo_data.dart';
import '../../../support/fixtures.dart';
import '../../../support/pump_app.dart';

void main() {
  final today = LocalDate(2026, 8, 10);

  testWidgets('a wallet card shows which instalment is due', (tester) async {
    final kpr = testBill(
      'kpr',
      due: LocalDate(2026, 8, 25),
      amount: 4250000,
    ).copyWith(installmentTotal: () => 60, installmentNumber: () => 13);
    await pumpScreen(
      tester,
      Center(
        child: BillWalletCard(bill: kpr, today: today, compact: true),
      ),
      today: today,
    );
    expect(find.text('Angsuran 13 dari 60'), findsOneWidget);
  });

  testWidgets('the form asks for the plan only when it is switched on', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpScreen(
      tester,
      const BillFormScreen(templateKey: 'pln'),
      today: today,
      overrides: [...demoOverrides(), databaseProvider.overrideWithValue(db)],
    );

    expect(find.text('Cicilan dengan tenor'), findsOneWidget);
    expect(find.text('Jumlah angsuran'), findsNothing);

    await tester.ensureVisible(find.text('Cicilan dengan tenor'));
    await tester.tap(find.text('Cicilan dengan tenor'));
    await tester.pumpAndSettle();

    expect(find.text('Jumlah angsuran'), findsOneWidget);
    expect(find.text('Angsuran ke-'), findsOneWidget);
  });
}
