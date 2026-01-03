import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/colors.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String selectedRole = 'user';

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Lewati",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),

              Text("Masuk", style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: 24),

              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  hintText: "Email atau Username",
                  helperText: "Anda bisa login menggunakan email atau username",
                  helperMaxLines: 2,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Kata Sandi"),
              ),

              const SizedBox(height: 24),

              const Text(
                "Masuk sebagai:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('User'),
                    value: 'user',
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setState(() => selectedRole = value!);
                    },
                    activeColor: AppColors.primary,
                    dense: true,
                  ),
                  RadioListTile<String>(
                    title: const Text('Pengelola Lapangan'),
                    value: 'pengelola',
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setState(() => selectedRole = value!);
                    },
                    activeColor: AppColors.primary,
                    dense: true,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(authControllerProvider.notifier)
                        .login(
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                          context: context,
                          selectedRole: selectedRole,
                        );
                  },
                  child: const Text("Masuk"),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/register"),
                  child: const Text(
                    "Belum punya akun SPE? Yuk Daftar",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
