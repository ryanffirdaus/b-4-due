import 'package:flutter/material.dart';

/// B4Due design tokens (docs/DESIGN.md): a calm fintech look in light and
/// dark, Electric Blue as the only brand colour.
///
/// Accessibility (WCAG AA) adjustments to the spec, measured:
/// - white on Electric Blue is 2.9:1, so text and icons on blue fills use
///   Midnight Navy (4.9:1);
/// - status colours are used as-is for dots and tinted backgrounds, while
///   status *text* uses a darker (light mode) or lighter (dark mode) shade.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.primary,
    required this.onPrimary,
    required this.primaryText,
    required this.navy,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.card,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.successText,
    required this.warning,
    required this.warningText,
    required this.today,
    required this.todayText,
    required this.danger,
    required this.dangerText,
    required this.info,
    required this.infoText,
    required this.muted,
  });

  static const light = Palette(
    primary: Color(0xFF459AF8),
    onPrimary: Color(0xFF20294C),
    primaryText: Color(0xFF1C6DD0),
    navy: Color(0xFF20294C),
    background: Color(0xFFF7F8FC),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF0F1F5),
    card: Color(0xFFFFFFFF),
    outline: Color(0xFFC7CBDB),
    textPrimary: Color(0xFF20294C),
    textSecondary: Color(0xFF5A6175),
    success: Color(0xFF16A34A),
    successText: Color(0xFF15803D),
    warning: Color(0xFFF59E0B),
    warningText: Color(0xFFB45309),
    today: Color(0xFFF97316),
    todayText: Color(0xFFC2410C),
    danger: Color(0xFFEF4444),
    dangerText: Color(0xFFDC2626),
    info: Color(0xFF3B82F6),
    infoText: Color(0xFF2563EB),
    muted: Color(0xFF94A3B8),
  );

  static const dark = Palette(
    primary: Color(0xFF459AF8),
    onPrimary: Color(0xFF0B1530),
    primaryText: Color(0xFF6CB0FA),
    navy: Color(0xFF20294C),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF243247),
    card: Color(0xFF243247),
    outline: Color(0xFF334155),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA9B4C6),
    success: Color(0xFF22C55E),
    successText: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    warningText: Color(0xFFF59E0B),
    today: Color(0xFFFB923C),
    todayText: Color(0xFFFB923C),
    danger: Color(0xFFEF4444),
    dangerText: Color(0xFFF87171),
    info: Color(0xFF3B82F6),
    infoText: Color(0xFF60A5FA),
    muted: Color(0xFF64748B),
  );

  /// Electric Blue: buttons, FAB, selected navigation, progress.
  final Color primary;

  /// Text and icons on [primary] fills.
  final Color onPrimary;

  /// Blue for text on the background (links, text buttons).
  final Color primaryText;
  final Color navy;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color card;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;

  /// Paid.
  final Color success;
  final Color successText;

  /// Due soon (within three days).
  final Color warning;
  final Color warningText;

  /// Due today.
  final Color today;
  final Color todayText;

  /// Overdue, destructive actions.
  final Color danger;
  final Color dangerText;

  /// Upcoming.
  final Color info;
  final Color infoText;

  /// Cancelled / inactive.
  final Color muted;

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(Palette? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}

/// Spacing and shape tokens.
abstract final class Tokens {
  static const pagePadding = 20.0;
  static const sectionGap = 24.0;
  static const cardGap = 16.0;
  static const listGap = 12.0;
  static const cardRadius = 20.0;
  static const controlRadius = 16.0;
  static const dialogRadius = 24.0;
  static const sheetRadius = 28.0;
  static const controlHeight = 56.0;
  static const motion = Duration(milliseconds: 200);
}

ThemeData buildAppTheme(Brightness brightness) {
  final p = brightness == Brightness.light ? Palette.light : Palette.dark;
  final isLight = brightness == Brightness.light;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    secondary: isLight ? p.navy : p.textPrimary,
    onSecondary: isLight ? Colors.white : p.navy,
    tertiary: const Color(0xFF375390),
    onTertiary: Colors.white,
    error: p.danger,
    onError: Colors.white,
    surface: p.surface,
    onSurface: p.textPrimary,
    onSurfaceVariant: p.textSecondary,
    surfaceContainerLowest: p.background,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surfaceVariant,
    surfaceContainerHighest: p.surfaceVariant,
    outline: p.outline,
    outlineVariant: p.outline,
    primaryContainer: p.primary.withValues(alpha: 0.14),
    onPrimaryContainer: p.primaryText,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: p.background,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    splashFactory: InkRipple.splashFactory,
    extensions: [p],
  );

  TextStyle? style(TextStyle? s, double size, FontWeight weight) =>
      s?.copyWith(fontSize: size, fontWeight: weight, color: p.textPrimary);

  // Spec type scale; the smallest text is 14sp (accessibility minimum).
  final text = base.textTheme.copyWith(
    displayLarge: style(base.textTheme.displayLarge, 36, FontWeight.w700),
    displayMedium: style(base.textTheme.displayMedium, 30, FontWeight.w700),
    headlineLarge: style(base.textTheme.headlineLarge, 24, FontWeight.w600),
    headlineMedium: style(base.textTheme.headlineMedium, 20, FontWeight.w600),
    titleLarge: style(base.textTheme.titleLarge, 20, FontWeight.w600),
    titleMedium: style(base.textTheme.titleMedium, 18, FontWeight.w500),
    titleSmall: style(base.textTheme.titleSmall, 16, FontWeight.w600),
    bodyLarge: style(base.textTheme.bodyLarge, 16, FontWeight.w400),
    bodyMedium: style(base.textTheme.bodyMedium, 14, FontWeight.w400),
    bodySmall: style(
      base.textTheme.bodySmall,
      14,
      FontWeight.w400,
    )?.copyWith(color: p.textSecondary),
    labelLarge: style(base.textTheme.labelLarge, 16, FontWeight.w600),
    labelMedium: style(base.textTheme.labelMedium, 14, FontWeight.w500),
    labelSmall: style(base.textTheme.labelSmall, 14, FontWeight.w500),
  );

  const controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(Tokens.controlRadius)),
  );
  const buttonSize = Size(64, Tokens.controlHeight);
  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(Tokens.controlRadius),
        ),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.headlineMedium,
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: isLight ? 2 : 0,
      shadowColor: const Color(0x1420294C),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Tokens.cardRadius)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: p.outline.withValues(alpha: 0.6),
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        minimumSize: buttonSize,
        textStyle: text.labelLarge,
        shape: controlShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        foregroundColor: p.primaryText,
        backgroundColor: p.surface,
        side: BorderSide(color: p.primary),
        textStyle: text.labelLarge,
        shape: controlShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primaryText,
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      elevation: 2,
      focusElevation: 2,
      hoverElevation: 3,
      highlightElevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Tokens.controlRadius)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: inputBorder(Colors.transparent),
      enabledBorder: inputBorder(Colors.transparent),
      focusedBorder: inputBorder(p.primary, 2),
      errorBorder: inputBorder(p.danger),
      focusedErrorBorder: inputBorder(p.danger, 2),
      labelStyle: TextStyle(color: p.textSecondary),
      hintStyle: TextStyle(color: p.textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      selectedColor: p.primary,
      side: BorderSide(color: p.outline),
      labelStyle: text.bodyMedium,
      secondaryLabelStyle: text.bodyMedium?.copyWith(color: p.onPrimary),
      checkmarkColor: p.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodyMedium?.copyWith(color: p.textSecondary),
      iconColor: p.textSecondary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : p.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.primary : p.surfaceVariant,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.primary : p.outline,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 80,
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      indicatorColor: p.primary.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => text.labelMedium?.copyWith(
          color: s.contains(WidgetState.selected)
              ? p.primaryText
              : p.textSecondary,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? p.primaryText
              : p.textSecondary,
          size: 24,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isLight ? p.navy : p.surfaceVariant,
      contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
      actionTextColor: const Color(0xFF8CC2FB),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Tokens.controlRadius)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Tokens.sheetRadius),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Tokens.dialogRadius)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.primary,
      circularTrackColor: p.surfaceVariant,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}
