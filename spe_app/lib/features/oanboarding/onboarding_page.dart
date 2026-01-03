import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../router/app_router.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_content.dart';
import 'widgets/onboarding_footer.dart';
import '../../core/config/colors.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) =>
                      ref.read(onboardingProvider.notifier).setPage(i),
                  children: const [
                    OnboardingContent(
                      image: 'assets/images/logo_app.png',
                      title: 'Bosan lawan tim yang itu-itu aja?',
                      subtitle:
                          'Temukan ratusan lawan mainmu\nlangsung dari SportEase.',
                    ),
                    OnboardingContent(
                      image: 'assets/images/logo_app.png',
                      title: 'Booking Lapangan Mudah',
                      subtitle:
                          'Pilih jam, tanggal, dan bayar\nsemua langsung dari aplikasi.',
                    ),
                    OnboardingContent(
                      image: 'assets/images/logo_app.png',
                      title: 'Gabung Komunitas',
                      subtitle: 'Bergabung dan buat komunitasmu\ntanpa ribet.',
                    ),
                  ],
                ),
              ),

              OnboardingFooter(
                index: index,
                onNext: () {
                  ref.read(onboardingProvider.notifier).nextPage();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                onSkip: () {
                  ref.read(onboardingProvider.notifier).skip();
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                onStart: () {
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
