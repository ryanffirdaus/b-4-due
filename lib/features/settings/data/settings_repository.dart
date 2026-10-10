import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../../security/domain/app_lock.dart';
import '../../security/domain/pin_hasher.dart';

/// Typed access to the key/value `app_settings` table.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _offsetsKey = 'reminder.offsets';
  static const _minuteKey = 'reminder.minuteOfDay';
  static const _onboardingKey = 'onboarding.completed';
  static const _pinHashKey = 'lock.pinHash';
  static const _pinSaltKey = 'lock.pinSalt';
  static const _pinIterationsKey = 'lock.pinIterations';
  static const _biometricKey = 'lock.biometric';
  static const _calendarKey = 'device.calendarId';

  Future<String?> _read(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> _watch(String key) =>
      (_db.select(_db.appSettings)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> _write(String key, String value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(SettingRow(key: key, value: value));

  Future<ReminderSettings> getReminderSettings() async =>
      _parseReminderSettings(await _read(_offsetsKey), await _read(_minuteKey));

  Stream<ReminderSettings> watchReminderSettings() {
    final query = _db.select(_db.appSettings)
      ..where((s) => s.key.isIn([_offsetsKey, _minuteKey]));
    return query.watch().map((rows) {
      final byKey = {for (final r in rows) r.key: r.value};
      return _parseReminderSettings(byKey[_offsetsKey], byKey[_minuteKey]);
    });
  }

  Future<void> saveReminderSettings(ReminderSettings settings) =>
      _db.transaction(() async {
        await _write(
          _offsetsKey,
          jsonEncode(
            ReminderSettings.normalizeOffsets(settings.defaultOffsets),
          ),
        );
        await _write(_minuteKey, settings.defaultMinuteOfDay.toString());
      });

  Future<bool> isOnboardingCompleted() async =>
      (await _read(_onboardingKey)) == 'true';

  Stream<bool> watchOnboardingCompleted() =>
      _watch(_onboardingKey).map((v) => v == 'true');

  Future<void> setOnboardingCompleted({required bool completed}) =>
      _write(_onboardingKey, completed.toString());

  Future<AppLockConfig> getAppLock() async {
    final hash = await _read(_pinHashKey);
    final salt = await _read(_pinSaltKey);
    final iterations = int.tryParse(await _read(_pinIterationsKey) ?? '');
    if (hash == null || salt == null || iterations == null) {
      return AppLockConfig.disabled;
    }
    return AppLockConfig(
      pin: PinHash(hash: hash, salt: salt, iterations: iterations),
      biometricEnabled: (await _read(_biometricKey)) == 'true',
    );
  }

  Future<void> saveAppLock(AppLockConfig config) => _db.transaction(() async {
    final pin = config.pin;
    if (pin == null) {
      await (_db.delete(
        _db.appSettings,
      )..where((s) => s.key.like('lock.%'))).go();
      return;
    }
    await _write(_pinHashKey, pin.hash);
    await _write(_pinSaltKey, pin.salt);
    await _write(_pinIterationsKey, pin.iterations.toString());
    await _write(_biometricKey, config.biometricEnabled.toString());
  });

  /// The calendar chosen for "Tambahkan ke Kalender" on this phone.
  Future<String?> getCalendarId() => _read(_calendarKey);

  Future<void> setCalendarId(String id) => _write(_calendarKey, id);

  /// Raw dump of all settings, used by backups.
  Future<Map<String, String>> exportAll() async {
    final rows = await _db.select(_db.appSettings).get();
    return {for (final r in rows) r.key: r.value};
  }

  static ReminderSettings _parseReminderSettings(
    String? offsetsJson,
    String? minute,
  ) {
    var settings = const ReminderSettings();
    if (offsetsJson != null) {
      // A corrupt value keeps the defaults rather than crashing the app.
      final decoded = _tryDecode(offsetsJson);
      if (decoded is List) {
        settings = settings.copyWith(
          defaultOffsets: ReminderSettings.normalizeOffsets(
            decoded.whereType<int>(),
          ),
        );
      }
    }
    final parsedMinute = int.tryParse(minute ?? '');
    if (parsedMinute != null && parsedMinute >= 0 && parsedMinute < 24 * 60) {
      settings = settings.copyWith(defaultMinuteOfDay: parsedMinute);
    }
    return settings;
  }

  static Object? _tryDecode(String json) {
    try {
      return jsonDecode(json);
    } on FormatException {
      return null;
    }
  }
}
