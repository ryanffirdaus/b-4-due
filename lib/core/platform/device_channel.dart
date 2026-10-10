import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Small Android-only helpers implemented in `MainActivity.kt`. On other
/// platforms every call returns a neutral value, so iOS builds keep working.
class DeviceChannel {
  const DeviceChannel();

  static const _channel = MethodChannel('b4due/device');

  bool get _android => !kIsWeb && Platform.isAndroid;

  Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    if (!_android) return null;
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('b4due/device $method failed: $e');
      return null;
    }
  }

  /// Lower-case `Build.MANUFACTURER`, e.g. "xiaomi", "samsung".
  Future<String?> manufacturer() => _call<String>('manufacturer');

  /// True when Android will not restrict the app in the background. Always
  /// true off Android.
  Future<bool> isIgnoringBatteryOptimizations() async =>
      await _call<bool>('isIgnoringBatteryOptimizations') ?? true;

  Future<bool> requestIgnoreBatteryOptimizations() async =>
      await _call<bool>('requestIgnoreBatteryOptimizations') ?? false;

  /// Opens the manufacturer's auto-start screen if this phone has a known
  /// one. Returns false when none could be opened.
  Future<bool> openAutostartSettings() async =>
      await _call<bool>('openAutostartSettings') ?? false;

  Future<bool> openAppDetails() async =>
      await _call<bool>('openAppDetails') ?? false;

  /// Checks calendar permission without prompting.
  Future<bool> hasCalendarPermission() async =>
      await _call<bool>('hasCalendarPermission') ?? false;

  Future<void> setSecure({required bool secure}) =>
      _call<void>('setSecure', {'secure': secure});
}

final deviceChannelProvider = Provider((ref) => const DeviceChannel());
