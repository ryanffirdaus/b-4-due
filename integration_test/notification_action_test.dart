// On-device check of the notification action path with the real runtime:
// drift_flutter's shared isolate, the notification plugin, time zones and
// the "Sudah dibayar" use case. Run on an emulator or phone:
//   flutter test integration_test -d <device>
import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/bills/data/drift_bill_repository.dart';
import 'package:b4due/features/bills/domain/bill.dart';
import 'package:b4due/features/bills/domain/bill_category.dart';
import 'package:b4due/features/bills/domain/recurrence.dart';
import 'package:b4due/features/payments/data/drift_payment_repository.dart';
import 'package:b4due/features/reminders/data/notification_actions.dart';
import 'package:b4due/features/reminders/domain/notification_action_handler.dart';
import 'package:b4due/features/reminders/domain/reminder_payload.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('"Sudah dibayar" action pays once through the real runtime', (
    tester,
  ) async {
    // The "UI" connection, open the whole time like the running app's.
    final ui = AppDatabase.open();
    await ui.delete(ui.payments).go();
    await ui.delete(ui.bills).go();

    final today = LocalDate.fromDateTime(DateTime.now());
    final due = today.addDays(3);
    final now = DateTime.now().toUtc();
    await DriftBillRepository(ui).save(
      Bill(
        id: 'integration-pln',
        name: 'Listrik PLN',
        category: BillCategory.electricity,
        dueDate: due,
        anchorDay: due.day,
        recurrence: const Recurrence.monthly(),
        amount: 150000,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final response = NotificationResponse(
      notificationResponseType:
          NotificationResponseType.selectedNotificationAction,
      actionId: ReminderActions.markPaid,
      payload: ReminderPayload(
        billId: 'integration-pln',
        dueDate: due,
      ).encode(),
    );

    // Delivered twice, as can happen with a double tap.
    await onBackgroundNotificationResponse(response);
    await onBackgroundNotificationResponse(response);

    final bill = await DriftBillRepository(ui).findById('integration-pln');
    expect(bill!.dueDate, due.addMonths(1));
    final payments = await DriftPaymentRepository(ui).getAll();
    expect(payments, hasLength(1));
    expect(payments.single.dueDate, due);

    await ui.delete(ui.payments).go();
    await ui.delete(ui.bills).go();
    await ui.close();
  });
}
