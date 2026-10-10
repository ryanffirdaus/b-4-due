import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/bills/data/drift_bill_repository.dart';
import '../features/bills/domain/bill.dart';
import '../features/bills/domain/bill_repository.dart';
import '../features/bills/domain/bill_service.dart';
import '../features/payments/data/drift_payment_repository.dart';
import '../features/payments/domain/pay_bill.dart';
import '../features/payments/domain/payment.dart';
import '../features/payments/domain/payment_repository.dart';
import '../features/reminders/domain/reminder_settings.dart';
import '../features/settings/data/settings_repository.dart';
import 'database/app_database.dart';
import 'time/local_date.dart';

/// Overridden in `main` (and in tests) with the opened database.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Source of "now". Overridden in tests and golden tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today's date in the device's time zone. Invalidated when the app resumes
/// so it rolls over after midnight.
final todayProvider = Provider<LocalDate>(
  (ref) => LocalDate.fromDateTime(ref.watch(clockProvider)()),
);

final billRepositoryProvider = Provider<BillRepository>(
  (ref) => DriftBillRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

/// Hook that keeps scheduled reminders in sync after data changes.
/// Replaced with the real implementation once reminders are wired up.
final onBillsChangedProvider = Provider<OnBillsChanged>((ref) => () async {});

final billServiceProvider = Provider<BillService>(
  (ref) => BillService(
    repository: ref.watch(billRepositoryProvider),
    clock: ref.watch(clockProvider),
    onChanged: ref.watch(onBillsChangedProvider),
  ),
);

final activeBillsProvider = StreamProvider<List<Bill>>(
  (ref) => ref.watch(billRepositoryProvider).watchActive(),
);

final billByIdProvider = FutureProvider.family<Bill?, String>((ref, id) {
  // Re-read whenever the active list changes (edit, pay, delete).
  ref.watch(activeBillsProvider);
  return ref.watch(billRepositoryProvider).findById(id);
});

final reminderSettingsProvider = StreamProvider<ReminderSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watchReminderSettings(),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => DriftPaymentRepository(ref.watch(databaseProvider)),
);

final payBillProvider = Provider<PayBill>((ref) {
  final db = ref.watch(databaseProvider);
  return PayBill(
    bills: ref.watch(billRepositoryProvider),
    payments: ref.watch(paymentRepositoryProvider),
    transaction: db.writeTransaction,
    clock: ref.watch(clockProvider),
    onChanged: ref.watch(onBillsChangedProvider),
  );
});

final paymentHistoryProvider = StreamProvider<List<PaymentEntry>>(
  (ref) => ref.watch(paymentRepositoryProvider).watchHistory(),
);

/// Payments for periods due in the current month (for the home total).
final paymentsThisMonthProvider = StreamProvider<List<Payment>>((ref) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(paymentRepositoryProvider)
      .watchForDueMonth(today.year, today.month);
});
