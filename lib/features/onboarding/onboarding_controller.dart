import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Whether onboarding was completed, read before `runApp` and overridden in
/// `main` so the first frame already knows where to go.
final initialOnboardingCompletedProvider = Provider<bool>((ref) => true);

final onboardingCompletedProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.watch(initialOnboardingCompletedProvider);

  Future<void> complete() async {
    await ref
        .read(settingsRepositoryProvider)
        .setOnboardingCompleted(completed: true);
    state = true;
  }
}
