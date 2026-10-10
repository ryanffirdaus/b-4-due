import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/battery/presentation/battery_guide_screen.dart';
import '../features/bills/presentation/bill_detail_screen.dart';
import '../features/bills/presentation/bill_form_screen.dart';
import '../features/bills/presentation/subscriptions_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/insights/presentation/calendar_screen.dart';
import '../features/insights/presentation/statistics_screen.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/payments/presentation/payment_history_screen.dart';
import '../features/security/presentation/set_pin_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/templates/presentation/template_picker_screen.dart';
import 'routes.dart';
import 'shell.dart';

/// Where the app opens; overridden when launched from a notification.
final initialLocationProvider = Provider<String>((ref) => Routes.home);

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Pages pushed above the bottom navigation (full screen, with back).
  GoRoute page(String path, Widget Function(GoRouterState) build) => GoRoute(
    path: path,
    parentNavigatorKey: _rootKey,
    builder: (context, state) => build(state),
  );

  GoRoute tab(String path, Widget screen) =>
      GoRoute(path: path, builder: (context, state) => screen);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: ref.read(initialLocationProvider),
    redirect: (context, state) {
      final onboarded = ref.read(onboardingCompletedProvider);
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      // The battery guide is reachable from onboarding itself.
      final allowedDuringOnboarding =
          atOnboarding || state.matchedLocation == Routes.battery;
      if (!onboarded && !allowedDuringOnboarding) return Routes.onboarding;
      if (onboarded && atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [tab(Routes.home, const HomeScreen())]),
          StatefulShellBranch(
            routes: [tab(Routes.calendar, const CalendarScreen())],
          ),
          StatefulShellBranch(
            routes: [tab(Routes.subscriptions, const SubscriptionsScreen())],
          ),
          StatefulShellBranch(
            routes: [tab(Routes.statistics, const StatisticsScreen())],
          ),
          StatefulShellBranch(
            routes: [tab(Routes.settings, const SettingsScreen())],
          ),
        ],
      ),
      page(Routes.onboarding, (_) => const OnboardingScreen()),
      page(Routes.addBill, (_) => const TemplatePickerScreen()),
      page(
        '/add/form',
        (state) =>
            BillFormScreen(templateKey: state.uri.queryParameters['template']),
      ),
      page(
        '/bill/:id',
        (state) => BillDetailScreen(billId: state.pathParameters['id']!),
      ),
      page(
        '/bill/:id/edit',
        (state) => _EditBillLoader(billId: state.pathParameters['id']!),
      ),
      page(Routes.history, (_) => const PaymentHistoryScreen()),
      page(Routes.setPin, (_) => const SetPinScreen()),
      page(Routes.battery, (_) => const BatteryGuideScreen()),
    ],
  );
  ref
    ..listen(onboardingCompletedProvider, (_, _) => router.refresh())
    ..onDispose(router.dispose);
  return router;
});

/// Loads the bill once, then shows the form. Not watching the stream keeps
/// background changes from resetting what the user is typing.
class _EditBillLoader extends ConsumerStatefulWidget {
  const _EditBillLoader({required this.billId});

  final String billId;

  @override
  ConsumerState<_EditBillLoader> createState() => _EditBillLoaderState();
}

class _EditBillLoaderState extends ConsumerState<_EditBillLoader> {
  late final _bill = ref.read(billRepositoryProvider).findById(widget.billId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bill,
      builder: (context, snapshot) {
        final bill = snapshot.data;
        if (bill != null) return BillFormScreen(bill: bill);
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(appBar: AppBar());
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
