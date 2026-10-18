import 'package:flutter/widgets.dart';

/// B4Due colour tokens (docs/DESIGN.md), "Dompet" style: an ink-and-lime
/// wallet on a cool lavender neutral (light) or near-black (dark).
///
/// Filled main actions are ink in light mode and near-white in dark mode;
/// the lime accent marks the add button, progress and selection. Bills are
/// shown as coloured wallet cards ([walletCards]). Every text/background pair
/// used by the app is checked against WCAG AA in
/// test/ui/palette_contrast_test.dart.
@immutable
class Palette {
  const Palette._({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryText,
    required this.primarySoft,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.outlineStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.scrim,
    required this.shadow,
    required this.success,
    required this.successText,
    required this.successSoft,
    required this.warning,
    required this.warningText,
    required this.warningSoft,
    required this.today,
    required this.todayText,
    required this.todaySoft,
    required this.danger,
    required this.dangerText,
    required this.dangerSoft,
    required this.onDanger,
    required this.neutral,
    required this.neutralText,
    required this.neutralSoft,
    required this.muted,
    required this.chart,
  });

  static const light = Palette._(
    brightness: Brightness.light,
    primary: Color(0xFF15121D),
    onPrimary: Color(0xFFFFFFFF),
    primaryText: Color(0xFF2F6B0C),
    primarySoft: Color(0xFFE9E5F0),
    accent: Color(0xFFB6F36B),
    onAccent: Color(0xFF15121D),
    accentText: Color(0xFF2F6B0C),
    accentSoft: Color(0xFFE4F5CC),
    background: Color(0xFFF3F1F7),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFECE8F2),
    outline: Color(0xFFE4DFEC),
    outlineStrong: Color(0xFFCBC4D8),
    textPrimary: Color(0xFF15121D),
    textSecondary: Color(0xFF5E5870),
    inverseSurface: Color(0xFF15121D),
    onInverseSurface: Color(0xFFFFFFFF),
    scrim: Color(0x8015121D),
    shadow: Color(0x1A3C285A),
    success: Color(0xFF17B26A),
    successText: Color(0xFF067647),
    successSoft: Color(0xFFDCFAE6),
    warning: Color(0xFFF79009),
    warningText: Color(0xFFB54708),
    warningSoft: Color(0xFFFEF0C7),
    today: Color(0xFFEF6820),
    todayText: Color(0xFFB93815),
    todaySoft: Color(0xFFFDEAD7),
    danger: Color(0xFFF04438),
    dangerText: Color(0xFFB42318),
    dangerSoft: Color(0xFFFEE4E2),
    onDanger: Color(0xFFFFFFFF),
    neutral: Color(0xFF8E87A0),
    neutralText: Color(0xFF524B63),
    neutralSoft: Color(0xFFECE8F2),
    muted: Color(0xFFA39CB4),
    chart: [
      Color(0xFF5B3FD0),
      Color(0xFF2A7F5F),
      Color(0xFFD9443A),
      Color(0xFF2F6FD6),
      Color(0xFFB4580F),
      Color(0xFFB8327E),
      Color(0xFF157A86),
      Color(0xFF5E5870),
    ],
  );

  static const dark = Palette._(
    brightness: Brightness.dark,
    primary: Color(0xFFF2EEFA),
    onPrimary: Color(0xFF0E0C14),
    primaryText: Color(0xFFB6F36B),
    primarySoft: Color(0xFF2A2538),
    accent: Color(0xFFB6F36B),
    onAccent: Color(0xFF0E0C14),
    accentText: Color(0xFFB6F36B),
    accentSoft: Color(0xFF26331A),
    background: Color(0xFF0E0C14),
    surface: Color(0xFF1C1828),
    surfaceVariant: Color(0xFF2A2538),
    outline: Color(0xFF2A2538),
    outlineStrong: Color(0xFF433B57),
    textPrimary: Color(0xFFF2EEFA),
    textSecondary: Color(0xFFA9A2BA),
    inverseSurface: Color(0xFFF2EEFA),
    onInverseSurface: Color(0xFF15121D),
    scrim: Color(0xB3000000),
    shadow: Color(0x00000000),
    success: Color(0xFF47CD89),
    successText: Color(0xFF47CD89),
    successSoft: Color(0xFF0E3123),
    warning: Color(0xFFFDB022),
    warningText: Color(0xFFFDB022),
    warningSoft: Color(0xFF3A2A08),
    today: Color(0xFFFF9C66),
    todayText: Color(0xFFFF9C66),
    todaySoft: Color(0xFF3D2113),
    danger: Color(0xFFF97066),
    dangerText: Color(0xFFF97066),
    dangerSoft: Color(0xFF3D1916),
    onDanger: Color(0xFF2B0D0B),
    neutral: Color(0xFF8E87A0),
    neutralText: Color(0xFFBDB6CC),
    neutralSoft: Color(0xFF2A2538),
    muted: Color(0xFF6B6480),
    chart: [
      Color(0xFFB6F36B),
      Color(0xFF9C86F5),
      Color(0xFF5ED3A6),
      Color(0xFFFF8A7A),
      Color(0xFF6FA8FF),
      Color(0xFFF2B35B),
      Color(0xFFF07BC0),
      Color(0xFF5CC9D4),
    ],
  );

  static Palette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  final Brightness brightness;
  bool get isDark => brightness == Brightness.dark;

  /// The main filled action: ink on light, near-white on dark. Also the
  /// selected navigation item.
  final Color primary;

  /// Text and icons on [primary] fills.
  final Color onPrimary;

  /// Emphasised text and icons on the page (links, ghost buttons).
  final Color primaryText;

  /// Quiet fill behind icons and unselected controls.
  final Color primarySoft;

  /// The lime accent: the add button, progress, selection.
  final Color accent;

  /// Text and icons on [accent] fills.
  final Color onAccent;

  /// The accent as text on the page; darker than [accent] in light mode so
  /// it stays readable.
  final Color accentText;

  /// A tint of the accent behind accent text.
  final Color accentSoft;

  final Color background;

  /// Panels, sheets, dialogs, navigation.
  final Color surface;

  /// Input fills.
  final Color surfaceVariant;

  /// Hairlines and dividers.
  final Color outline;

  /// Outlined buttons and unselected controls.
  final Color outlineStrong;

  final Color textPrimary;
  final Color textSecondary;

  /// Chart tooltips.
  final Color inverseSurface;
  final Color onInverseSurface;

  /// Behind sheets and dialogs.
  final Color scrim;

  /// Soft shadow under floating surfaces (none in dark mode).
  final Color shadow;

  /// Paid. The plain colour is for dots, `*Text` for text, `*Soft` behind
  /// text.
  final Color success;
  final Color successText;
  final Color successSoft;

  /// Due within three days.
  final Color warning;
  final Color warningText;
  final Color warningSoft;

  /// Due today.
  final Color today;
  final Color todayText;
  final Color todaySoft;

  /// Overdue and destructive actions.
  final Color danger;
  final Color dangerText;
  final Color dangerSoft;

  /// Text and icons on a [dangerText] fill.
  final Color onDanger;

  /// Upcoming: deliberately neutral, so only states that need action are
  /// coloured.
  final Color neutral;
  final Color neutralText;
  final Color neutralSoft;

  /// Cancelled / inactive.
  final Color muted;

  /// Categorical colours for charts.
  final List<Color> chart;

  /// Wallet-card colours for bills, the same in both themes. White text on
  /// each reaches 4.5:1.
  static const walletCards = [
    WalletCardColors(Color(0xFF6A4CDB), Color(0xFF4A2DA8)),
    WalletCardColors(Color(0xFF2A7F5F), Color(0xFF175440)),
    WalletCardColors(Color(0xFFD13F35), Color(0xFF9E2A21)),
    WalletCardColors(Color(0xFF2F6AD0), Color(0xFF1E4A99)),
    WalletCardColors(Color(0xFFA9520E), Color(0xFF7E3B08)),
    WalletCardColors(Color(0xFF4A5568), Color(0xFF2D3442)),
    WalletCardColors(Color(0xFFB0307A), Color(0xFF82205A)),
    WalletCardColors(Color(0xFF13717C), Color(0xFF0C525A)),
  ];
}

/// A wallet card's diagonal gradient, top left to bottom right.
@immutable
class WalletCardColors {
  const WalletCardColors(this.start, this.end);

  final Color start;
  final Color end;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [start, end],
  );
}

/// Spacing, shape and motion tokens.
abstract final class Tokens {
  static const pagePadding = 22.0;
  static const sectionGap = 28.0;
  static const cardGap = 16.0;
  static const listGap = 12.0;

  /// Wallet cards and panels.
  static const cardRadius = 22.0;

  /// Buttons are full pills; inputs use [inputRadius].
  static const controlRadius = 28.0;
  static const inputRadius = 18.0;
  static const chipRadius = 20.0;
  static const dialogRadius = 28.0;
  static const sheetRadius = 30.0;

  /// The floating navigation pill.
  static const dockRadius = 30.0;
  static const dockHeight = 60.0;

  /// Bottom space a tab's list leaves so its last item can scroll clear of
  /// the floating add button.
  static const fabClearance = 84.0;

  static const controlHeight = 56.0;
  static const compactControlHeight = 44.0;

  /// Minimum touch target.
  static const minTouch = 48.0;

  static const motion = Duration(milliseconds: 200);
  static const motionSlow = Duration(milliseconds: 300);
  static const curve = Curves.easeOutCubic;
}
