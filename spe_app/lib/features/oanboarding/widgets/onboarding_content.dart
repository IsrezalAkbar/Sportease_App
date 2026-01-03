import 'package:flutter/material.dart';
import '../../../../core/config/colors.dart';

class OnboardingContent extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Image (placeholder)
        SizedBox(height: 320, child: Image.asset(image, fit: BoxFit.contain)),

        const SizedBox(height: 40),

        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
        ),
      ],
    );
  }
}
