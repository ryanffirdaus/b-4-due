import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// The type scale (Inter). Nothing is smaller than 14sp.
@immutable
class AppText {
  factory AppText(Palette p) {
    TextStyle style(
      double size,
      double height,
      FontWeight weight, {
      double spacing = 0,
      Color? color,
    }) => TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color ?? p.textPrimary,
      // Digits line up in amounts and dates.
      fontFeatures: const [FontFeature.tabularFigures()],
      decoration: TextDecoration.none,
    );

    return AppText._(
      displayLarge: style(36, 44, FontWeight.w700, spacing: -0.6),
      displayMedium: style(30, 38, FontWeight.w700, spacing: -0.4),
      headlineLarge: style(24, 32, FontWeight.w600, spacing: -0.2),
      headlineMedium: style(20, 28, FontWeight.w600, spacing: -0.1),
      titleMedium: style(18, 26, FontWeight.w500),
      titleSmall: style(16, 24, FontWeight.w600),
      bodyLarge: style(16, 24, FontWeight.w400),
      bodyMedium: style(14, 20, FontWeight.w400),
      bodySmall: style(14, 20, FontWeight.w400, color: p.textSecondary),
      labelLarge: style(16, 24, FontWeight.w600),
      labelMedium: style(14, 20, FontWeight.w500),
    );
  }

  const AppText._({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
  });

  /// Monthly total.
  final TextStyle displayLarge;

  /// Page titles.
  final TextStyle displayMedium;
  final TextStyle headlineLarge;

  /// Section and dialog titles.
  final TextStyle headlineMedium;
  final TextStyle titleMedium;

  /// Card titles.
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;

  /// Secondary text.
  final TextStyle bodySmall;

  /// Buttons.
  final TextStyle labelLarge;

  /// Chips, captions, navigation labels.
  final TextStyle labelMedium;
}

@immutable
class B4ThemeData {
  B4ThemeData(this.palette) : text = AppText(palette);

  final Palette palette;
  final AppText text;
}

/// Provides the palette and type scale. Read them with `context.palette`
/// and `context.text`.
class B4Theme extends InheritedWidget {
  const B4Theme({required this.data, required super.child, super.key});

  final B4ThemeData data;

  static B4ThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<B4Theme>();
    assert(theme != null, 'No B4Theme above this widget.');
    return theme!.data;
  }

  @override
  bool updateShouldNotify(B4Theme oldWidget) =>
      oldWidget.data.palette != data.palette;
}

extension B4ThemeContext on BuildContext {
  Palette get palette => B4Theme.of(this).palette;
  AppText get text => B4Theme.of(this).text;
}

final _themes = {
  Brightness.light: B4ThemeData(Palette.light),
  Brightness.dark: B4ThemeData(Palette.dark),
};

/// Installs the theme plus the defaults plain widgets read: text style,
/// icon colour, text selection colours and scroll behaviour.
class B4ThemeScope extends StatelessWidget {
  const B4ThemeScope({
    required this.brightness,
    required this.child,
    super.key,
  });

  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = _themes[brightness]!;
    final p = data.palette;
    return B4Theme(
      data: data,
      child: DefaultTextStyle(
        style: data.text.bodyLarge,
        child: IconTheme(
          data: IconThemeData(color: p.textPrimary, size: 24),
          child: DefaultSelectionStyle(
            cursorColor: p.primary,
            selectionColor: p.primary.withValues(alpha: 0.28),
            child: ScrollConfiguration(
              behavior: const B4ScrollBehavior(),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Android-style stretch at the scroll edges, no scrollbars.
class B4ScrollBehavior extends ScrollBehavior {
  const B4ScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (defaultTargetPlatform != TargetPlatform.android) return child;
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      clipBehavior: details.decorationClipBehavior ?? Clip.hardEdge,
      child: child,
    );
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

/// Transparent system bars with icons that contrast with the page.
SystemUiOverlayStyle systemBarsFor(Palette p) => SystemUiOverlayStyle(
  statusBarColor: const Color(0x00000000),
  statusBarIconBrightness: p.isDark ? Brightness.light : Brightness.dark,
  statusBarBrightness: p.isDark ? Brightness.dark : Brightness.light,
  systemNavigationBarColor: p.surface,
  systemNavigationBarIconBrightness: p.isDark
      ? Brightness.light
      : Brightness.dark,
  systemNavigationBarDividerColor: p.outline,
);
