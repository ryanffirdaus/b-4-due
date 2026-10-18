import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
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
