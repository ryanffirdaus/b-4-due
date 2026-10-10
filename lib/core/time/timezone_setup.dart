import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Used when the device reports a zone the database does not know.
const fallbackTimeZone = 'Asia/Jakarta';

/// Loads the time zone database and points `tz.local` at the device's zone.
/// Safe to call more than once and from any isolate.
Future<tz.Location> configureLocalTimeZone() async {
  tzdata.initializeTimeZones();
  var name = fallbackTimeZone;
  try {
    name = (await FlutterTimezone.getLocalTimezone()).identifier;
  } on Object catch (error) {
    debugPrint('Could not read device time zone, using $name: $error');
  }
  tz.Location location;
  try {
    location = tz.getLocation(name);
  } on tz.LocationNotFoundException {
    location = tz.getLocation(fallbackTimeZone);
  }
  tz.setLocalLocation(location);
  return location;
}
