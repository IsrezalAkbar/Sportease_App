import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingProvider = StateNotifierProvider<OnboardingController, int>((
  ref,
) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<int> {
  OnboardingController() : super(0);

  void nextPage() {
    if (state < 2) {
      state++;
    }
  }

  void skip() {
    state = 2;
  }

  void setPage(int page) {
    state = page;
  }
}
