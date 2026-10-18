import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Code points mapped by a TrueType font's Unicode cmap (formats 4 and 12).
Set<int> _codePoints(String path) {
  final data = ByteData.sublistView(File(path).readAsBytesSync());
  final tables = data.getUint16(4);
  var cmap = -1;
  for (var i = 0; i < tables; i++) {
    final record = 12 + i * 16;
    if (String.fromCharCodes(data.buffer.asUint8List(record, 4)) == 'cmap') {
      cmap = data.getUint32(record + 8);
    }
  }
  expect(cmap, isNot(-1), reason: '$path has no cmap');

  final points = <int>{};
  final subtables = data.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final offset = cmap + data.getUint32(cmap + 4 + i * 8 + 4);
    switch (data.getUint16(offset)) {
      case 4:
        final segments = data.getUint16(offset + 6) ~/ 2;
        final ends = offset + 14;
        final starts = ends + segments * 2 + 2;
        for (var s = 0; s < segments; s++) {
          final end = data.getUint16(ends + s * 2);
          final start = data.getUint16(starts + s * 2);
          if (start == 0xFFFF) continue;
          for (var c = start; c <= end; c++) {
            points.add(c);
          }
        }
      case 12:
        final groups = data.getUint32(offset + 12);
        for (var g = 0; g < groups; g++) {
          final group = offset + 16 + g * 12;
          for (
            var c = data.getUint32(group);
            c <= data.getUint32(group + 4);
            c++
          ) {
            points.add(c);
          }
        }
    }
  }
  return points;
}

void main() {
  test('every weight of Sora draws every character in the UI text', () {
    final used = <int>{};
    for (final arb in ['lib/l10n/app_id.arb', 'lib/l10n/app_en.arb']) {
      final json = jsonDecode(File(arb).readAsStringSync()) as Map;
      for (final MapEntry(:key, :value) in json.entries) {
        if (key is String && !key.startsWith('@') && value is String) {
          used.addAll(value.runes.where((c) => c > 0x20));
        }
      }
    }
    // Built in code rather than in the ARB files.
    used.addAll('≈·…'.runes);

    for (final font in Directory('assets/fonts').listSync()) {
      if (!font.path.contains('Sora-') || !font.path.endsWith('.ttf')) {
        continue;
      }
      final missing = used.difference(_codePoints(font.path));
      expect(
        missing.map(String.fromCharCode).toList(),
        isEmpty,
        reason: '${font.path} cannot draw these; see tool/add_sora_glyphs.py',
      );
    }
  });
}
