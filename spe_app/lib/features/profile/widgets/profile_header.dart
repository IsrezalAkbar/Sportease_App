import 'package:flutter/material.dart';
import '../../../core/config/colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? username;
  final String? photoUrl;
  final VoidCallback? onChangeAccount;

  const ProfileHeader({
    super.key,
    required this.name,
    this.username,
    this.photoUrl,
    this.onChangeAccount,
  });

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatarInitials = _initials(name);

    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(height: 170, color: AppColors.primary),
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Container(
                margin: const EdgeInsets.only(top: 60),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.orange,
                      backgroundImage:
                          (photoUrl != null && photoUrl!.isNotEmpty)
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: (photoUrl == null || photoUrl!.isEmpty)
                          ? Text(
                              avatarInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      username ?? '',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (onChangeAccount != null)
                      TextButton(
                        onPressed: onChangeAccount,
                        child: const Text(
                          'Ganti Akun',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
