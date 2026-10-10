import 'dart:convert';

import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';

/// Data attached to every reminder notification and read back when the user
/// taps it or one of its actions.
@immutable
class ReminderPayload {
  const ReminderPayload({required this.billId, required this.dueDate});

  /// Returns null for missing or malformed payloads (e.g. the test
  /// notification, or one written by a future app version).
  static ReminderPayload? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderPayload(
        billId: map['billId'] as String,
        dueDate: LocalDate.parse(map['dueDate'] as String),
      );
    } on Object {
      return null;
    }
  }

  final String billId;

  /// The period the notification is about.
  final LocalDate dueDate;

  String encode() => jsonEncode({'billId': billId, 'dueDate': dueDate.toIso()});
}
