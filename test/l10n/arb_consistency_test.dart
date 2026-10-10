import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads an ARB file, failing on duplicate keys (which JSON decoders
/// silently accept, keeping only the last value).
Map<String, Object?> _readArb(String path) {
  final text = File(path).readAsStringSync();
  final keys = RegExp(
    r'^\s{2}"([^"]+)":',
    multiLine: true,
  ).allMatches(text).map((m) => m.group(1)!).toList();
  final duplicates = <String>{
    for (final k in keys)
      if (keys.where((x) => x == k).length > 1) k,
  };
  expect(duplicates, isEmpty, reason: 'duplicate keys in $path');
  return jsonDecode(text) as Map<String, Object?>;
}

void main() {
  test('Indonesian and English ARB files define the same messages', () {
    Set<String> messages(Map<String, Object?> arb) =>
        arb.keys.where((k) => !k.startsWith('@')).toSet();

    final id = messages(_readArb('lib/l10n/app_id.arb'));
    final en = messages(_readArb('lib/l10n/app_en.arb'));

    expect(id.difference(en), isEmpty, reason: 'missing in English');
    expect(en.difference(id), isEmpty, reason: 'missing in Indonesian');
  });
}
