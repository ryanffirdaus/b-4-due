import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../app_lock_controller.dart';
import '../domain/pin_hasher.dart';
import 'pin_pad.dart';

enum _Stage { verifyCurrent, enter, confirm }

/// Create or change the PIN: (current PIN), new PIN, repeat.
class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  late _Stage _stage = ref.read(appLockConfigProvider).enabled
      ? _Stage.verifyCurrent
      : _Stage.enter;
  String? _first;
  String? _error;

  Future<void> _onPin(String pin) async {
    final l10n = AppLocalizations.of(context);
    switch (_stage) {
      case _Stage.verifyCurrent:
        final current = ref.read(appLockConfigProvider).pin!;
        final ok = await PinHasher.verify(pin, current);
        setState(() {
          _error = ok ? null : l10n.lockWrongPin;
          if (ok) _stage = _Stage.enter;
        });
      case _Stage.enter:
        if (!PinHasher.isValidPin(pin)) return;
        setState(() {
          _first = pin;
          _error = null;
          _stage = _Stage.confirm;
        });
      case _Stage.confirm:
        if (pin != _first) {
          setState(() {
            _first = null;
            _error = l10n.securityPinMismatch;
            _stage = _Stage.enter;
          });
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        final config = ref.read(appLockConfigProvider);
        await ref
            .read(appLockConfigProvider.notifier)
            .setPin(pin, biometric: config.biometricEnabled);
        messenger.showSnackBar(SnackBar(content: Text(l10n.securityPinSaved)));
        if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (_stage) {
      _Stage.verifyCurrent => l10n.securityConfirmCurrentPin,
      _Stage.enter => l10n.securitySetPinTitle,
      _Stage.confirm => l10n.securityConfirmPinTitle,
    };
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              PinPad(
                // A new key per stage resets the entered digits.
                key: ValueKey(_stage),
                onCompleted: _onPin,
                message: _error,
                messageIsError: _error != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
