import 'dart:convert';
import 'dart:io';

import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/backup/data/backup_service.dart';
import 'package:b4due/features/backup/domain/backup_codec.dart';
import 'package:b4due/features/backup/presentation/csv_export.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:b4due/features/currency/domain/money.dart';
import 'package:b4due/features/payments/data/drift_payment_repository.dart';
import 'package:b4due/features/payments/domain/payment.dart';
import 'package:b4due/features/reminders/domain/reminder_settings.dart';
import 'package:b4due/features/security/domain/app_lock.dart';
import 'package:b4due/features/security/domain/pin_hasher.dart';
import 'package:b4due/features/settings/data/settings_repository.dart';
import 'package:b4due/features/settings/domain/theme_preference.dart';
import 'package:b4due/l10n/generated/app_localizations.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

final _exportedAt = DateTime.utc(2026, 8, 20, 3);

/// A database with every kind of row a real user could have.
Future<AppDatabase> _populated() async {
  final db = AppDatabase(NativeDatabase.memory());
  final bills = DriftBillRepository(db);
  await bills.save(
    testBill(
      'a1b2c3d4-0000-4000-8000-000000000001',
      name: 'Listrik PLN',
      due: LocalDate(2026, 8, 31),
      anchorDay: 31,
      amount: 487500,
      reminderOffsets: [14, 0],
      reminderMinuteOfDay: 19 * 60,
    ).copyWith(
      amountIsEstimate: true,
      notes: () => 'ID pelanggan 5412 "rumah"; lantai 2',
      paymentUrl: () => 'https://example.org/bayar?id=1',
      snoozedUntil: () => DateTime.utc(2026, 8, 21, 2),
      cardColor: () => 4,
      installmentTotal: () => 60,
      installmentNumber: () => 13,
    ),
  );
  await bills.save(
    testBill(
      'a1b2c3d4-0000-4000-8000-000000000002',
      name: 'Perpanjang STNK',
      category: BillCategory.vehicleTax,
      recurrence: const Recurrence.every5Years(),
      due: LocalDate(2028, 2, 29),
    ),
  );
  await bills.save(
    testBill(
      'a1b2c3d4-0000-4000-8000-000000000003',
      name: 'Kursus (lunas)',
      recurrence: const Recurrence.once(),
      due: LocalDate(2026, 7, 1),
      archivedAt: DateTime.utc(2026, 7, 1, 5),
    ),
  );
  await bills.save(
    testBill(
      'a1b2c3d4-0000-4000-8000-000000000004',
      name: 'Dihapus',
      recurrence: Recurrence.everyNMonths(3),
      due: LocalDate(2026, 9, 1),
      deletedAt: DateTime.utc(2026, 8, 1),
    ),
  );
  await bills.save(
    testBill(
      'a1b2c3d4-0000-4000-8000-000000000005',
      name: 'Claude Pro',
      category: BillCategory.subscription,
      due: LocalDate(2026, 10, 20),
      amount: 357611,
    ).copyWith(currency: usd, originalAmountMinor: () => 2000),
  );
  await DriftPaymentRepository(db).add(
    Payment(
      id: 'p0000000-0000-4000-8000-000000000001',
      billId: 'a1b2c3d4-0000-4000-8000-000000000001',
      dueDate: LocalDate(2026, 7, 31),
      paidAt: DateTime.utc(2026, 7, 30, 4, 15),
      amount: 450000,
      createdAt: DateTime.utc(2026, 7, 30, 4, 15),
    ),
  );
  final settings = SettingsRepository(db);
  await settings.saveReminderSettings(
    const ReminderSettings(defaultOffsets: [3, 0], defaultMinuteOfDay: 420),
  );
  await settings.setOnboardingCompleted(completed: true);
  await settings.saveAppLock(
    const AppLockConfig(
      pin: PinHash(hash: 'h', salt: 's', iterations: 1),
    ),
  );
  return db;
}

BackupService _service(AppDatabase db, {void Function()? onRestored}) =>
    BackupService(
      db,
      clock: () => _exportedAt,
      onRestored: () async => onRestored?.call(),
    );

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('JSON backup round trip', () {
    test(
      'export → restore into an empty phone → export is identical',
      () async {
        final source = await _populated();
        final target = AppDatabase(NativeDatabase.memory());
        var restored = false;

        final json = await _service(source).exportJson();
        final service = _service(target, onRestored: () => restored = true);
        await service.restore(service.preview(json));

        expect(await _service(target).exportJson(), json);
        expect(restored, isTrue);

        await source.close();
        await target.close();
      },
    );

    test('restoring replaces existing bills and payments', () async {
      final source = await _populated();
      final target = AppDatabase(NativeDatabase.memory());
      await DriftBillRepository(target)
          .save(testBill('old-bill', due: LocalDate(2026, 1, 1)));

      final json = await _service(source).exportJson();
      await _service(target).restore(BackupCodec.decode(json));

      final ids = (await DriftBillRepository(target).getAll()).map((b) => b.id);
      expect(ids, isNot(contains('old-bill')));
      expect(ids, hasLength(5));
      expect(await DriftPaymentRepository(target).getAll(), hasLength(1));

      await source.close();
      await target.close();
    });

    test('keeps every field, including tricky ones', () async {
      final source = await _populated();
      final data = BackupCodec.decode(await _service(source).exportJson());
      final pln = data.bills.firstWhere((b) => b.name == 'Listrik PLN');

      expect(pln.amount, 487500);
      expect(pln.amountIsEstimate, isTrue);
      expect(pln.anchorDay, 31);
      expect(pln.reminderOffsets, [14, 0]);
      expect(pln.reminderMinuteOfDay, 19 * 60);
      expect(pln.notes, 'ID pelanggan 5412 "rumah"; lantai 2');
      expect(pln.snoozedUntil, DateTime.utc(2026, 8, 21, 2));
      expect(pln.cardColor, 4);
      expect(pln.installmentTotal, 60);
      expect(pln.installmentNumber, 13);
      expect(
        data.bills.firstWhere((b) => b.name == 'Perpanjang STNK').cardColor,
        isNull,
      );
      final stnk = data.bills.firstWhere((b) => b.name == 'Perpanjang STNK');
      expect(stnk.dueDate, LocalDate(2028, 2, 29));
      expect(stnk.recurrence, const Recurrence.every5Years());
      expect(
        data.bills.firstWhere((b) => b.name == 'Dihapus').recurrence,
        Recurrence.everyNMonths(3),
      );
      expect(
        data.bills.firstWhere((b) => b.name == 'Dihapus').isDeleted,
        isTrue,
      );
      expect(data.payments.single.paidAt, DateTime.utc(2026, 7, 30, 4, 15));
      final claude = data.bills.firstWhere((b) => b.name == 'Claude Pro');
      expect(claude.currency, usd);
      expect(claude.originalAmountMinor, 2000);
      expect(claude.amount, 357611);
      await source.close();
    });

    test('app lock and onboarding state never leave the phone', () async {
      final source = await _populated();
      final json = await _service(source).exportJson();
      expect(json, isNot(contains('lock.')));
      expect(json, isNot(contains('onboarding')));
      expect(
        BackupCodec.decode(json).settings.keys,
        unorderedEquals(['reminder.offsets', 'reminder.minuteOfDay']),
      );

      // Restoring onto a locked phone keeps that phone's PIN.
      final target = await _populated();
      await _service(target).restore(BackupCodec.decode(json));
      expect((await SettingsRepository(target).getAppLock()).enabled, isTrue);
      await source.close();
      await target.close();
    });

    test(
      'the theme travels, but an older file keeps the current one',
      () async {
        final source = await _populated();
        await SettingsRepository(source)
            .setThemePreference(ThemePreference.dark);
        final json = await _service(source).exportJson();
        expect(
          BackupCodec.decode(json).settings['appearance.theme'],
          ThemePreference.dark.name,
        );

        final target = await _populated();
        await _service(target).restore(BackupCodec.decode(json));
        expect(
          await SettingsRepository(target).getThemePreference(),
          ThemePreference.dark,
        );

        // A backup made before themes existed leaves the choice alone.
        final older = BackupCodec.decode(json);
        final withoutTheme = BackupData(
          bills: older.bills,
          payments: older.payments,
          settings: {
            for (final e in older.settings.entries)
              if (e.key != 'appearance.theme') e.key: e.value,
          },
          exportedAt: older.exportedAt,
        );
        await SettingsRepository(target)
            .setThemePreference(ThemePreference.light);
        await _service(target).restore(withoutTheme);
        expect(
          await SettingsRepository(target).getThemePreference(),
          ThemePreference.light,
        );
        await source.close();
        await target.close();
      },
    );
  });

  group('BackupCodec.decode rejects bad files', () {
    Future<Map<String, dynamic>> valid() async {
      final db = await _populated();
      final json = await _service(db).exportJson();
      await db.close();
      return jsonDecode(json) as Map<String, dynamic>;
    }

    Matcher failsWith(BackupFormatError reason) => throwsA(
      isA<BackupFormatException>().having((e) => e.reason, 'reason', reason),
    );

    test('non-JSON and foreign JSON', () {
      expect(
        () => BackupCodec.decode('PK\u0003\u0004'),
        failsWith(BackupFormatError.notJson),
      );
      expect(
        () => BackupCodec.decode('[]'),
        failsWith(BackupFormatError.notB4Due),
      );
      expect(
        () => BackupCodec.decode('{"format":"other","version":1}'),
        failsWith(BackupFormatError.notB4Due),
      );
    });

    test('files from a newer app version', () async {
      final json = await valid()
        ..['version'] = BackupCodec.version + 1;
      expect(
        () => BackupCodec.decode(jsonEncode(json)),
        failsWith(BackupFormatError.newerVersion),
      );
    });

    test('invalid values', () async {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (j) => _first(j, 'bills')['dueDate'] = '2026-02-30',
        (j) => _first(j, 'bills')['recurrence'] = 'weekly',
        (j) => _first(j, 'bills')['anchorDay'] = 42,
        (j) => _first(j, 'bills')['amount'] = -1,
        (j) => _first(j, 'bills')['name'] = '   ',
        (j) => _first(j, 'bills')['id'] = '../../etc',
        (j) => _first(j, 'payments')['billId'] = 'nonexistent',
        (j) => j.remove('bills'),
      ]) {
        final json = await valid();
        mutate(json);
        expect(
          () => BackupCodec.decode(jsonEncode(json)),
          failsWith(BackupFormatError.invalidData),
        );
      }
    });

    test(
      'unknown categories fall back to "other" instead of failing',
      () async {
        final json = await valid();
        _first(json, 'bills')['category'] = 'spaceship';
        final data = BackupCodec.decode(jsonEncode(json));
        expect(data.bills.first.category, BillCategory.other);
      },
    );
  });

  test('demo backup in demo/ imports cleanly', () async {
    // Keeps the published sample file in sync with the format.
    final file = await rootBundleSafeRead('demo/contoh-cadangan.json');
    if (file == null) return; // Added in the docs step.
    final data = BackupCodec.decode(file);
    expect(data.bills, isNotEmpty);
  });

  test('CSV export: Excel-friendly with localized headers', () async {
    final db = await _populated();
    final data = await _service(db).collect();
    final l10n = lookupAppLocalizations(const Locale('id'));
    final csv = buildCsvExport(data, l10n);

    expect(csv.bills.startsWith('﻿'), isTrue, reason: 'UTF-8 BOM');
    final lines = csv.bills.substring(1).trim().split('\r\n');
    expect(lines.first, startsWith('Nama;Kategori;Nominal (Rp);'));
    // Deleted bills are left out; archived ones are marked done.
    expect(lines, hasLength(1 + 4));
    expect(
      csv.bills,
      contains('Listrik PLN;Listrik;487500;Ya;2026-08-31;Bulanan;Aktif'),
    );
    expect(csv.bills, contains('"ID pelanggan 5412 ""rumah""; lantai 2"'));
    expect(csv.bills, contains('Kursus (lunas)'));
    expect(csv.bills, contains('Selesai'));
    expect(csv.payments, contains('Listrik PLN;2026-07-31;2026-07-30;450000'));
    await db.close();
  });
}

Map<String, dynamic> _first(Map<String, dynamic> json, String key) =>
    (json[key] as List<dynamic>).first as Map<String, dynamic>;

/// Reads a repo file relative to the project root, or null if missing.
Future<String?> rootBundleSafeRead(String path) async {
  try {
    return await File(path).readAsString();
  } on FileSystemException {
    return null;
  }
}
