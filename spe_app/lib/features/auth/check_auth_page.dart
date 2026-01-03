import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'auth_service.dart';
import '../../data/repositories/field_repo.dart';

class CheckAuthPage extends ConsumerWidget {
  const CheckAuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, "/onboarding");
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Cek verifikasi email (kecuali untuk admin)
    final authService = AuthService();
    final currentUser = authService.currentUser;
    if (currentUser != null &&
        !currentUser.emailVerified &&
        authState.user!.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/email-verification',
          arguments: {
            'email': authState.user!.email,
            'role': authState.user!.role,
            'name': authState.user!.name,
          },
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Untuk pengelola, perlu cek approval status
    if (authState.user!.role == 'pengelola') {
      return FutureBuilder<bool>(
        future: FieldRepo().hasApprovedField(authState.user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final hasApproved = snapshot.data!;
          String target;

          if (hasApproved) {
            target = "/manager";
          } else {
            // Cek apakah sudah pernah submit lapangan
            return FutureBuilder<List<dynamic>>(
              future: FieldRepo().getByOwner(authState.user!.uid).first,
              builder: (context, fieldSnapshot) {
                if (!fieldSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final fields = fieldSnapshot.data!;
                final route = fields.isNotEmpty
                    ? "/pending-approval"
                    : "/first-field-registration";

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, route);
                });

                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, target);
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    // Untuk admin atau user biasa
    final target = authState.user!.role == 'admin' ? '/admin' : '/main';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, target);
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
