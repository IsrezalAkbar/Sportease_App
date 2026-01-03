import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/colors.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_button.dart';
import 'widgets/profile_section.dart';
import '../auth/auth_controller.dart';
import 'edit_profile_page.dart';
import 'pages/change_password_page.dart';
import 'pages/my_communities_page.dart';
import 'pages/my_sparring_page.dart';
import 'pages/transaction_history_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final name = auth.user?.name ?? 'Nama User';
    final username = '@${name.toLowerCase().replaceAll(' ', '.')}'.replaceAll(
      '..',
      '.',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                name: name,
                username: username,
                photoUrl: auth.user?.photoUrl,
              ),
              const SizedBox(height: 0),
              ProfileSection(
                title: 'Akun',
                items: [
                  ProfileMenuButton(
                    icon: Icons.person_outline,
                    label: 'Edit Profil',
                    onTap: () {
                      final user = auth.user;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data pengguna belum tersedia'),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: user),
                        ),
                      );
                    },
                  ),
                  ProfileMenuButton(
                    icon: Icons.lock_outline,
                    label: 'Ubah Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ProfileSection(
                title: 'Aktivitas',
                items: [
                  ProfileMenuButton(
                    icon: Icons.groups_outlined,
                    label: 'Komunitas Saya',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyCommunitiesPage(user: auth.user),
                        ),
                      );
                    },
                  ),
                  ProfileMenuButton(
                    icon: Icons.event_note_outlined,
                    label: 'Sparring Saya',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MySparringPage(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuButton(
                    icon: Icons.receipt_long,
                    label: 'Transaksi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ProfileSection(
                title: 'Lainnya',
                items: [
                  ProfileMenuButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
