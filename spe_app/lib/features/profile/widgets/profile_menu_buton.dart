import 'package:flutter/material.dart';

class ProfileMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProfileMenuButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
