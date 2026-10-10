import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../app_lock_controller.dart';
import 'pin_pad.dart';

/// Full-screen lock shown on top of the app while locked.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String? _error;
  Timer? _ticker;
  var _showForgot = false;

  @override
  void initState() {
    super.initState();
    // Offer biometrics straight away when enabled.
    WidgetsBinding.instance.addPostFrameCallback((_) => _biometric());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _biometric() async {
    if (!ref.read(appLockConfigProvider).biometricEnabled) return;
    final reason = AppLocalizations.of(context).lockBiometricReason;
    await ref.read(appLockProvider.notifier).unlockWithBiometrics(reason);
  }

  Future<void> _pin(String pin) async {
    final ok = await ref.read(appLockProvider.notifier).unlockWithPin(pin);
    if (!ok && mounted) {
      setState(() => _error = AppLocalizations.of(context).lockWrongPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(appLockProvider);
    final config = ref.watch(appLockConfigProvider);
    final now = ref.read(clockProvider)();
    final lockedOut = state.isLockedOut(now);
    final message = lockedOut
        ? l10n.lockLockedOut(
            state.lockedOutUntil!.difference(now).inSeconds + 1,
          )
        : _error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: context.palette.primaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.lockTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                PinPad(
                  onCompleted: _pin,
                  enabled: !lockedOut,
                  message: message,
                  messageIsError: message != null,
                  extraAction: config.biometricEnabled
                      ? IconButton(
                          tooltip: l10n.lockUseBiometric,
                          iconSize: 32,
                          onPressed: _biometric,
                          icon: const Icon(Icons.fingerprint),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                // Inline rather than a dialog: the lock screen sits above the
                // app's Navigator.
                TextButton(
                  onPressed: () => setState(() => _showForgot = !_showForgot),
                  child: Text(l10n.lockForgot),
                ),
                if (_showForgot)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      l10n.lockForgotBody,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: context.palette.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
