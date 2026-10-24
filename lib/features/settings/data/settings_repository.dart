import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../currency/domain/money.dart';
import '../../reminders/domain/reminder_settings.dart';
import '../../security/domain/app_lock.dart';
import '../../security/domain/pin_hasher.dart';
import '../domain/theme_preference.dart';

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
  static const _themeKey = 'appearance.theme';
  static const _budgetKey = 'budget.monthly';
  static const _accentKey = 'appearance.accent';
  static const _mainCurrencyKey = 'currency.main';

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

  Future<ThemePreference> getThemePreference() async =>
      ThemePreference.parse(await _read(_themeKey));

  Future<void> setThemePreference(ThemePreference preference) =>
      _write(_themeKey, preference.name);

  /// The currency of totals, budgets and statistics, or null before one has
  /// been stored (see [ensureMainCurrency]).
  Future<Currency?> getMainCurrency() async {
    final code = await _read(_mainCurrencyKey);
    return code == null ? null : currencyByCode(code);
  }

  /// The main currency, rupiah until one is stored.
  Future<Currency> mainCurrency() async => await getMainCurrency() ?? idr;

  Stream<Currency> watchMainCurrency() =>
      _watch(_mainCurrencyKey)
          .map((code) => code == null ? idr : currencyByCode(code));

  Future<void> setMainCurrency(Currency currency) =>
      _write(_mainCurrencyKey, currency.code);

  /// Stores a main currency when there is none yet and returns the result.
  /// Installs from before main currencies keep rupiah, because their data
  /// is in rupiah; a fresh install takes the currency of the phone's
  /// region when it is supported.
  Future<Currency> ensureMainCurrency({String? regionCode}) async {
    final stored = await getMainCurrency();
    if (stored != null) return stored;
    final hasData =
        await isOnboardingCompleted() ||
        (await _db.select(_db.bills).get()).isNotEmpty;
    final chosen = hasData ? idr : currencyForRegion(regionCode) ?? idr;
    await setMainCurrency(chosen);
    return chosen;
  }

  /// The monthly budget in the main currency's minor units, or null when
  /// none is set.
  Stream<int?> watchMonthlyBudget() => _watch(_budgetKey).map(_parseBudget);

  Future<int?> getMonthlyBudget() async =>
      _parseBudget(await _read(_budgetKey));

  /// Null removes the budget.
  Future<void> setMonthlyBudget(int? minorUnits) async {
    if (minorUnits == null) {
      await (_db.delete(
        _db.appSettings,
      )..where((s) => s.key.equals(_budgetKey))).go();
      return;
    }
    await _write(_budgetKey, minorUnits.toString());
  }

  static int? _parseBudget(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed != null && parsed > 0 ? parsed : null;
  }

  /// The accent's name (`lime`, `sky`, ...), or null for the default.
  Future<String?> getAccent() => _read(_accentKey);

  Future<void> setAccent(String name) => _write(_accentKey, name);

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
