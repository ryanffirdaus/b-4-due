import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/ui.dart';
import '../app_lock_controller.dart';

/// Settings card for the optional PIN / biometric app lock.
class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appLockConfigProvider);
    final biometricAvailable =
        ref.watch(biometricAvailableProvider).value ?? false;

    return B4ListGroup(
      children: [
        B4SwitchRow(
          icon: RemixIcons.lock2Line,
          title: l10n.securityPinLock,
          subtitle: l10n.securityPinLockHelp,
          value: config.enabled,
          onChanged: (on) async {
            if (on) {
              await context.push(Routes.setPin);
              return;
            }
            final toast = B4Toast.of(context);
            await ref.read(appLockConfigProvider.notifier).disable();
            toast.show(l10n.securityPinRemoved);
          },
        ),
        if (config.enabled) ...[
          B4ListRow(
            icon: RemixIcons.key2Line,
            title: l10n.securityChangePin,
            showChevron: true,
            onTap: () => context.push(Routes.setPin),
          ),
          B4SwitchRow(
            icon: RemixIcons.fingerprintLine,
            title: l10n.securityBiometric,
            subtitle: biometricAvailable
                ? null
                : l10n.securityBiometricUnavailable,
            value: config.biometricEnabled && biometricAvailable,
            onChanged: biometricAvailable
                ? (on) => ref
                      .read(appLockConfigProvider.notifier)
                      .setBiometric(enabled: on)
                : null,
          ),
        ],
      ],
    );
  }
}
