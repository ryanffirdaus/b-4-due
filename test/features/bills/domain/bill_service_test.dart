import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/domain/bill_draft.dart';
import 'package:b4due/features/bills/domain/bill_service.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBillRepository repo;
  late BillService service;
  late int changeCount;
  var now = DateTime.utc(2026, 8, 1, 2);

  BillDraft draft({
    String name = 'Listrik PLN',
    LocalDate? due,
    String? url,
    int? amount,
  }) => BillDraft(
    name: name,
    category: BillCategory.electricity,
    dueDate: due ?? LocalDate(2026, 8, 20),
    recurrence: const Recurrence.monthly(),
    amount: amount,
    paymentUrl: url,
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftBillRepository(db);
    changeCount = 0;
    var ids = 0;
    service = BillService(
      repository: repo,
      clock: () => now,
      onChanged: () async => changeCount++,
      newId: () => 'id-${ids++}',
    );
  });

  tearDown(() => db.close());

  test('create trims input, sets the anchor day and notifies', () async {
    final bill = await service.create(
      draft(
        name: '  Listrik PLN  ',
        due: LocalDate(2026, 8, 31),
        url: 'pln.co.id',
      ),
    );
    expect(bill.id, 'id-0');
    expect(bill.name, 'Listrik PLN');
    expect(bill.anchorDay, 31);
    expect(bill.paymentUrl, 'https://pln.co.id');
    expect(bill.amountIsEstimate, isFalse);
    expect(changeCount, 1);
    expect(await repo.findById('id-0'), isNotNull);
  });

  test('update keeps the anchor day unless the due date changes', () async {
    final created = await service.create(draft(due: LocalDate(2026, 1, 31)));
    // Simulate the bill having rolled to February (clamped to the 28th).
    final rolled = created.copyWith(dueDate: LocalDate(2026, 2, 28));
    await repo.save(rolled);

    now = now.add(const Duration(days: 1));
    final renamed = await service.update(
      rolled,
      BillDraft.fromBill(rolled).copyWithName('PLN rumah'),
    );
    expect(renamed.anchorDay, 31);
    expect(renamed.updatedAt, now);

    final moved = await service.update(
      renamed,
      BillDraft.fromBill(renamed).copyWithDue(LocalDate(2026, 3, 15)),
    );
    expect(moved.anchorDay, 15);
  });

  test('rejects invalid drafts without saving', () async {
    expect(
      () => service.create(draft(name: '   ')),
      throwsA(isA<InvalidBillDraft>()),
    );
    expect(
      () => service.create(draft(url: 'javascript:alert(1)')),
      throwsA(isA<InvalidBillDraft>()),
    );
    expect(await repo.getAll(), isEmpty);
    expect(changeCount, 0);
  });

  test('delete is a soft delete and notifies', () async {
    final bill = await service.create(draft());
    await service.delete(bill.id);
    expect(await repo.getActive(), isEmpty);
    expect((await repo.findById(bill.id))!.isDeleted, isTrue);
    expect(changeCount, 2);
  });

  group('instalment plan validation', () {
    BillDraft plan({
      int? total,
      int? number,
      Recurrence recurrence = const Recurrence.monthly(),
    }) => BillDraft(
      name: 'KPR',
      category: BillCategory.installment,
      dueDate: LocalDate(2026, 8, 25),
      recurrence: recurrence,
      installmentTotal: total,
      installmentNumber: number,
    );

    test('accepts no plan, or a number within the total', () {
      expect(plan().validate(), isEmpty);
      expect(plan(total: 60, number: 1).validate(), isEmpty);
      expect(plan(total: 60, number: 60).validate(), isEmpty);
    });

    test('rejects half a plan, numbers out of range and one-off bills', () {
      const error = BillDraftError.installmentsInvalid;
      expect(plan(total: 60).validate(), contains(error));
      expect(plan(total: 60, number: 0).validate(), contains(error));
      expect(plan(total: 60, number: 61).validate(), contains(error));
      expect(plan(total: 0, number: 0).validate(), contains(error));
      expect(
        plan(
          total: 3,
          number: 1,
          recurrence: const Recurrence.once(),
        ).validate(),
        contains(error),
      );
    });

    test('create and update keep the plan', () async {
      final bill = await service.create(plan(total: 60, number: 13));
      expect((await repo.findById(bill.id))!.installmentNumber, 13);
      await service.update(bill, plan());
      expect((await repo.findById(bill.id))!.hasInstallments, isFalse);
    });
  });

  group('BillDraft.normalizePaymentUrl', () {
    test('accepts web addresses', () {
      expect(
        BillDraft.normalizePaymentUrl('https://bayar.example.id/x?y=1'),
        'https://bayar.example.id/x?y=1',
      );
      expect(BillDraft.normalizePaymentUrl('example.id'), 'https://example.id');
    });

    test('rejects other schemes and junk', () {
      expect(BillDraft.normalizePaymentUrl('intent://foo#Intent;end'), isNull);
      expect(BillDraft.normalizePaymentUrl('file:///sdcard/x'), isNull);
      expect(BillDraft.normalizePaymentUrl('not a url'), isNull);
      expect(BillDraft.normalizePaymentUrl('localhost'), isNull);
    });
  });
}

extension on BillDraft {
  BillDraft copyWithName(String name) => BillDraft(
    name: name,
    category: category,
    dueDate: dueDate,
    recurrence: recurrence,
    amount: amount,
  );

  BillDraft copyWithDue(LocalDate due) => BillDraft(
    name: name,
    category: category,
    dueDate: due,
    recurrence: recurrence,
    amount: amount,
  );
}
