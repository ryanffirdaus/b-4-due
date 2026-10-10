import 'dart:async';

import 'support/golden.dart';

/// Applies to every test in this directory tree.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  installTolerantGoldenComparator();
  await testMain();
}
