import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/features/security/app_lock_controller.dart';
import 'package:b4due/features/security/domain/app_lock.dart';
import 'package:b4due/features/security/domain/pin_hasher.dart';
import 'package:b4due/features/security/presentation/app_lock_gate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';

void main() {
  testWidgets('locked: secret content is hidden, also from screen readers; '
      'the right PIN unlocks', (tester) async {
    final pin = await tester.runAsync(
      () => PinHasher.create('2580', iterations: 10),
    );
    final semantics = tester.ensureSemantics();

    await pumpScreen(
      tester,
      const AppLockGate(child: Center(child: Text('Saldo rahasia'))),
      today: LocalDate(2026, 8, 10),
      overrides: [
        initialAppLockConfigProvider.overrideWithValue(AppLockConfig(pin: pin)),
      ],
    );

    expect(find.text('Masukkan PIN'), findsOneWidget);
    expect(find.bySemanticsLabel('Saldo rahasia'), findsNothing);

    for (final digit in ['2', '5', '8', '0']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.tap(find.bySemanticsLabel('OK'));
    // PBKDF2 runs in a real isolate.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Masukkan PIN'), findsNothing);
    expect(find.bySemanticsLabel('Saldo rahasia'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('unlocked when no PIN is set', (tester) async {
    await pumpScreen(
      tester,
      const AppLockGate(child: Center(child: Text('Beranda'))),
      today: LocalDate(2026, 8, 10),
    );
    expect(find.text('Masukkan PIN'), findsNothing);
    expect(find.text('Beranda'), findsOneWidget);
  });
}
