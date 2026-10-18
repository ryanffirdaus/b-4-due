import 'package:b4due/app/app.dart';
import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/core/providers.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/settings/data/settings_repository.dart';
import 'package:b4due/features/settings/domain/theme_preference.dart';
import 'package:b4due/features/settings/presentation/theme_picker.dart';
import 'package:b4due/features/settings/theme_controller.dart';
import 'package:b4due/ui/ui.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';

/// Shows which theme the frame applied, next to the picker.
class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(context.palette.isDark ? 'tema gelap' : 'tema terang'),
      const ThemePicker(),
    ],
  );
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
    ThemePreference initial = ThemePreference.system,
    Brightness system = Brightness.light,
  }) async {
    tester.platformDispatcher.platformBrightnessTestValue = system;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpScreen(
      tester,
      const B4AppFrame(child: _Probe()),
      today: LocalDate(2026, 8, 10),
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialThemePreferenceProvider.overrideWithValue(initial),
      ],
    );
  }

  testWidgets('choosing Gelap switches the whole app and is stored', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('tema terang'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Gelap'));
    await tester.pumpAndSettle();

    expect(find.text('tema gelap'), findsOneWidget);
    final stored = await tester.runAsync(
      () => SettingsRepository(db).getThemePreference(),
    );
    expect(stored, ThemePreference.dark);
  });

  testWidgets('Ikuti sistem follows the phone', (tester) async {
    await pump(tester, system: Brightness.dark);
    expect(find.text('tema gelap'), findsOneWidget);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(find.text('tema terang'), findsOneWidget);
  });

  testWidgets('a stored choice wins over the phone setting', (tester) async {
    await pump(tester, initial: ThemePreference.light, system: Brightness.dark);
    expect(find.text('tema terang'), findsOneWidget);
  });
}
