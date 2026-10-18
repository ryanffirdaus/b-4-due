import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/platform/device_channel.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
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
    final text = context.text;
    final device = ref.read(deviceChannelProvider);
    final brand = ref.watch(phoneBrandProvider).value ?? PhoneBrand.other;
    final unrestricted = ref.watch(batteryUnrestrictedProvider).value;

    return B4Scaffold(
      topBar: B4TopBar(title: l10n.batteryTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Tokens.pagePadding,
          8,
          Tokens.pagePadding,
          32,
        ),
        children: [
          Text(l10n.batteryIntro, style: text.bodyLarge),
          const SizedBox(height: Tokens.cardGap),
          if (unrestricted != null) ...[
            B4Note(
              text: unrestricted
                  ? l10n.batteryStatusOk
                  : l10n.batteryStatusRestricted,
              tone: unrestricted ? B4Tone.success : B4Tone.danger,
            ),
            const SizedBox(height: Tokens.listGap),
          ],
          if (unrestricted == false) ...[
            B4Button(
              icon: RemixIcons.battery2ChargeLine,
              label: l10n.batteryAllow,
              onPressed: device.requestIgnoreBatteryOptimizations,
            ),
            const SizedBox(height: 8),
          ],
          B4Button.outline(
            icon: RemixIcons.restartLine,
            label: l10n.batteryOpenAutostart,
            onPressed: _openAutostart,
          ),
          const SizedBox(height: 8),
          B4Button.outline(
            icon: RemixIcons.informationLine,
            label: l10n.batteryOpenAppInfo,
            onPressed: device.openAppDetails,
          ),
          B4GroupLabel(l10n.batteryYourPhone(brand.label(l10n))),
          B4Card(child: Text(brand.steps(l10n), style: text.bodyLarge)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l10n.batteryMenuNote, style: text.bodySmall),
          ),
          B4GroupLabel(l10n.batteryOtherBrands),
          B4Card(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Tokens.cardRadius),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, other)
                      in PhoneBrand.values
                          .where((b) => b != brand)
                          .indexed) ...[
                    if (i > 0) const B4Divider(indent: 16),
                    B4Expandable(
                      title: other.label(l10n),
                      child: Text(other.steps(l10n), style: text.bodyLarge),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.cardGap),
          B4Button.ghost(
            icon: RemixIcons.externalLinkLine,
            label: l10n.batteryMoreInfo,
            onPressed: () => launchUrl(
              Uri.parse('https://dontkillmyapp.com'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: 8),
          B4Button.tonal(
            icon: RemixIcons.notification3Line,
            label: l10n.settingsTestNotification,
            onPressed: () =>
                ref.read(reminderRuntimeProvider).gateway.showTest(),
          ),
        ],
      ),
    );
  }
}
