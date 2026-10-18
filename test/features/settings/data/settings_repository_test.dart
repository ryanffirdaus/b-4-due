import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/features/reminders/domain/reminder_settings.dart';
import 'package:b4due/features/settings/data/settings_repository.dart';
import 'package:b4due/features/settings/domain/theme_preference.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() => db.close());

  test('returns standard defaults on a fresh database', () async {
    expect(await repo.getReminderSettings(), const ReminderSettings());
    expect(await repo.isOnboardingCompleted(), isFalse);
  });

  test('theme follows the system until one is chosen', () async {
    expect(await repo.getThemePreference(), ThemePreference.system);
    await repo.setThemePreference(ThemePreference.dark);
    expect(await repo.getThemePreference(), ThemePreference.dark);
    await repo.setThemePreference(ThemePreference.system);
    expect(await repo.getThemePreference(), ThemePreference.system);
  });

  test('an unknown stored theme falls back to the system', () async {
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(key: 'appearance.theme', value: 'neon'),
        );
    expect(await repo.getThemePreference(), ThemePreference.system);
  });

  test('persists normalized reminder settings', () async {
    await repo.saveReminderSettings(
      const ReminderSettings(
        defaultOffsets: [0, 3, 3, 14, 999],
        defaultMinuteOfDay: 7 * 60,
      ),
    );
    final loaded = await repo.getReminderSettings();
    expect(loaded.defaultOffsets, [14, 3, 0]);
    expect(loaded.defaultMinuteOfDay, 7 * 60);
  });

  test('ignores corrupt stored values', () async {
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(key: 'reminder.offsets', value: '{oops'),
        );
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            key: 'reminder.minuteOfDay',
            value: '99999',
          ),
        );
    expect(await repo.getReminderSettings(), const ReminderSettings());
  });

  test('onboarding flag round-trips', () async {
    await repo.setOnboardingCompleted(completed: true);
    expect(await repo.isOnboardingCompleted(), isTrue);
  });

  test('watchReminderSettings emits updates', () async {
    final stream = repo.watchReminderSettings().map(
      (s) => s.defaultMinuteOfDay,
    );
    final expectation = expectLater(stream, emitsInOrder([540, 1200]));
    await pumpEventQueue();
    await repo.saveReminderSettings(
      const ReminderSettings(defaultMinuteOfDay: 1200),
    );
    await expectation;
  });

  test('exportAll returns raw values', () async {
    await repo.setOnboardingCompleted(completed: true);
    expect(await repo.exportAll(), {'onboarding.completed': 'true'});
  });
}
