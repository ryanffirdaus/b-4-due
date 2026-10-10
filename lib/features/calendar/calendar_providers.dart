import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/device_channel.dart';
import '../../core/providers.dart';
import 'data/calendar_wiring.dart';
import 'data/drift_calendar_link_repository.dart';
import 'data/eventide_calendar_gateway.dart';
import 'domain/calendar_gateway.dart';
import 'domain/calendar_sync.dart';

final calendarGatewayProvider = Provider<CalendarGateway>(
  (ref) => EventideCalendarGateway(const DeviceChannel()),
);

final calendarSyncProvider = Provider<CalendarSync>(
  (ref) => buildCalendarSync(ref.watch(databaseProvider)),
);

final calendarLinkProvider = StreamProvider.family<CalendarLink?, String>(
  (ref, billId) =>
      DriftCalendarLinkRepository(ref.watch(databaseProvider)).watch(billId),
);
