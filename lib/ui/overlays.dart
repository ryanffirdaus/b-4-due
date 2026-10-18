import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
import 'buttons.dart';
import 'icons.dart';
import 'pressable.dart';
import 'surfaces.dart';
import 'theme.dart';
import 'tokens.dart';

// ---------------------------------------------------------------------------
// Bottom sheet
// ---------------------------------------------------------------------------

/// Slides a sheet up from the bottom. Dismissed by dragging it down, tapping
/// the scrim, or the back button. [builder] content scrolls when it is taller
/// than 90% of the screen.
Future<T?> showB4Sheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
}) {
  final l10n = AppLocalizations.of(context);
  final theme = B4Theme.of(context);
  return Navigator.of(context, rootNavigator: true).push(
    _SheetRoute<T>(
      builder: builder,
      title: title,
      theme: theme,
      barrierLabel: l10n.actionClose,
    ),
  );
}

class _SheetRoute<T> extends PopupRoute<T> {
  _SheetRoute({
    required this.builder,
    required this.title,
    required this.theme,
    required this.barrierLabel,
  });

  final WidgetBuilder builder;
  final String? title;
  final B4ThemeData theme;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => theme.palette.scrim;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => Tokens.motionSlow;

  @override
  Duration get reverseTransitionDuration => Tokens.motion;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return B4Theme(
      data: theme,
      child: _SheetBody(
        title: title,
        onDragUpdate: (delta) =>
            controller!.value = (controller!.value - delta).clamp(0, 1),
        onDragEnd: (velocity) {
          if (velocity > 1.2 || controller!.value < 0.6) {
            Navigator.of(context).pop();
          } else {
            controller!.forward();
          }
        },
        child: Builder(builder: builder),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(
          parent: animation,
          curve: Tokens.curve,
          reverseCurve: Curves.easeInCubic,
        ),
      ),
      child: child,
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.title,
    required this.child,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final String? title;
  final Widget child;

  /// Fraction of the sheet height dragged.
  final ValueChanged<double> onDragUpdate;

  /// Downward fling velocity in sheet heights per second.
  final ValueChanged<double> onDragEnd;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final media = MediaQuery.of(context);
    final radius = const BorderRadius.vertical(
      top: Radius.circular(Tokens.sheetRadius),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (media.size.height - media.viewInsets.bottom) * 0.9,
            maxWidth: 640,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Container(
              decoration: BoxDecoration(color: p.surface, borderRadius: radius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    onVerticalDragUpdate: (d) =>
                        onDragUpdate(d.primaryDelta! / constraints.maxHeight),
                    onVerticalDragEnd: (d) => onDragEnd(
                      d.velocity.pixelsPerSecond.dy / constraints.maxHeight,
                    ),
                    // A header with a close button instead of a drag
                    // handle; the header still drags the sheet down.
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Tokens.pagePadding,
                        12,
                        10,
                        8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: title == null
                                ? const SizedBox.shrink()
                                : Semantics(
                                    header: true,
                                    child: Text(
                                      title!,
                                      style: context.text.headlineMedium,
                                    ),
                                  ),
                          ),
                          B4IconButton(
                            icon: RemixIcons.closeLine,
                            label: AppLocalizations.of(context).actionClose,
                            background: p.surfaceVariant,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: MediaQuery.removeViewInsets(
                      context: context,
                      removeBottom: true,
                      child: SafeArea(top: false, child: child),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

/// Centred dialog card that scales in: an icon tile, the title, the content,
/// and the [actions] side by side at equal width.
Future<T?> showB4Dialog<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder content,
  required List<Widget> Function(BuildContext context) actions,
  IconData icon = RemixIcons.informationLine,
  B4Tone tone = B4Tone.primary,
}) {
  final l10n = AppLocalizations.of(context);
  final theme = B4Theme.of(context);
  return Navigator.of(context, rootNavigator: true).push(
    _DialogRoute<T>(
      theme: theme,
      barrierLabel: l10n.actionClose,
      builder: (context) => _DialogCard(
        title: title,
        icon: icon,
        tone: tone,
        content: content(context),
        actions: actions(context),
      ),
    ),
  );
}

/// Asks for confirmation. Resolves to true only when the confirm button is
/// pressed.
Future<bool> showB4Confirm({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showB4Dialog<bool>(
    context: context,
    title: title,
    icon: destructive
        ? RemixIcons.errorWarningLine
        : RemixIcons.informationLine,
    tone: destructive ? B4Tone.danger : B4Tone.primary,
    content: (context) => Text(
      body,
      style: context.text.bodyLarge.copyWith(
        color: context.palette.textSecondary,
      ),
    ),
    actions: (context) => [
      B4Button.outline(
        label: l10n.actionCancel,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      B4Button(
        label: confirmLabel,
        destructive: destructive,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  return result ?? false;
}

class _DialogRoute<T> extends PopupRoute<T> {
  _DialogRoute({
    required this.builder,
    required this.theme,
    required this.barrierLabel,
  });

  final WidgetBuilder builder;
  final B4ThemeData theme;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => theme.palette.scrim;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => Tokens.motion;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => B4Theme(
    data: theme,
    child: Builder(builder: builder),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Tokens.curve);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween(begin: 0.94, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.title,
    required this.icon,
    required this.tone,
    required this.content,
    required this.actions,
  });

  final String title;
  final IconData icon;
  final B4Tone tone;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color iconFg, Color iconBg) = switch (tone) {
      B4Tone.danger => (p.dangerText, p.dangerSoft),
      B4Tone.success => (p.successText, p.successSoft),
      _ => (p.primaryText, p.primarySoft),
    };
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: Container(
                padding: const EdgeInsets.all(Tokens.pagePadding),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(Tokens.dialogRadius),
                  border: Border.all(color: p.outline),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: B4IconTile(
                        icon: icon,
                        color: iconFg,
                        background: iconBg,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: context.text.headlineMedium),
                    const SizedBox(height: 8),
                    Flexible(child: SingleChildScrollView(child: content)),
                    const SizedBox(height: Tokens.sectionGap),
                    Row(
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toast
// ---------------------------------------------------------------------------

enum B4ToastKind { success, info, error }

/// Short message at the top of the screen, optionally with one action
/// ("Urungkan"). Read with [B4Toast.of] before any `await`.
class B4Toast {
  B4Toast._(this._host);

  final _ToasterState _host;

  static B4Toast of(BuildContext context) {
    final host = context.findAncestorStateOfType<_ToasterState>();
    assert(host != null, 'No B4Toaster above this widget.');
    return B4Toast._(host!);
  }

  void show(
    String message, {
    B4ToastKind kind = B4ToastKind.success,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) => _host.show(_ToastData(message, kind, actionLabel, onAction, duration));

  void error(String message) => show(message, kind: B4ToastKind.error);

  void info(String message) => show(message, kind: B4ToastKind.info);

  void hide() => _host.hide();
}

class _ToastData {
  _ToastData(
    this.message,
    this.kind,
    this.actionLabel,
    this.onAction,
    this.duration,
  );

  final String message;
  final B4ToastKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
}

/// Hosts toasts above [child]; place it above the Navigator.
class B4Toaster extends StatefulWidget {
  const B4Toaster({required this.child, super.key});

  final Widget child;

  @override
  State<B4Toaster> createState() => _ToasterState();
}

class _ToasterState extends State<B4Toaster>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Tokens.motionSlow,
    reverseDuration: Tokens.motion,
  );
  _ToastData? _current;
  Timer? _timer;

  void show(_ToastData data) {
    _timer?.cancel();
    setState(() => _current = data);
    _controller.forward(from: _controller.value > 0 ? 0.6 : 0);
    _timer = Timer(data.duration, hide);
  }

  Future<void> hide() async {
    _timer?.cancel();
    if (_current == null) return;
    await _controller.reverse();
    if (mounted) setState(() => _current = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toast = _current;
    return Stack(
      children: [
        widget.child,
        if (toast != null)
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.paddingOf(context).top + 12,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, -1.4), end: Offset.zero)
                  .animate(
                    CurvedAnimation(parent: _controller, curve: Tokens.curve),
                  ),
              child: FadeTransition(
                opacity: _controller,
                child: _ToastCard(
                  data: toast,
                  onDismiss: hide,
                  onAction: () {
                    toast.onAction?.call();
                    hide();
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.data,
    required this.onDismiss,
    required this.onAction,
  });

  final _ToastData data;
  final VoidCallback onDismiss;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (IconData icon, Color badge, Color onBadge) = switch (data.kind) {
      B4ToastKind.success => (RemixIcons.checkLine, p.accent, p.onAccent),
      B4ToastKind.info => (
        RemixIcons.informationLine,
        p.onInverseSurface.withValues(alpha: 0.16),
        p.onInverseSurface,
      ),
      B4ToastKind.error => (
        RemixIcons.errorWarningLine,
        p.danger,
        const Color(0xFF15121D),
      ),
    };
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: GestureDetector(
          // Swipe up to dismiss.
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) < -200) onDismiss();
          },
          child: Semantics(
            liveRegion: true,
            container: true,
            // An inverted pill that drops from the top, like a wallet
            // notification, rather than a system snackbar.
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: EdgeInsets.fromLTRB(
                8,
                6,
                data.actionLabel == null ? 20 : 6,
                6,
              ),
              decoration: BoxDecoration(
                color: p.inverseSurface,
                borderRadius: BorderRadius.circular(Tokens.dockRadius),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: badge,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 22, color: onBadge),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        data.message,
                        style: context.text.bodyMedium.copyWith(
                          color: p.onInverseSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (data.actionLabel != null) ...[
                    const SizedBox(width: 8),
                    Pressable(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onAction();
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: Tokens.minTouch,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: p.accent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          data.actionLabel!,
                          style: context.text.labelMedium.copyWith(
                            color: p.onAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
