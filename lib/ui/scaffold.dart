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
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: bottomBar == null ? keyboard : 0,
                    ),
                    child: content,
                  ),
                ),
                if (bottomBar != null && keyboard == 0) bottomBar!,
              ],
            ),
            if (floatingAction != null)
              Positioned(
                right: Tokens.pagePadding,
                bottom:
                    Tokens.cardGap +
                    (bottomBar == null ? media.padding.bottom + keyboard : 0),
                child: floatingAction!,
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

/// Bottom navigation: a dock floating above the page edge. The active tab
/// gets a Plum marker hanging from the dock's top edge, like the tab on a
/// calendar divider, above a filled icon.
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

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 4, 12, 10 + bottom),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(Tokens.dockRadius),
          border: Border.all(color: p.outline),
          boxShadow: p.isDark
              ? null
              : [
                  BoxShadow(
                    color: p.shadow,
                    blurRadius: 24,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _NavButton(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () {
                    if (i != selectedIndex) HapticFeedback.selectionClick();
                    onSelect(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final B4NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.primaryText : p.textSecondary;
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: item.label,
      excludeChildSemantics: true,
      borderRadius: BorderRadius.circular(16),
      pressedScale: 0.94,
      pressedOverlay: const Color(0x00000000),
      child: SizedBox(
        height: 62,
        child: Column(
          children: [
            // The tab marker, flush with the dock's top edge.
            AnimatedContainer(
              duration: Tokens.motion,
              curve: Tokens.curve,
              width: selected ? 28 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: p.primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(3),
                ),
              ),
            ),
            const Spacer(),
            Icon(selected ? item.activeIcon : item.icon, color: fg, size: 24),
            const SizedBox(height: 4),
            // 14sp like all text; only a label too wide for its slot is
            // scaled down, so it is never cut off.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                textScaler: MediaQuery.textScalerOf(context)
                    .clamp(maxScaleFactor: 1.3),
                style: context.text.labelMedium.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
