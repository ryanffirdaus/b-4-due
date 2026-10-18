import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// B4Due draws every control itself (lib/ui). Material and Cupertino
/// widgets must not creep back in.
void main() {
  test('lib/ never imports Material or Cupertino', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final text = file.readAsStringSync();
      if (RegExp(
        r'''import\s+['"]package:flutter/(material|cupertino)\.dart['"]''',
      ).hasMatch(text)) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty, reason: 'use lib/ui components instead');
  });
}
