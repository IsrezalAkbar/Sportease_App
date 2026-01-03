import 'package:flutter/material.dart';
import '../../../core/config/colors.dart';

class OnboardingFooter extends StatelessWidget {
  final int index;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onStart;

  const OnboardingFooter({
    super.key,
    required this.index,
    required this.onNext,
    required this.onSkip,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == i ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == i ? AppColors.primary : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Button
        if (index < 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onSkip,
                child: const Text(
                  "Lewati",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              ElevatedButton(
                onPressed: onNext,
                child: const Text("Selanjutnya"),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              child: const Text("Mulai Sekarang"),
            ),
          ),

        const SizedBox(height: 10),
      ],
    );
  }
}
