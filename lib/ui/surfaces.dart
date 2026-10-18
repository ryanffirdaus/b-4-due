import 'package:flutter/widgets.dart';

import 'icons.dart';
import 'pressable.dart';
import 'theme.dart';
import 'tokens.dart';

/// A rounded panel for grouped content: no outline, a soft shadow in light
/// mode, a lifted surface in dark mode. With [onTap] the whole panel is a
/// button.
class B4Card extends StatelessWidget {
  const B4Card({
    required this.child,
    this.padding = const EdgeInsets.all(Tokens.pagePadding),
    this.onTap,
    this.onLongPress,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(Tokens.cardRadius);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: radius,
        boxShadow: p.isDark
            ? null
            : [
                BoxShadow(
                  color: p.shadow,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
    if (onTap == null && onLongPress == null) return card;
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      borderRadius: radius,
      pressedScale: 0.985,
      child: card,
    );
  }
}

/// Hairline between rows.
class B4Divider extends StatelessWidget {
  const B4Divider({this.indent = 0, this.endIndent = 0, super.key});

  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
    child: Container(height: 1, color: context.palette.outline),
  );
}

/// A card of [B4ListRow]s with dividers between them.
class B4ListGroup extends StatelessWidget {
  const B4ListGroup({
    required this.children,
    this.dividerIndent = 70,
    super.key,
  });

  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    return B4Card(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) B4Divider(indent: dividerIndent),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

enum B4Tone { normal, primary, success, danger }

/// Icon in a rounded tile, title, optional subtitle and trailing widget.
class B4ListRow extends StatelessWidget {
  const B4ListRow({
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.tone = B4Tone.normal,
    this.selected = false,
    this.toggled,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Replaces the icon tile.
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final B4Tone tone;
  final bool selected;

  /// For rows that act as a switch.
  final bool? toggled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = context.text;
    final (Color iconFg, Color iconBg) = switch (tone) {
      B4Tone.normal when selected => (p.onAccent, p.accent),
      B4Tone.normal => (p.textPrimary, p.surfaceVariant),
      B4Tone.primary => (p.accentText, p.accentSoft),
      B4Tone.success => (p.successText, p.successSoft),
      B4Tone.danger => (p.dangerText, p.dangerSoft),
    };

    final row = Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: padding,
      color: selected ? p.accentSoft : null,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 14),
          ] else if (icon != null) ...[
            B4IconTile(
              icon: icon!,
              color: iconFg,
              background: iconBg,
              size: 40,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: text.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: tone == B4Tone.danger ? p.dangerText : null,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: text.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          if (selected)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(RemixIcons.checkLine, color: p.primaryText),
            )
          else if (showChevron)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(RemixIcons.arrowRightSLine, color: p.textSecondary),
            ),
        ],
      ),
    );

    if (onTap == null && toggled == null) return row;
    return Pressable(
      onTap: onTap,
      selected: selected ? true : null,
      toggled: toggled,
      button: toggled == null,
      pressedScale: 1,
      child: row,
    );
  }
}

/// A circle holding an icon (category "logo", list row icon).
class B4IconTile extends StatelessWidget {
  const B4IconTile({
    required this.icon,
    this.color,
    this.background,
    this.size = 48,
    super.key,
  });

  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? p.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color ?? p.primaryText, size: size * 0.5),
    );
  }
}

/// Inline message with an icon, tinted by [tone].
class B4Note extends StatelessWidget {
  const B4Note({
    required this.text,
    this.tone = B4Tone.primary,
    this.icon,
    super.key,
  });

  final String text;
  final B4Tone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color fg, Color bg, IconData defaultIcon) = switch (tone) {
      B4Tone.success => (
        p.successText,
        p.successSoft,
        RemixIcons.checkboxCircleLine,
      ),
      B4Tone.danger => (
        p.dangerText,
        p.dangerSoft,
        RemixIcons.errorWarningLine,
      ),
      _ => (p.primaryText, p.primarySoft, RemixIcons.informationLine),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Tokens.inputRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.text.bodyLarge.copyWith(color: p.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muted caption above a group ("Pengingat", "Keamanan").
class B4GroupLabel extends StatelessWidget {
  const B4GroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: context.text.labelMedium.copyWith(
            color: context.palette.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Illustration tile, title, one sentence and an optional action.
class B4EmptyState extends StatelessWidget {
  const B4EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: p.accentSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 52, color: p.accentText),
        ),
        const SizedBox(height: Tokens.sectionGap),
        Text(
          title,
          style: context.text.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: context.text.bodyLarge.copyWith(color: p.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[
          const SizedBox(height: Tokens.sectionGap),
          action!,
        ],
      ],
    );
  }
}
