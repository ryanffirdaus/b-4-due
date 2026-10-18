import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/platform/device_channel.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../reminders/reminder_providers.dart';
import '../onboarding_controller.dart';

enum _Step { welcome, notifications, exactAlarms, battery, test }

/// A short, linear setup: explain first, then ask for each permission.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with WidgetsBindingObserver {
  var _step = _Step.welcome;
  bool? _notificationsGranted;
  var _testSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system settings page.
    if (state != AppLifecycleState.resumed) return;
    if (_step == _Step.exactAlarms) _advanceFromExact();
    if (_step == _Step.battery) _advanceFromBattery();
  }

  /// Moves to the next step that still needs the user, skipping ones that
  /// are already fine on this phone.
  Future<void> _next() async {
    final status = await ref.read(reminderPermissionsProvider).status();
    final batteryOk = await ref
        .read(deviceChannelProvider)
        .isIgnoringBatteryOptimizations();
    if (!mounted) return;
    const order = _Step.values;
    var next = order[(order.indexOf(_step) + 1).clamp(0, order.length - 1)];
    bool needed(_Step s) => switch (s) {
      _Step.notifications => !status.notificationsAllowed,
      _Step.exactAlarms => !status.exactAlarmsAllowed,
      _Step.battery => !batteryOk,
      _ => true,
    };
    while (!needed(next)) {
      next = order[order.indexOf(next) + 1];
    }
    setState(() => _step = next);
  }

  Future<void> _advanceFromExact() async {
    final status = await ref.read(reminderPermissionsProvider).status();
    if (mounted && status.exactAlarmsAllowed) {
      setState(() => _step = _Step.test);
    }
  }

  Future<void> _advanceFromBattery() async {
    final ok = await ref
        .read(deviceChannelProvider)
        .isIgnoringBatteryOptimizations();
    if (mounted && ok) setState(() => _step = _Step.test);
  }

  Future<void> _requestNotifications() async {
    final granted = await ref
        .read(reminderPermissionsProvider)
        .requestNotifications();
    ref.invalidate(reminderPermissionStatusProvider);
    if (!mounted) return;
    setState(() => _notificationsGranted = granted);
  }

  Future<void> _sendTest() async {
    await ref.read(reminderRuntimeProvider).gateway.showTest();
    if (mounted) setState(() => _testSent = true);
  }

  Future<void> _finish() async {
    // Reminders may have been planned before permissions were granted.
    await ref.read(reminderRuntimeProvider).syncAll();
    await ref.read(onboardingCompletedProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final page = switch (_step) {
      _Step.welcome => _Page(
        icon: RemixIcons.notification3Line,
        title: l10n.onboardingWelcomeTitle,
        body: l10n.onboardingWelcomeBody,
        extra: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Point(RemixIcons.calendarCheckLine, l10n.onboardingPointReminders),
            _Point(RemixIcons.shieldUserLine, l10n.onboardingPointPrivate),
            _Point(RemixIcons.handCoinLine, l10n.onboardingPointFree),
          ],
        ),
        primary: _Action(l10n.onboardingStart, _next),
      ),
      _Step.notifications => _Page(
        icon: RemixIcons.notification3Line,
        title: l10n.onboardingNotifTitle,
        body: l10n.onboardingNotifBody,
        extra: switch (_notificationsGranted) {
          true => _Note(l10n.onboardingNotifGranted, ok: true),
          false => _Note(l10n.onboardingNotifDenied, ok: false),
          null => null,
        },
        primary: _notificationsGranted == null
            ? _Action(l10n.onboardingNotifAllow, _requestNotifications)
            : _Action(l10n.actionContinue, _next),
      ),
      _Step.exactAlarms => _Page(
        icon: RemixIcons.alarmLine,
        title: l10n.onboardingExactTitle,
        body: l10n.onboardingExactBody,
        primary: _Action(
          l10n.onboardingExactOpen,
          () => ref.read(reminderPermissionsProvider).requestExactAlarms(),
        ),
        secondary: _Action(l10n.onboardingSkip, _next),
      ),
      _Step.battery => _Page(
        icon: RemixIcons.battery2ChargeLine,
        title: l10n.onboardingBatteryTitle,
        body: l10n.onboardingBatteryBody,
        primary: _Action(l10n.batteryAllow, () async {
          await ref
              .read(deviceChannelProvider)
              .requestIgnoreBatteryOptimizations();
        }),
        secondary: _Action(l10n.actionContinue, _next),
        extra: Align(
          alignment: Alignment.centerLeft,
          child: B4Button.ghost(
            icon: RemixIcons.informationLine,
            label: l10n.onboardingBatteryGuide,
            onPressed: () => context.push(Routes.battery),
          ),
        ),
      ),
      _Step.test => _Page(
        icon: RemixIcons.checkboxCircleLine,
        title: l10n.onboardingTestTitle,
        body: l10n.onboardingTestBody,
        extra: _testSent ? _Note(l10n.onboardingTestSent, ok: true) : null,
        primary: _testSent
            ? _Action(l10n.onboardingFinish, _finish)
            : _Action(l10n.settingsTestNotification, _sendTest),
        secondary: _testSent
            ? _Action(l10n.settingsTestNotification, _sendTest)
            : _Action(l10n.onboardingSkip, _finish),
      ),
    };

    return B4Scaffold(body: SafeArea(top: false, child: page));
  }
}

class _Action {
  const _Action(this.label, this.onPressed);
  final String label;
  final VoidCallback onPressed;
}

class _Page extends StatelessWidget {
  const _Page({
    required this.icon,
    required this.title,
    required this.body,
    required this.primary,
    this.secondary,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? extra;
  final _Action primary;
  final _Action? secondary;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: B4IconTile(icon: icon, size: 72),
              ),
              const SizedBox(height: 28),
              Semantics(
                header: true,
                child: Text(title, style: text.displayMedium),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: text.bodyLarge.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
              if (extra != null) ...[const SizedBox(height: 28), extra!],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              B4Button(label: primary.label, onPressed: primary.onPressed),
              if (secondary != null) ...[
                const SizedBox(height: 8),
                B4Button.ghost(
                  label: secondary!.label,
                  onPressed: secondary!.onPressed,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          B4IconTile(icon: icon, size: 44),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: context.text.bodyLarge)),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text, {required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) =>
      B4Note(text: text, tone: ok ? B4Tone.success : B4Tone.danger);
}
