import 'dart:convert';

/// IDs that the planner must never hand out.
abstract final class ReservedNotificationIds {
  /// "Test notification now" in settings and onboarding.
  static const test = 1;

  static bool contains(int id) => id == 0 || id == test;
}

/// FNV-1a over the UTF-8 bytes of [key], folded to a positive 31-bit int.
///
/// Android notification IDs are Java ints and must be stable across runs and
/// isolates, which rules out `String.hashCode`.
int stableNotificationId(String key) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(key)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

/// Assigns a unique ID to every key, deterministically.
///
/// Keys are processed in sorted order; a key whose hash is taken (or
/// reserved) probes to the next free value. The same set of keys therefore
/// always yields the same IDs, no matter the input order.
Map<String, int> assignNotificationIds(Iterable<String> keys) {
  final sorted = keys.toSet().toList()..sort();
  final used = <int>{};
  final result = <String, int>{};
  for (final key in sorted) {
    var id = stableNotificationId(key);
    while (ReservedNotificationIds.contains(id) || used.contains(id)) {
      id = (id + 1) & 0x7fffffff;
    }
    used.add(id);
    result[key] = id;
  }
  return result;
}
