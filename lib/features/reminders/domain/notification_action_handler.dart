import '../../payments/domain/pay_bill.dart';
import 'reminder_payload.dart';

/// Action IDs shared by Android actions and the iOS category.
abstract final class ReminderActions {
  static const markPaid = 'mark_paid';
  static const snooze = 'snooze';
}

enum ActionOutcome { paid, snoozed, ignored }

/// Turns a tapped notification action into a use case call. Free of plugin
/// code so it can run (and be tested) in any isolate.
class NotificationActionHandler {
  NotificationActionHandler({required this._payBill, required this._snooze});

  final PayBill _payBill;
  final SnoozeBill _snooze;

  Future<ActionOutcome> handle(String? actionId, String? rawPayload) async {
    final payload = ReminderPayload.tryParse(rawPayload);
    if (payload == null) return ActionOutcome.ignored;
    switch (actionId) {
      case ReminderActions.markPaid:
        final result = await _payBill(
          payload.billId,
          expectedDueDate: payload.dueDate,
        );
        return result.outcome == PayOutcome.alreadyHandled
            ? ActionOutcome.ignored
            : ActionOutcome.paid;
      case ReminderActions.snooze:
        final ok = await _snooze(
          payload.billId,
          expectedDueDate: payload.dueDate,
        );
        return ok ? ActionOutcome.snoozed : ActionOutcome.ignored;
      default:
        return ActionOutcome.ignored;
    }
  }
}
