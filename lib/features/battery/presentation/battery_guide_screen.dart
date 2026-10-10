import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/platform/device_channel.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../reminders/reminder_providers.dart';
import '../domain/phone_brand.dart';

final phoneBrandProvider = FutureProvider<PhoneBrand>(
  (ref) async => PhoneBrand.fromManufacturer(
    await ref.watch(deviceChannelProvider).manufacturer(),
  ),
);

/// Re-read after returning from system settings.
final batteryUnrestrictedProvider = FutureProvider<bool>(
  (ref) => ref.watch(deviceChannelProvider).isIgnoringBatteryOptimizations(),
);

extension PhoneBrandText on PhoneBrand {
  String label(AppLocalizations l10n) => switch (this) {
    PhoneBrand.xiaomi => l10n.brandXiaomi,
    PhoneBrand.oppo => l10n.brandOppo,
    PhoneBrand.vivo => l10n.brandVivo,
    PhoneBrand.samsung => l10n.brandSamsung,
    PhoneBrand.transsion => l10n.brandTranssion,
    PhoneBrand.huawei => l10n.brandHuawei,
    PhoneBrand.other => l10n.brandOther,
  };

  String steps(AppLocalizations l10n) => switch (this) {
    PhoneBrand.xiaomi => l10n.guideXiaomi,
    PhoneBrand.oppo => l10n.guideOppo,
    PhoneBrand.vivo => l10n.guideVivo,
    PhoneBrand.samsung => l10n.guideSamsung,
    PhoneBrand.transsion => l10n.guideTranssion,
    PhoneBrand.huawei => l10n.guideHuawei,
    PhoneBrand.other => l10n.guideOther,
  };
}

/// Per-brand guide for exempting the app from battery optimizations, with
/// one-tap shortcuts where Android allows them.
class BatteryGuideScreen extends ConsumerStatefulWidget {
  const BatteryGuideScreen({super.key});

  @override
  ConsumerState<BatteryGuideScreen> createState() => _BatteryGuideScreenState();
}

class _BatteryGuideScreenState extends ConsumerState<BatteryGuideScreen>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(batteryUnrestrictedProvider);
    }
  }

  Future<void> _openAutostart() async {
    final device = ref.read(deviceChannelProvider);
    if (!await device.openAutostartSettings()) await device.openAppDetails();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final device = ref.read(deviceChannelProvider);
    final brand = ref.watch(phoneBrandProvider).value ?? PhoneBrand.other;
    final unrestricted = ref.watch(batteryUnrestrictedProvider).value;
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: context.palette.textSecondary,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batteryTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.batteryIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          if (unrestricted != null)
            Card(
              child: ListTile(
                leading: Icon(
                  unrestricted
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: unrestricted
                      ? context.palette.primaryText
                      : context.palette.dangerText,
                ),
                title: Text(
                  unrestricted
                      ? l10n.batteryStatusOk
                      : l10n.batteryStatusRestricted,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (unrestricted == false) ...[
            FilledButton.icon(
              onPressed: device.requestIgnoreBatteryOptimizations,
              icon: const Icon(Icons.battery_charging_full),
              label: Text(l10n.batteryAllow),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: _openAutostart,
            icon: const Icon(Icons.settings_power),
            label: Text(l10n.batteryOpenAutostart),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: device.openAppDetails,
            icon: const Icon(Icons.info_outline),
            label: Text(l10n.batteryOpenAppInfo),
          ),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              l10n.batteryYourPhone(brand.label(l10n)),
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(brand.steps(l10n), style: theme.textTheme.bodyLarge),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.batteryMenuNote, style: secondary),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              l10n.batteryOtherBrands,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final other in PhoneBrand.values.where((b) => b != brand))
                  ExpansionTile(
                    title: Text(other.label(l10n)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      Text(other.steps(l10n), style: theme.textTheme.bodyLarge),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse('https://dontkillmyapp.com'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(l10n.batteryMoreInfo),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () =>
                ref.read(reminderRuntimeProvider).gateway.showTest(),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(l10n.settingsTestNotification),
          ),
        ],
      ),
    );
  }
}
