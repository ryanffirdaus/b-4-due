import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_lock_controller.dart';
import 'lock_screen.dart';

/// Covers [child] with the lock screen while the app is locked.
///
/// Used as `MaterialApp.builder`, so it sits above the Navigator: every
/// route (including one opened from a notification) stays alive underneath
/// and reappears after unlocking.
class AppLockGate extends ConsumerWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(appLockProvider.select((s) => s.locked));
    return Stack(
      children: [
        // Hidden from screen readers too, not just covered visually.
        ExcludeSemantics(excluding: locked, child: child),
        if (locked)
          Positioned.fill(
            // Its own Overlay: above the Navigator there is no other host
            // for tooltips.
            child: Overlay(
              initialEntries: [
                OverlayEntry(builder: (_) => const LockScreen()),
              ],
            ),
          ),
      ],
    );
  }
}
