import 'package:flutter/widgets.dart';

import 'feedback.dart';
import 'icons.dart';
import 'pressable.dart';
import 'theme.dart';
import 'tokens.dart';

enum B4ButtonVariant {
  /// Filled Plum: the one main action on a screen.
  primary,

  /// Plum tint: secondary actions that still deserve weight.
  tonal,

  /// Bordered: alternatives next to a primary button.
  outline,

  /// Text only: low-emphasis actions ("Lihat semua", dialog cancel).
  ghost,
}

class B4Button extends StatelessWidget {
  const B4Button({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = B4ButtonVariant.primary,
    this.destructive = false,
    this.loading = false,
    this.compact = false,
    super.key,
  });

  const B4Button.tonal({
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.loading = false,
    this.compact = false,
    super.key,
  }) : variant = B4ButtonVariant.tonal;

  const B4Button.outline({
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.loading = false,
    this.compact = false,
    super.key,
  }) : variant = B4ButtonVariant.outline;

  const B4Button.ghost({
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.loading = false,
    this.compact = false,
    super.key,
  }) : variant = B4ButtonVariant.ghost;

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final IconData? icon;
  final B4ButtonVariant variant;

  /// Red instead of Plum, for delete and restore-over-data actions.
  final bool destructive;

  /// Shows a spinner and ignores taps.
  final bool loading;

  /// 44 instead of 56 high (still a 48dp touch target via padding).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = destructive ? p.dangerText : p.primaryText;
    final (Color? fill, Color fg, Color? border) = switch (variant) {
      B4ButtonVariant.primary => (
        destructive ? p.dangerText : p.primary,
        destructive ? p.onDanger : p.onPrimary,
        null,
      ),
      B4ButtonVariant.tonal => (
        destructive ? p.dangerSoft : p.primarySoft,
        destructive ? p.dangerText : p.textPrimary,
        null,
      ),
      B4ButtonVariant.outline => (p.surface, accent, p.outlineStrong),
      B4ButtonVariant.ghost => (null, accent, null),
    };
    final enabled = onPressed != null && !loading;
    final height = compact
        ? Tokens.compactControlHeight
        : variant == B4ButtonVariant.ghost
        ? Tokens.minTouch
        : Tokens.controlHeight;
    final radius = BorderRadius.circular(Tokens.controlRadius);
    final textStyle = context.text.labelLarge.copyWith(color: fg);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: B4Spinner(size: 18, color: fg),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: 20, color: fg),
          ),
        Flexible(
          child: Text(
            label,
            style: textStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );

    return DisabledOpacity(
      enabled: enabled || loading,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        borderRadius: radius,
        pressedOverlay: fill == null || variant == B4ButtonVariant.outline
            ? null
            : const Color(0x14000000),
        child: Container(
          constraints: BoxConstraints(minHeight: height, minWidth: 64),
          padding: EdgeInsets.symmetric(
            horizontal: variant == B4ButtonVariant.ghost ? 12 : 20,
            vertical: 8,
          ),
          // No alignment: the button hugs its label unless the parent
          // stretches it.
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: border == null
                ? null
                : Border.all(color: border, width: 1.5),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// A 48dp round icon button. [label] is required: it is what screen
/// readers announce.
class B4IconButton extends StatelessWidget {
  const B4IconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.filled = false,
    this.background,
    this.size = 24,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  /// A raised circle behind the icon (top-bar actions).
  final bool filled;

  /// A flat circle in this colour instead (e.g. on a sheet, where a raised
  /// circle would vanish).
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = color ?? p.textPrimary;
    return DisabledOpacity(
      enabled: onPressed != null,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: label,
        excludeChildSemantics: true,
        borderRadius: BorderRadius.circular(Tokens.minTouch / 2),
        pressedScale: 0.92,
        child: Container(
          width: Tokens.minTouch,
          height: Tokens.minTouch,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background ?? (filled ? p.surface : null),
            boxShadow: filled && background == null && !p.isDark
                ? [
                    BoxShadow(
                      color: p.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: size, color: fg),
        ),
      ),
    );
  }
}

/// The round accent "+" that sits beside the navigation pill: the one way
/// to add a bill from every tab.
class B4AddButton extends StatelessWidget {
  const B4AddButton({required this.label, required this.onPressed, super.key});

  /// Spoken by screen readers ("Tambah tagihan").
  final String label;
  final VoidCallback onPressed;

  static const size = 60.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      excludeChildSemantics: true,
      borderRadius: BorderRadius.circular(size / 2),
      pressedScale: 0.9,
      pressedOverlay: const Color(0x14000000),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.accent,
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: p.isDark ? 0.18 : 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(RemixIcons.addLine, color: p.onAccent, size: 28),
      ),
    );
  }
}
