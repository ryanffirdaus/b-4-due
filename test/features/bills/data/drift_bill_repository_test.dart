import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/bills/domain/bill.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBillRepository repo;
  final now = DateTime.utc(2026, 8, 1, 9);

  Bill bill(String id, {required LocalDate due, String name = 'Listrik'}) =>
      Bill(
        id: id,
        name: name,
        category: BillCategory.electricity,
        dueDate: due,
        anchorDay: due.day,
        recurrence: const Recurrence.monthly(),
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftBillRepository(db);
  });

  tearDown(() => db.close());

  test('saves and reads back every field', () async {
    final original = Bill(
      id: '7f0c2c1e-0000-4000-8000-000000000001',
      name: 'Pajak motor',
      category: BillCategory.vehicleTax,
      amount: 350000,
      amountIsEstimate: true,
      dueDate: LocalDate(2026, 9, 30),
      anchorDay: 31,
      recurrence: Recurrence.everyNMonths(3),
      reminderOffsets: const [14, 1],
      reminderMinuteOfDay: 19 * 60 + 30,
      notes: 'Bawa STNK',
      paymentUrl: 'https://example.org/bayar',
      cardColor: 6,
      createdAt: now,
      updatedAt: now,
    );
    await repo.save(original);

    final loaded = (await repo.findById(original.id))!;
    expect(loaded.name, original.name);
    expect(loaded.category, original.category);
    expect(loaded.amount, 350000);
    expect(loaded.amountIsEstimate, isTrue);
    expect(loaded.dueDate, LocalDate(2026, 9, 30));
    expect(loaded.anchorDay, 31);
    expect(loaded.recurrence, Recurrence.everyNMonths(3));
    expect(loaded.reminderOffsets, [14, 1]);
    expect(loaded.reminderMinuteOfDay, 19 * 60 + 30);
    expect(loaded.notes, 'Bawa STNK');
    expect(loaded.paymentUrl, 'https://example.org/bayar');
    expect(loaded.cardColor, 6);
    expect(loaded.createdAt.isAtSameMomentAs(now), isTrue);
  });

  test('save replaces an existing bill with the same id', () async {
    await repo.save(bill('a', due: LocalDate(2026, 8, 20)));
    await repo.save(bill('a', due: LocalDate(2026, 9, 20), name: 'PLN'));

    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.single.name, 'PLN');
    expect(all.single.dueDate, LocalDate(2026, 9, 20));
  });

  test(
    'active bills are sorted by due date and exclude deleted/archived',
    () async {
      await repo.save(bill('late', due: LocalDate(2026, 9, 1)));
      await repo.save(bill('soon', due: LocalDate(2026, 8, 5)));
      await repo.save(bill('gone', due: LocalDate(2026, 8, 2)));
      await repo.save(
        bill(
          'paid',
          due: LocalDate(2026, 8, 3),
        ).copyWith(archivedAt: () => now),
      );
      await repo.softDelete('gone', at: now);

      final active = await repo.getActive();
      expect(active.map((b) => b.id), ['soon', 'late']);

      // Soft-deleted rows are kept for history and backups.
      final deleted = await repo.findById('gone');
      expect(deleted!.isDeleted, isTrue);
      expect(await repo.getAll(), hasLength(4));
    },
  );

  test('watchActive emits on changes', () async {
    final emissions = repo.watchActive().map((l) => l.length);
    final expectation = expectLater(emissions, emitsInOrder([0, 1, 0]));

    await pumpEventQueue();
    await repo.save(bill('a', due: LocalDate(2026, 8, 20)));
    await pumpEventQueue();
    await repo.softDelete('a', at: now);

    await expectation;
  });
}
