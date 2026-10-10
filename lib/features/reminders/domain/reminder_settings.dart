import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// App-wide reminder defaults. Individual bills may override both values.
@immutable
class ReminderSettings {
  const ReminderSettings({
    this.defaultOffsets = standardOffsets,
    this.defaultMinuteOfDay = standardMinuteOfDay,
  });

  /// H-7, H-3, H-1 and the due day itself.
  static const standardOffsets = [7, 3, 1, 0];

  /// 09:00.
  static const standardMinuteOfDay = 9 * 60;

  /// Largest offset the UI offers; keeps reminders within a sane window.
  static const maxOffsetDays = 60;

  final List<int> defaultOffsets;
  final int defaultMinuteOfDay;

  ReminderSettings copyWith({
    List<int>? defaultOffsets,
    int? defaultMinuteOfDay,
  }) => ReminderSettings(
    defaultOffsets: defaultOffsets ?? this.defaultOffsets,
    defaultMinuteOfDay: defaultMinuteOfDay ?? this.defaultMinuteOfDay,
  );

  /// Sorted (largest first), de-duplicated and range-checked offsets.
  static List<int> normalizeOffsets(Iterable<int> offsets) {
    final unique =
        offsets.where((o) => o >= 0 && o <= maxOffsetDays).toSet().toList()
          ..sort((a, b) => b.compareTo(a));
    return unique;
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      const ListEquality<int>().equals(other.defaultOffsets, defaultOffsets) &&
      other.defaultMinuteOfDay == defaultMinuteOfDay;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(defaultOffsets), defaultMinuteOfDay);
}
