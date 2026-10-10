import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/providers.dart';
import 'domain/app_lock.dart';
import 'domain/pin_hasher.dart';

/// Lock configuration read before `runApp`, so a locked app never shows a
/// frame of content. Overridden in `main`.
final initialAppLockConfigProvider = Provider<AppLockConfig>(
  (ref) => AppLockConfig.disabled,
);

final appLockConfigProvider =
    NotifierProvider<AppLockConfigController, AppLockConfig>(
      AppLockConfigController.new,
    );

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);

final localAuthProvider = Provider<LocalAuthentication>(
  (ref) => LocalAuthentication(),
);

/// Whether this device can do fingerprint/face unlock right now.
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(localAuthProvider);
  try {
    return await auth.canCheckBiometrics &&
        (await auth.getAvailableBiometrics()).isNotEmpty;
  } on Object {
    return false;
  }
});

class AppLockConfigController extends Notifier<AppLockConfig> {
  @override
  AppLockConfig build() => ref.watch(initialAppLockConfigProvider);

  Future<void> setPin(String pin, {required bool biometric}) async {
    final hash = await PinHasher.create(pin);
    await _save(AppLockConfig(pin: hash, biometricEnabled: biometric));
  }

  Future<void> setBiometric({required bool enabled}) =>
      _save(AppLockConfig(pin: state.pin, biometricEnabled: enabled));

  Future<void> disable() => _save(AppLockConfig.disabled);

  Future<void> _save(AppLockConfig config) async {
    await ref.read(settingsRepositoryProvider).saveAppLock(config);
    state = config;
  }
}

class AppLockController extends Notifier<AppLockState> {
  DateTime? _backgroundedAt;

  @override
  AppLockState build() =>
      AppLockState(locked: ref.read(appLockConfigProvider).enabled);

  DateTime _now() => ref.read(clockProvider)();

  void onBackgrounded() => _backgroundedAt ??= _now();

  void onResumed() {
    final shouldLock = AppLockPolicy.shouldRelock(
      config: ref.read(appLockConfigProvider),
      backgroundedAt: _backgroundedAt,
      now: _now(),
    );
    _backgroundedAt = null;
    if (shouldLock) {
      state = AppLockState(locked: true, lockedOutUntil: state.lockedOutUntil);
    }
  }

  /// Returns false for a wrong PIN or while locked out.
  Future<bool> unlockWithPin(String pin) async {
    final now = _now();
    final pinHash = ref.read(appLockConfigProvider).pin;
    if (pinHash == null) return _unlock();
    if (state.isLockedOut(now)) return false;
    if (await PinHasher.verify(pin, pinHash)) return _unlock();

    final failed = state.failedAttempts + 1;
    final lockout = AppLockPolicy.lockoutAfter(failed);
    state = AppLockState(
      locked: true,
      failedAttempts: failed,
      lockedOutUntil: lockout == null ? null : _now().add(lockout),
    );
    return false;
  }

  Future<bool> unlockWithBiometrics(String reason) async {
    if (!ref.read(appLockConfigProvider).biometricEnabled) return false;
    try {
      final ok = await ref
          .read(localAuthProvider)
          .authenticate(
            localizedReason: reason,
            biometricOnly: true,
            persistAcrossBackgrounding: true,
          );
      return ok ? _unlock() : false;
    } on Object {
      return false;
    }
  }

  bool _unlock() {
    state = const AppLockState(locked: false);
    return true;
  }
}
