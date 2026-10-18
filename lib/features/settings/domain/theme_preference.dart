/// Which theme the app shows, chosen in Pengaturan → Tampilan.
enum ThemePreference {
  /// Follow the phone's light or dark mode (the default).
  system,
  light,
  dark;

  /// The stored value; unknown or missing values fall back to [system].
  static ThemePreference parse(String? value) => switch (value) {
    'light' => light,
    'dark' => dark,
    _ => system,
  };
}
