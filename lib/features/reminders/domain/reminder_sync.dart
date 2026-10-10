import 'package:timezone/timezone.dart' as tz;

import '../../bills/domain/bill.dart';
import '../../bills/domain/bill_repository.dart';
import 'notification_gateway.dart';
import 'reminder_planner.dart';
import 'reminder_settings.dart';

typedef NotificationTextBuilder = NotificationText Function(
  PlannedNotification plan,
  Bill bill,
);

/// Result of one sync, for logging and tests.
class ReminderSyncResult {
  const ReminderSyncResult({required this.scheduled, required this.cancelled});

  final int scheduled;
  final int cancelled;

  @override
  String toString() => 'scheduled $scheduled, cancelled $cancelled';
}

/// Makes the OS's pending notifications match [planNotifications].
///
/// Idempotent: IDs are deterministic, scheduling an existing ID replaces it,
/// and anything pending that is no longer planned is cancelled. Run it after
/// every data change, on app start, after restore and from the daily
/// background task; running it twice changes nothing.
class ReminderSync {
  ReminderSync({
    required this._bills,
    required this._settings,
    required this._gateway,
    required this._textFor,
    required this._now,
    this._policy = SchedulePolicy.android,
  });

  final BillRepository _bills;
  final Future<ReminderSettings> Function() _settings;
  final NotificationGateway _gateway;
  final NotificationTextBuilder _textFor;
  final tz.TZDateTime Function() _now;
  final SchedulePolicy _policy;

  Future<ReminderSyncResult>? _running;
  var _rerunRequested = false;

  /// Coalesces concurrent calls: while a sync runs, further calls schedule a
  /// single follow-up run instead of interleaving platform calls.
  Future<ReminderSyncResult> sync() {
    final running = _running;
    if (running != null) {
      _rerunRequested = true;
      return running;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<ReminderSyncResult> _loop() async {
    ReminderSyncResult result;
    do {
      _rerunRequested = false;
      result = await _syncOnce();
    } while (_rerunRequested);
    return result;
  }

  Future<ReminderSyncResult> _syncOnce() async {
    final bills = await _bills.getActive();
    final plan = planNotifications(
      bills: bills,
      settings: await _settings(),
      now: _now(),
      policy: _policy,
    );
    final byId = {for (final b in bills) b.id: b};
    final planned = {for (final p in plan) p.id};

    var cancelled = 0;
    for (final id in await _gateway.pendingIds()) {
      if (!planned.contains(id)) {
        await _gateway.cancel(id);
        cancelled++;
      }
    }
    for (final p in plan) {
      await _gateway.schedule(p, _textFor(p, byId[p.billId]!));
    }
    return ReminderSyncResult(scheduled: plan.length, cancelled: cancelled);
  }
}
