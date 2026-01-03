import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/colors.dart';
import 'auth_controller.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String email;
  final String role;
  final String name;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.role,
    required this.name,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  Timer? resendTimer;
  int resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    isEmailVerified = ref.read(authControllerProvider.notifier).isEmailVerified;

    if (!isEmailVerified) {
      // Cek status verifikasi setiap 3 detik
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    resendTimer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    try {
      await ref.read(authControllerProvider.notifier).reloadUser();
      final verified = ref
          .read(authControllerProvider.notifier)
          .isEmailVerified;

      if (verified) {
        setState(() {
          isEmailVerified = true;
        });
        timer?.cancel();

        // Navigate setelah verifikasi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email berhasil diverifikasi!'),
              backgroundColor: Colors.green,
            ),
          );

          // Delay untuk menampilkan snackbar
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            String route;
            if (widget.role == 'pengelola') {
              route = '/first-field-registration';
            } else if (widget.role == 'admin') {
              route = '/admin';
            } else {
              route = '/main';
            }
            Navigator.pushReplacementNamed(context, route);
          }
        }
      }
    } catch (e) {
      // Ignore errors during checking
    }
  }

  Future<void> resendVerificationEmail() async {
    if (!canResendEmail) return;

    try {
      await ref.read(authControllerProvider.notifier).sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verifikasi telah dikirim ulang!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Set countdown 60 detik
      setState(() {
        canResendEmail = false;
        resendCountdown = 60;
      });

      resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (resendCountdown > 0) {
          setState(() {
            resendCountdown--;
          });
        } else {
          setState(() {
            canResendEmail = true;
          });
          resendTimer?.cancel();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(authControllerProvider.notifier).logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEmailVerified ? Icons.check_circle : Icons.email_outlined,
                size: 100,
                color: isEmailVerified ? Colors.green : AppColors.primary,
              ),
              const SizedBox(height: 32),
              Text(
                isEmailVerified
                    ? 'Email Terverifikasi!'
                    : 'Verifikasi Email Anda',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isEmailVerified
                    ? 'Email Anda telah berhasil diverifikasi.\nAnda akan diarahkan ke aplikasi...'
                    : 'Kami telah mengirim email verifikasi ke:\n${widget.email}\n\nSilakan cek inbox atau folder spam Anda dan klik link verifikasi.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!isEmailVerified) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Menunggu verifikasi...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (!canResendEmail && resendCountdown > 0)
                  Text(
                    'Kirim ulang dalam $resendCountdown detik',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: canResendEmail ? resendVerificationEmail : null,
                  child: Text(
                    'Kirim Ulang Email Verifikasi',
                    style: TextStyle(
                      color: canResendEmail ? AppColors.primary : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Kembali ke Login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
