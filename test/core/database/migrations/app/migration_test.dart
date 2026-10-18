// Migration tests: every schema version must upgrade to every later one,
// and real user data must survive. Schema dumps live in drift_schemas/;
// regenerate helpers with `dart run drift_dev make-migrations`.
import 'package:b4due/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('schema upgrades', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from v$fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to v$toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v1 to v2 keeps bills and settings and adds empty payments', () async {
    const pln = v1.BillsData(
      id: '0b9f6a52-4d0b-4c1e-9c41-2f6d0b6f7a01',
      name: 'Listrik PLN',
      category: 'electricity',
      amount: 487500,
      amountIsEstimate: 1,
      dueDate: '2026-08-31',
      anchorDay: 31,
      recurrence: 'monthly',
      intervalMonths: 1,
      reminderOffsets: '[7,1,0]',
      reminderMinuteOfDay: 1170,
      notes: 'ID pelanggan 1234',
      paymentUrl: 'https://example.org',
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-02-01T00:00:00.000Z',
    );
    const deleted = v1.BillsData(
      id: '0b9f6a52-4d0b-4c1e-9c41-2f6d0b6f7a02',
      name: 'Langganan lama',
      category: 'subscription',
      amountIsEstimate: 0,
      dueDate: '2026-05-01',
      anchorDay: 1,
      recurrence: 'once',
      intervalMonths: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-03-01T00:00:00.000Z',
      deletedAt: '2026-03-01T00:00:00.000Z',
    );
    const setting = v1.AppSettingsData(
      key: 'reminder.minuteOfDay',
      value: '480',
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.bills, [pln, deleted])
          ..insert(oldDb.appSettings, setting);
      },
      validateItems: (newDb) async {
        final bills = await newDb.select(newDb.bills).get();
        expect(bills, hasLength(2));
        final migrated = bills.firstWhere((b) => b.id == pln.id);
        expect(migrated.name, pln.name);
        expect(migrated.amount, pln.amount);
        expect(migrated.amountIsEstimate, 1);
        expect(migrated.dueDate, pln.dueDate);
        expect(migrated.anchorDay, 31);
        expect(migrated.reminderOffsets, '[7,1,0]');
        expect(migrated.notes, pln.notes);
        expect(migrated.snoozedUntil, isNull);
        expect(
          bills.firstWhere((b) => b.id == deleted.id).deletedAt,
          deleted.deletedAt,
        );
        expect(await newDb.select(newDb.appSettings).get(), [
          const v2.AppSettingsData(key: 'reminder.minuteOfDay', value: '480'),
        ]);
        expect(await newDb.select(newDb.payments).get(), isEmpty);
      },
    );
  });

  test('v3 to v4 keeps bills as rupiah and adds an empty rate cache', () async {
    const bill = v3.BillsData(
      id: '0b9f6a52-4d0b-4c1e-9c41-2f6d0b6f7a03',
      name: 'Netflix',
      category: 'subscription',
      amount: 65000,
      amountIsEstimate: 0,
      dueDate: '2026-10-31',
      anchorDay: 31,
      recurrence: 'monthly',
      intervalMonths: 1,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.bills, bill),
      validateItems: (newDb) async {
        final migrated = (await newDb.select(newDb.bills).get()).single;
        expect(migrated.amount, 65000);
        expect(migrated.currency, 'IDR');
        expect(migrated.originalAmountMinor, isNull);
        expect(await newDb.select(newDb.cachedRates).get(), isEmpty);
      },
    );
  });

  test('v4 to v5 keeps bills and leaves their card colour to the '
      'category', () async {
    const bill = v4.BillsData(
      id: '0b9f6a52-4d0b-4c1e-9c41-2f6d0b6f7a04',
      name: 'Claude Pro',
      category: 'subscription',
      amount: 357611,
      amountIsEstimate: 0,
      dueDate: '2026-08-12',
      anchorDay: 12,
      recurrence: 'monthly',
      intervalMonths: 1,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      currency: 'USD',
      originalAmountMinor: 2000,
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.bills, bill),
      validateItems: (newDb) async {
        final migrated = (await newDb.select(newDb.bills).get()).single;
        expect(migrated.name, 'Claude Pro');
        expect(migrated.currency, 'USD');
        expect(migrated.originalAmountMinor, 2000);
        expect(migrated.cardColor, isNull);
      },
    );
  });
}
