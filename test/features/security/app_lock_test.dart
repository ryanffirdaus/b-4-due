import 'dart:convert';

import 'package:b4due/features/security/domain/app_lock.dart';
import 'package:b4due/features/security/domain/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

String _b64(String ascii) => base64Encode(utf8.encode(ascii));
String _hexOf(String b64) =>
    base64Decode(b64).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('PBKDF2-HMAC-SHA256 (RFC 7914 §11 vectors, first 32 bytes)', () {
    test('c = 1', () {
      expect(
        _hexOf(PinHasher.derive('passwd', _b64('salt'), 1)),
        '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc',
      );
    });

    test('c = 80000', () {
      expect(
        _hexOf(PinHasher.derive('Password', _b64('NaCl'), 80000)),
        '4ddcd8f60b98be21830cee5ef22701f9641a4418d04c0414aeff08876b34ab56',
      );
    });
  });

  group('PinHasher', () {
    test('verifies the right PIN and rejects others', () async {
      final stored = await PinHasher.create('2580', iterations: 1000);
      expect(await PinHasher.verify('2580', stored), isTrue);
      expect(await PinHasher.verify('2581', stored), isFalse);
      expect(await PinHasher.verify('258', stored), isFalse);
      expect(stored.hash, isNot(contains('2580')));
    });

    test('uses a fresh salt every time', () async {
      final a = await PinHasher.create('1234', iterations: 10);
      final b = await PinHasher.create('1234', iterations: 10);
      expect(a.salt, isNot(b.salt));
      expect(a.hash, isNot(b.hash));
    });

    test('accepts only 4 to 6 digits', () {
      expect(PinHasher.isValidPin('1234'), isTrue);
      expect(PinHasher.isValidPin('123456'), isTrue);
      expect(PinHasher.isValidPin('123'), isFalse);
      expect(PinHasher.isValidPin('1234567'), isFalse);
      expect(PinHasher.isValidPin('12a4'), isFalse);
    });
  });

  group('AppLockPolicy', () {
    test('locks out after five wrong PINs, doubling up to 15 minutes', () {
      expect(AppLockPolicy.lockoutAfter(4), isNull);
      expect(AppLockPolicy.lockoutAfter(5), const Duration(seconds: 30));
      expect(AppLockPolicy.lockoutAfter(6), const Duration(seconds: 60));
      expect(AppLockPolicy.lockoutAfter(7), const Duration(seconds: 120));
      expect(AppLockPolicy.lockoutAfter(50), const Duration(minutes: 15));
    });

    test('relocks only after a real absence', () {
      const config = AppLockConfig(
        pin: PinHash(hash: 'h', salt: 's', iterations: 1),
      );
      final left = DateTime.utc(2026, 8, 1, 10);
      expect(
        AppLockPolicy.shouldRelock(
          config: config,
          backgroundedAt: left,
          now: left.add(const Duration(seconds: 10)),
        ),
        isFalse,
        reason: 'share sheet / file picker',
      );
      expect(
        AppLockPolicy.shouldRelock(
          config: config,
          backgroundedAt: left,
          now: left.add(const Duration(minutes: 1)),
        ),
        isTrue,
      );
      expect(
        AppLockPolicy.shouldRelock(
          config: AppLockConfig.disabled,
          backgroundedAt: left,
          now: left.add(const Duration(hours: 1)),
        ),
        isFalse,
      );
    });
  });
}
