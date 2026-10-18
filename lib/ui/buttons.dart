import 'package:flutter/widgets.dart';

import 'feedback.dart';
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
        accent,
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
    this.size = 24,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  /// Plum-tinted circle behind the icon.
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = color ?? (filled ? p.primaryText : p.textPrimary);
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
            color: filled ? p.primarySoft : null,
          ),
          child: Icon(icon, size: size, color: fg),
        ),
      ),
    );
  }
}

/// The floating "add a bill" action, shaped like a bill ticket: an icon
/// stub, a perforation with notches top and bottom, then the label.
class B4TicketButton extends StatelessWidget {
  const B4TicketButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  static const _stubWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const shape = _TicketBorder(stubWidth: _stubWidth);
    return Pressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Tokens.controlRadius),
      pressedOverlay: const Color(0x14000000),
      child: Container(
        height: Tokens.controlHeight,
        decoration: ShapeDecoration(
          color: p.primary,
          shape: shape,
          shadows: [
            BoxShadow(
              color: p.primary.withValues(alpha: p.isDark ? 0.25 : 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _PerforationPainter(
            x: _stubWidth,
            color: p.onPrimary.withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _stubWidth,
                child: Icon(icon, color: p.onPrimary, size: 24),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 22, 0),
                child: Text(
                  label,
                  style: context.text.labelLarge.copyWith(color: p.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded rectangle with a semicircular notch in the top and bottom
/// edges at [stubWidth], where a ticket would tear.
class _TicketBorder extends ShapeBorder {
  const _TicketBorder({required this.stubWidth});

  final double stubWidth;

  static const _radius = Tokens.controlRadius;
  static const _notch = 6.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(_radius)));
    final x = rect.left + stubWidth;
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(x, rect.top), radius: _notch))
      ..addOval(
        Rect.fromCircle(center: Offset(x, rect.bottom), radius: _notch),
      );
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

/// Dashed vertical line between the notches of a [_TicketBorder].
class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({required this.x, required this.color});

  final double x;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 3.0;
    const gap = 4.0;
    for (
      var y = _TicketBorder._notch + 4;
      y < size.height - _TicketBorder._notch - 4;
      y += dash + gap
    ) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dash), paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter old) =>
      old.x != x || old.color != color;
}
