import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:b4due/features/payments/data/drift_payment_repository.dart';
import 'package:b4due/features/payments/domain/pay_bill.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

void main() {
  late AppDatabase db;
  late DriftBillRepository bills;
  late DriftPaymentRepository payments;
  late PayBill payBill;
  late SnoozeBill snooze;
  late int changes;
  final now = DateTime.utc(2026, 8, 20, 2, 30, 45);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    bills = DriftBillRepository(db);
    payments = DriftPaymentRepository(db);
    changes = 0;
    Future<void> onChanged() async => changes++;
    var ids = 0;
    payBill = PayBill(
      bills: bills,
      payments: payments,
      transaction: db.writeTransaction,
      clock: () => now,
      onChanged: onChanged,
      newId: () => 'pay-${ids++}',
    );
    snooze = SnoozeBill(bills: bills, clock: () => now, onChanged: onChanged);
  });

  tearDown(() => db.close());

  test('records the payment and moves a monthly bill on', () async {
    await bills.save(
      testBill('pln', due: LocalDate(2026, 8, 31), amount: 487500),
    );

    final result = await payBill('pln');

    expect(result.outcome, PayOutcome.paid);
    final bill = (await bills.findById('pln'))!;
    expect(bill.dueDate, LocalDate(2026, 9, 30));
    expect(bill.anchorDay, 31);
    final recorded = await payments.getAll();
    expect(recorded.single.dueDate, LocalDate(2026, 8, 31));
    expect(recorded.single.amount, 487500);
    expect(recorded.single.paidAt, now);
    expect(changes, 1);
  });

  test('archives a one-off bill', () async {
    await bills.save(
      testBill(
        'once',
        due: LocalDate(2026, 8, 20),
        recurrence: const Recurrence.once(),
      ),
    );

    final result = await payBill('once');

    expect(result.outcome, PayOutcome.archived);
    final bill = (await bills.findById('once'))!;
    expect(bill.isArchived, isTrue);
    expect(bill.dueDate, LocalDate(2026, 8, 20));
    expect(await bills.getActive(), isEmpty);
  });

  group('instalment plan', () {
    Future<void> saveKpr({required int number, int total = 60}) => bills.save(
      testBill('kpr', due: LocalDate(2026, 8, 25), amount: 4250000).copyWith(
        installmentTotal: () => total,
        installmentNumber: () => number,
      ),
    );

    test('paying moves to the next instalment', () async {
      await saveKpr(number: 13);

      final result = await payBill('kpr');

      expect(result.outcome, PayOutcome.paid);
      final bill = (await bills.findById('kpr'))!;
      expect(bill.installmentNumber, 14);
      expect(bill.installmentsLeft, 47);
      expect(bill.dueDate, LocalDate(2026, 9, 25));
      expect(bill.isActive, isTrue);
    });

    test('the last instalment finishes the plan', () async {
      await saveKpr(number: 60);

      final result = await payBill('kpr');

      expect(result.outcome, PayOutcome.archived);
      final bill = (await bills.findById('kpr'))!;
      expect(bill.isArchived, isTrue);
      expect(bill.installmentNumber, 60);
      expect(await payments.getAll(), hasLength(1));
    });

    test('undo puts the instalment number back', () async {
      await saveKpr(number: 13);

      final result = await payBill('kpr');
      await payBill.undo(result);

      final bill = (await bills.findById('kpr'))!;
      expect(bill.installmentNumber, 13);
      expect(bill.dueDate, LocalDate(2026, 8, 25));
      expect(await payments.getAll(), isEmpty);
    });
  });

  test('paying twice for the same period records one payment', () async {
    await bills.save(testBill('pln', due: LocalDate(2026, 8, 20)));

    final first = await payBill('pln', expectedDueDate: LocalDate(2026, 8, 20));
    final second = await payBill(
      'pln',
      expectedDueDate: LocalDate(2026, 8, 20),
    );

    expect(first.outcome, PayOutcome.paid);
    expect(second.outcome, PayOutcome.alreadyHandled);
    expect(await payments.getAll(), hasLength(1));
    expect((await bills.findById('pln'))!.dueDate, LocalDate(2026, 9, 20));
    expect(changes, 1);
  });

  test('ignores deleted bills and unknown ids', () async {
    await bills.save(testBill('gone', due: LocalDate(2026, 8, 20)));
    await bills.softDelete('gone', at: now);

    expect((await payBill('gone')).outcome, PayOutcome.alreadyHandled);
    expect((await payBill('missing')).outcome, PayOutcome.alreadyHandled);
    expect(await payments.getAll(), isEmpty);
  });

  test('undo restores the bill and removes the payment', () async {
    await bills.save(testBill('pln', due: LocalDate(2026, 8, 20)));
    final result = await payBill('pln');

    await payBill.undo(result);

    expect((await bills.findById('pln'))!.dueDate, LocalDate(2026, 8, 20));
    expect(await payments.getAll(), isEmpty);
  });

  test(
    'snooze sets a whole-minute time one day ahead; paying clears it',
    () async {
      await bills.save(testBill('pln', due: LocalDate(2026, 8, 20)));

      expect(
        await snooze('pln', expectedDueDate: LocalDate(2026, 8, 20)),
        isTrue,
      );
      expect(
        (await bills.findById('pln'))!.snoozedUntil,
        DateTime.utc(2026, 8, 21, 2, 30),
      );

      await payBill('pln');
      expect((await bills.findById('pln'))!.snoozedUntil, isNull);
    },
  );

  test('snooze for a stale period is ignored', () async {
    await bills.save(testBill('pln', due: LocalDate(2026, 9, 20)));
    expect(
      await snooze('pln', expectedDueDate: LocalDate(2026, 8, 20)),
      isFalse,
    );
    expect((await bills.findById('pln'))!.snoozedUntil, isNull);
  });
}
