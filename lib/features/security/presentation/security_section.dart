import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: Text(l10n.securityPinLock),
            subtitle: Text(l10n.securityPinLockHelp),
            value: config.enabled,
            onChanged: (on) async {
              if (on) {
                await context.push(Routes.setPin);
                return;
              }
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(appLockConfigProvider.notifier).disable();
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.securityPinRemoved)),
              );
            },
          ),
          if (config.enabled) ...[
            const Divider(indent: 16),
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: Text(l10n.securityChangePin),
              onTap: () => context.push(Routes.setPin),
            ),
            const Divider(indent: 16),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: Text(l10n.securityBiometric),
              subtitle: biometricAvailable
                  ? null
                  : Text(
                      l10n.securityBiometricUnavailable,
                      style: TextStyle(color: context.palette.textSecondary),
                    ),
              value: config.biometricEnabled && biometricAvailable,
              onChanged: biometricAvailable
                  ? (on) => ref
                        .read(appLockConfigProvider.notifier)
                        .setBiometric(enabled: on)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
