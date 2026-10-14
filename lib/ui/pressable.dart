import 'package:flutter/widgets.dart';

import 'theme.dart';
import 'tokens.dart';

/// The tap primitive behind every interactive component: a slight press
/// scale and tint instead of a ripple, keyboard activation, a focus ring,
/// and button semantics.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    this.selected,
    this.toggled,
    this.button = true,
    this.pressedScale = 0.98,
    this.pressedOverlay,
    this.excludeChildSemantics = false,
    super.key,
  });

  final Widget child;

  /// Null disables the control.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;

  /// Accessible name, for controls whose child is only an icon.
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;
  final bool button;
  final double pressedScale;

  /// Tint while pressed; defaults to a faint text-coloured wash.
  final Color? pressedOverlay;
  final bool excludeChildSemantics;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  var _pressed = false;
  var _focused = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final showFocus =
        _focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

    Widget child = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      foregroundDecoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: _pressed
            ? widget.pressedOverlay ?? p.textPrimary.withValues(alpha: 0.06)
            : null,
        border: showFocus ? Border.all(color: p.primary, width: 2) : null,
      ),
      child: widget.child,
    );

    child = AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: child,
    );

    return Semantics(
      container: true,
      button: widget.button,
      enabled: _enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeChildSemantics,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: FocusableActionDetector(
        enabled: _enabled,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: child,
        ),
      ),
    );
  }
}

/// Fades a disabled control.
class DisabledOpacity extends StatelessWidget {
  const DisabledOpacity({
    required this.enabled,
    required this.child,
    super.key,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: enabled ? 1 : 0.45,
    duration: Tokens.motion,
    child: child,
  );
}
