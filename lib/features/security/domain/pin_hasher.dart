import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// A stored PIN: never the PIN itself, only a salted PBKDF2 hash.
@immutable
class PinHash {
  const PinHash({
    required this.hash,
    required this.salt,
    required this.iterations,
  });

  final String hash;
  final String salt;
  final int iterations;
}

/// PBKDF2-HMAC-SHA256 for app-lock PINs.
///
/// A 4-6 digit PIN has little entropy, so this mainly protects against
/// casual inspection of the database file (for example in a backup). The
/// app lock is a privacy screen, not encryption; the docs say so.
abstract final class PinHasher {
  static const defaultIterations = 100000;
  static const _keyLength = 32;

  static bool isValidPin(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  /// Hashes [pin] with a fresh random salt, off the UI isolate.
  static Future<PinHash> create(
    String pin, {
    int iterations = defaultIterations,
    Random? random,
  }) async {
    final rng = random ?? Random.secure();
    final salt = base64Encode(List<int>.generate(16, (_) => rng.nextInt(256)));
    final hash = await Isolate.run(() => derive(pin, salt, iterations));
    return PinHash(hash: hash, salt: salt, iterations: iterations);
  }

  /// Checks [pin] against [stored] in constant time.
  static Future<bool> verify(String pin, PinHash stored) async {
    final candidate = await Isolate.run(
      () => derive(pin, stored.salt, stored.iterations),
    );
    return _constantTimeEquals(candidate, stored.hash);
  }

  @visibleForTesting
  static String derive(String pin, String salt, int iterations) {
    final hmac = Hmac(sha256, utf8.encode(pin));
    final saltBytes = base64Decode(salt);
    // One block is enough: SHA-256 output equals the 32-byte key length.
    final block = Uint8List(saltBytes.length + 4)
      ..setAll(0, saltBytes)
      ..setAll(saltBytes.length, [0, 0, 0, 1]);
    var u = hmac.convert(block).bytes;
    final result = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < _keyLength; j++) {
        result[j] ^= u[j];
      }
    }
    return base64Encode(result);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
