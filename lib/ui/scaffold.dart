import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
import 'buttons.dart';
import 'icons.dart';
import 'pressable.dart';
import 'theme.dart';
import 'tokens.dart';

/// Page frame: background, system bar styling, optional top bar, body,
/// floating action and bottom bar. The body is lifted above the keyboard.
class B4Scaffold extends StatelessWidget {
  const B4Scaffold({
    required this.body,
    this.topBar,
    this.floatingAction,
    this.bottomBar,
    this.safeTop = true,
    super.key,
  });

  final Widget body;

  /// Usually a [B4TopBar]; it handles the status bar inset itself.
  final Widget? topBar;
  final Widget? floatingAction;
  final Widget? bottomBar;

  /// Pad the body below the status bar when there is no [topBar].
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;

    Widget content = MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: body,
    );
    if (topBar != null) {
      content = MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: content,
      );
    } else if (safeTop) {
      content = SafeArea(bottom: false, child: content);
    }
    if (bottomBar != null) {
      // The bar owns the bottom inset.
      content = MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: content,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarsFor(p),
      child: ColoredBox(
        color: p.background,
        child: Stack(
          children: [
            Column(
              children: [
                ?topBar,
                Expanded(
                  // The floating action sits over the content, just above
                  // the bottom bar.
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: bottomBar == null ? keyboard : 0,
                          ),
                          child: content,
                        ),
                      ),
                      if (floatingAction != null &&
                          (bottomBar == null || keyboard == 0))
                        Positioned(
                          right: Tokens.pagePadding,
                          bottom: bottomBar == null
                              ? Tokens.cardGap + media.padding.bottom + keyboard
                              : 4,
                          child: floatingAction!,
                        ),
                    ],
                  ),
                ),
                if (bottomBar != null && keyboard == 0) bottomBar!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar for pushed pages: back button, optional title and actions.
class B4TopBar extends StatelessWidget {
  const B4TopBar({this.title, this.actions = const [], this.onBack, super.key});

  final String? title;
  final List<Widget> actions;

  /// Defaults to popping the current route when there is one.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPop = onBack != null || Navigator.of(context).canPop();
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 6),
            if (canPop)
              B4IconButton(
                icon: RemixIcons.arrowLeftLine,
                label: l10n.actionBack,
                filled: true,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            else
              const SizedBox(width: 10),
            const SizedBox(width: 4),
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style: context.text.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
            ...actions,
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

/// Large title at the top of a tab screen (no back button).
class B4PageTitle extends StatelessWidget {
  const B4PageTitle(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Tokens.pagePadding,
        Tokens.cardGap,
        Tokens.pagePadding - 8,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text, style: context.text.displayMedium),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Section title with an optional trailing action ("Lihat semua").
class B4SectionHeader extends StatelessWidget {
  const B4SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.sectionGap, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: context.text.headlineMedium),
            ),
          ),
          if (actionLabel != null)
            B4Button.ghost(label: actionLabel!, onPressed: onAction),
        ],
      ),
    );
  }
}

class B4NavItem {
  const B4NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Bottom navigation: a floating pill of tab icons. The active tab is a
/// filled capsule that also shows its label when there is room; every tab
/// keeps its spoken label.
class B4BottomNav extends StatelessWidget {
  const B4BottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    super.key,
  });

  final List<B4NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _iconSlot = 46.0;
  static const _capsulePadding = 14.0;
  static const _iconSize = 22.0;
  static const _labelGap = 6.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final labelStyle = context.text.labelMedium.copyWith(
      color: p.onPrimary,
      fontWeight: FontWeight.w700,
    );
    final scaler = MediaQuery.textScalerOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 6, 14, 12 + bottom),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: Tokens.dockHeight,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(Tokens.dockRadius),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Room left for the active label once every icon fits.
                  final room =
                      constraints.maxWidth -
                      items.length * _iconSlot -
                      2 * _capsulePadding -
                      _labelGap;
                  final label = items[selectedIndex].label;
                  final painter = TextPainter(
                    text: TextSpan(text: label, style: labelStyle),
                    textDirection: TextDirection.ltr,
                    textScaler: scaler,
                    maxLines: 1,
                  )..layout();
                  final showLabel = painter.width <= room;
                  painter.dispose();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _NavButton(
                          item: items[i],
                          selected: i == selectedIndex,
                          showLabel: showLabel,
                          labelStyle: labelStyle,
                          onTap: () {
                            if (i != selectedIndex) {
                              HapticFeedback.selectionClick();
                            }
                            onSelect(i);
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.labelStyle,
    required this.onTap,
  });

  final B4NavItem item;
  final bool selected;
  final bool showLabel;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final expanded = selected && showLabel;
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: item.label,
      excludeChildSemantics: true,
      borderRadius: BorderRadius.circular(24),
      pressedScale: 0.92,
      pressedOverlay: const Color(0x00000000),
      child: AnimatedContainer(
        duration: Tokens.motion,
        curve: Tokens.curve,
        height: Tokens.minTouch,
        constraints: const BoxConstraints(minWidth: B4BottomNav._iconSlot),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? B4BottomNav._capsulePadding : 0,
        ),
        decoration: BoxDecoration(
          color: selected ? p.primary : const Color(0x00000000),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: B4BottomNav._iconSize,
              color: selected ? p.onPrimary : p.textSecondary,
            ),
            if (expanded) ...[
              const SizedBox(width: B4BottomNav._labelGap),
              Text(item.label, maxLines: 1, style: labelStyle),
            ],
          ],
        ),
      ),
    );
  }
}
