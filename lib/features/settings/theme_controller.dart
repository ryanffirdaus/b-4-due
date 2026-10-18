import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../ui/tokens.dart';
import 'domain/theme_preference.dart';

/// Theme read before `runApp`, so the first frame already has the chosen
/// theme. Overridden in `main`.
final initialThemePreferenceProvider = Provider<ThemePreference>(
  (ref) => ThemePreference.system,
);

final themePreferenceProvider =
    NotifierProvider<ThemePreferenceController, ThemePreference>(
      ThemePreferenceController.new,
    );

/// Accent read before `runApp`, like the theme. Overridden in `main`.
final initialAccentProvider = Provider<AccentColors>(
  (ref) => AccentColors.lime,
);

final accentProvider = NotifierProvider<AccentController, AccentColors>(
  AccentController.new,
);

class ThemePreferenceController extends Notifier<ThemePreference> {
  @override
  ThemePreference build() => ref.watch(initialThemePreferenceProvider);

  /// Picks up a theme written behind the controller's back (a restored
  /// backup).
  Future<void> reload() async {
    state = await ref.read(settingsRepositoryProvider).getThemePreference();
  }

  /// Applies [preference] at once and stores it.
  Future<void> set(ThemePreference preference) async {
    if (preference == state) return;
    state = preference;
    await ref.read(settingsRepositoryProvider).setThemePreference(preference);
  }
}

class AccentController extends Notifier<AccentColors> {
  @override
  AccentColors build() => ref.watch(initialAccentProvider);

  /// Picks up an accent written behind the controller's back (a restored
  /// backup).
  Future<void> reload() async {
    state = AccentColors.byName(
      await ref.read(settingsRepositoryProvider).getAccent(),
    );
  }

  /// Applies [accent] at once and stores it.
  Future<void> set(AccentColors accent) async {
    if (accent == state) return;
    state = accent;
    await ref.read(settingsRepositoryProvider).setAccent(accent.name);
  }
}
