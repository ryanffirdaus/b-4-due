import 'package:flutter/widgets.dart';

/// B4Due colour tokens (docs/DESIGN.md): Plum on a lavender-tinted neutral.
///
/// Plum was chosen because it collides with none of the status colours
/// (overdue red, today orange, due-soon amber, paid green), and white on Plum
/// reaches 7.1:1. Every text/background pair used by the app is checked
/// against WCAG AA in test/ui/palette_contrast_test.dart.
@immutable
class Palette {
  const Palette._({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryText,
    required this.primarySoft,
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
    primary: Color(0xFF6D28D9),
    onPrimary: Color(0xFFFFFFFF),
    primaryText: Color(0xFF6D28D9),
    primarySoft: Color(0xFFF0EAFB),
    background: Color(0xFFF8F6FB),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1EDF7),
    outline: Color(0xFFE4DEEC),
    outlineStrong: Color(0xFFCFC6DC),
    textPrimary: Color(0xFF1F1A2E),
    textSecondary: Color(0xFF625B70),
    inverseSurface: Color(0xFF1F1A2E),
    onInverseSurface: Color(0xFFFFFFFF),
    scrim: Color(0x801F1A2E),
    shadow: Color(0x0F1F1A2E),
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
    neutralSoft: Color(0xFFEFECF4),
    muted: Color(0xFFA39CB4),
    chart: [
      Color(0xFF6D28D9),
      Color(0xFF0BA5EC),
      Color(0xFF15B79E),
      Color(0xFFF79009),
      Color(0xFFDD2590),
      Color(0xFF9E77ED),
      Color(0xFF2E90FA),
      Color(0xFF8E87A0),
    ],
  );

  static const dark = Palette._(
    brightness: Brightness.dark,
    primary: Color(0xFFB197FC),
    onPrimary: Color(0xFF1A1033),
    primaryText: Color(0xFFC4B1FD),
    primarySoft: Color(0xFF2E2547),
    background: Color(0xFF14111C),
    surface: Color(0xFF1F1A2B),
    surfaceVariant: Color(0xFF2A2438),
    outline: Color(0xFF2E2740),
    outlineStrong: Color(0xFF453C5C),
    textPrimary: Color(0xFFEDE9F5),
    textSecondary: Color(0xFFA9A2BA),
    inverseSurface: Color(0xFFEDE9F5),
    onInverseSurface: Color(0xFF1F1A2E),
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
    neutralSoft: Color(0xFF2A2438),
    muted: Color(0xFF6B6480),
    chart: [
      Color(0xFFB197FC),
      Color(0xFF36BFFA),
      Color(0xFF2ED3B7),
      Color(0xFFFDB022),
      Color(0xFFF670C7),
      Color(0xFFD6BBFB),
      Color(0xFF53B1FD),
      Color(0xFF8E87A0),
    ],
  );

  static Palette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  final Brightness brightness;
  bool get isDark => brightness == Brightness.dark;

  /// Plum: filled buttons, FAB, selected navigation and chips, progress.
  final Color primary;

  /// Text and icons on [primary] fills.
  final Color onPrimary;

  /// Plum for text and icons on the background (links, ghost buttons).
  final Color primaryText;

  /// Plum tint behind icons and selected navigation items.
  final Color primarySoft;

  final Color background;

  /// Cards, sheets, dialogs, navigation bar.
  final Color surface;

  /// Input fills and icon tiles.
  final Color surfaceVariant;

  /// Card borders and dividers.
  final Color outline;

  /// Outlined buttons, unselected chips, the off switch track.
  final Color outlineStrong;

  final Color textPrimary;
  final Color textSecondary;

  /// Chart tooltips.
  final Color inverseSurface;
  final Color onInverseSurface;

  /// Behind sheets and dialogs.
  final Color scrim;

  /// Card shadow (none in dark mode, where borders carry the depth).
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

  /// Categorical colours for charts, Plum first.
  final List<Color> chart;
}

/// Spacing, shape and motion tokens.
abstract final class Tokens {
  static const pagePadding = 20.0;
  static const sectionGap = 24.0;
  static const cardGap = 16.0;
  static const listGap = 12.0;

  static const cardRadius = 20.0;
  static const controlRadius = 16.0;
  static const chipRadius = 12.0;
  static const dialogRadius = 24.0;
  static const sheetRadius = 28.0;

  /// The floating bottom navigation dock.
  static const dockRadius = 24.0;

  static const controlHeight = 56.0;
  static const compactControlHeight = 44.0;

  /// Minimum touch target.
  static const minTouch = 48.0;

  static const motion = Duration(milliseconds: 200);
  static const motionSlow = Duration(milliseconds: 280);
  static const curve = Curves.easeOutCubic;
}
