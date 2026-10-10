import 'package:meta/meta.dart';

import 'pin_hasher.dart';

/// Persisted app-lock configuration.
@immutable
class AppLockConfig {
  const AppLockConfig({this.pin, this.biometricEnabled = false});

  static const disabled = AppLockConfig();

  final PinHash? pin;

  /// Offer fingerprint/face unlock in addition to the PIN.
  final bool biometricEnabled;

  bool get enabled => pin != null;
}

/// Lock screen state.
@immutable
class AppLockState {
  const AppLockState({
    required this.locked,
    this.failedAttempts = 0,
    this.lockedOutUntil,
  });

  final bool locked;
  final int failedAttempts;

  /// Set after too many wrong PINs; input is refused until then.
  final DateTime? lockedOutUntil;

  bool isLockedOut(DateTime now) =>
      lockedOutUntil != null && now.isBefore(lockedOutUntil!);
}

/// Pure rules for wrong-PIN throttling and re-locking.
abstract final class AppLockPolicy {
  /// Free attempts before the first lockout.
  static const freeAttempts = 5;

  /// Leaving the app for less than this (a share sheet, the file picker, the
  /// biometric prompt) does not lock it again.
  static const relockAfter = Duration(seconds: 30);

  /// 30 s after 5 failures, doubling for each further failure, max 15 min.
  static Duration? lockoutAfter(int failedAttempts) {
    if (failedAttempts < freeAttempts) return null;
    final steps = failedAttempts - freeAttempts;
    final seconds = 30 * (1 << steps.clamp(0, 5));
    return Duration(seconds: seconds.clamp(30, 15 * 60));
  }

  static bool shouldRelock({
    required AppLockConfig config,
    required DateTime? backgroundedAt,
    required DateTime now,
  }) {
    if (!config.enabled || backgroundedAt == null) return false;
    return now.difference(backgroundedAt) >= relockAfter;
  }
}
