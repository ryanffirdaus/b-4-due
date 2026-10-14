import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'icons.dart';
import 'pressable.dart';
import 'surfaces.dart';
import 'theme.dart';
import 'tokens.dart';

/// On/off toggle: a squircle track with a square knob that slides across.
/// The knob keeps its size and carries no icon; position and fill tell the
/// state.
class B4Switch extends StatelessWidget {
  const B4Switch({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onChanged != null;
    return DisabledOpacity(
      enabled: enabled,
      child: Pressable(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onChanged!(!value);
              }
            : null,
        button: false,
        toggled: value,
        semanticLabel: semanticLabel,
        borderRadius: BorderRadius.circular(10),
        pressedScale: 0.96,
        child: SizedBox(
          width: 54,
          height: Tokens.minTouch,
          child: Center(
            child: AnimatedContainer(
              duration: Tokens.motion,
              curve: Tokens.curve,
              width: 54,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? p.primary : p.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: value ? p.primary : p.outlineStrong,
                  width: 1.5,
                ),
              ),
              child: AnimatedAlign(
                duration: Tokens.motion,
                curve: Tokens.curve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: Tokens.motion,
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: value ? p.onPrimary : p.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A list row whose whole area toggles a [B4Switch].
class B4SwitchRow extends StatelessWidget {
  const B4SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    // One tap target and one semantics node: the row is the switch.
    return DisabledOpacity(
      enabled: enabled,
      child: B4ListRow(
        title: title,
        subtitle: subtitle,
        icon: icon,
        toggled: value,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onChanged!(!value);
              }
            : null,
        trailing: IgnorePointer(
          child: ExcludeSemantics(
            child: B4Switch(value: value, onChanged: (_) {}),
          ),
        ),
      ),
    );
  }
}

/// Selectable chip with a leading ring: hollow when off, filled when on, so
/// the choice reads without relying on colour. Selected chips are filled
/// Plum; unselected ones sit on a soft fill without a border.
class B4Chip extends StatelessWidget {
  const B4Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.onPrimary : p.textPrimary;
    final radius = BorderRadius.circular(Tokens.chipRadius);
    return Pressable(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      selected: selected,
      borderRadius: radius,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: Tokens.motion,
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
        decoration: BoxDecoration(
          color: selected ? p.primary : p.surfaceVariant,
          borderRadius: radius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Ring(
              on: selected,
              color: selected ? p.onPrimary : p.outlineStrong,
            ),
            const SizedBox(width: 8),
            if (icon != null) ...[
              Icon(icon, size: 18, color: selected ? fg : p.textSecondary),
              const SizedBox(width: 6),
            ],
            Text(label, style: context.text.labelMedium.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.on, required this.color});

  final bool on;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Tokens.motion,
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: AnimatedContainer(
        duration: Tokens.motion,
        curve: Tokens.curve,
        width: on ? 6 : 0,
        height: on ? 6 : 0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

/// An applied filter with a remove button ("Listrik  ×").
class B4FilterTag extends StatelessWidget {
  const B4FilterTag({
    required this.label,
    required this.removeLabel,
    required this.onRemove,
    this.icon,
    super.key,
  });

  final String label;
  final String removeLabel;
  final VoidCallback onRemove;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: p.primarySoft,
        borderRadius: BorderRadius.circular(Tokens.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: p.primaryText),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: context.text.labelMedium.copyWith(color: p.primaryText),
          ),
          Pressable(
            onTap: onRemove,
            semanticLabel: removeLabel,
            excludeChildSemantics: true,
            borderRadius: BorderRadius.circular(Tokens.chipRadius),
            child: SizedBox.square(
              dimension: 40,
              child: Icon(RemixIcons.closeLine, size: 18, color: p.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
