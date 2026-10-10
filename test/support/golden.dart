import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The reference images in test/goldens are rendered on Linux, like CI.
/// Font anti-aliasing differs on Windows and macOS, so there a mismatch is
/// reported as a warning instead of a failure. Set B4DUE_STRICT_GOLDENS=1
/// to compare strictly anywhere.
bool get _strict =>
    Platform.isLinux || Platform.environment['B4DUE_STRICT_GOLDENS'] == '1';

/// Tolerates tiny differences between Linux distributions and CPUs; layout
/// regressions change far more pixels than this.
const goldenTolerance = 0.002; // 0.2 %

void installTolerantGoldenComparator() {
  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(
      Uri.parse('${current.basedir}placeholder_test.dart'),
    );
  }
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= goldenTolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    if (_strict) throw FlutterError(error);
    debugPrint(
      'Golden "$golden" differs on ${Platform.operatingSystem} '
      '(${(result.diffPercent * 100).toStringAsFixed(2)}%); goldens are '
      'checked strictly on Linux/CI only.',
    );
    return true;
  }
}

var _fontsLoaded = false;

/// Loads every font declared in the app's FontManifest (the app font and
/// Material Icons) so goldens show real text instead of boxes.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    final loader = FontLoader(family.replaceFirst('packages/', ''));
    for (final font
        in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  _fontsLoaded = true;
}
