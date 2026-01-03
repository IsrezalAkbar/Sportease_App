import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/config/colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Singkat saja agar terasa responsif
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/check');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Ruby red
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer soft ring
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
              ),
            ),
            // Middle ring
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            // Inner circle
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
            // Center logo image from assets
            Image.asset(
              'assets/images/logo_app.png',
              width: 56,
              height: 56,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
