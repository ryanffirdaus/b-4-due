import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../ui/ui.dart';

/// Bottom navigation (Home, Calendar, Subscriptions, Statistics, Settings)
/// around the five tab branches; each tab keeps its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return B4Scaffold(
      safeTop: false,
      body: navigationShell,
      bottomBar: B4BottomNav(
        selectedIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          // Tapping the current tab again returns to its first page.
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          B4NavItem(
            icon: RemixIcons.home5Line,
            activeIcon: RemixIcons.home5Fill,
            label: l10n.navHome,
          ),
          B4NavItem(
            icon: RemixIcons.calendar2Line,
            activeIcon: RemixIcons.calendar2Fill,
            label: l10n.navCalendar,
          ),
          B4NavItem(
            icon: RemixIcons.billLine,
            activeIcon: RemixIcons.billFill,
            label: l10n.navSubscriptions,
          ),
          B4NavItem(
            icon: RemixIcons.pieChart2Line,
            activeIcon: RemixIcons.pieChart2Fill,
            label: l10n.navStatistics,
          ),
          B4NavItem(
            icon: RemixIcons.settings3Line,
            activeIcon: RemixIcons.settings3Fill,
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
