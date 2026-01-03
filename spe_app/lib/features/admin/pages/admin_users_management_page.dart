import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_repo.dart';
import '../../../data/models/user_model.dart';

class AdminUsersManagementPage extends ConsumerStatefulWidget {
  const AdminUsersManagementPage({super.key});

  @override
  ConsumerState<AdminUsersManagementPage> createState() =>
      _AdminUsersManagementPageState();
}

class _AdminUsersManagementPageState
    extends ConsumerState<AdminUsersManagementPage> {
  String selectedFilter = 'all'; // all, user, pengelola

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen User')),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: selectedFilter == 'all',
                  onSelected: (selected) {
                    setState(() => selectedFilter = 'all');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('User'),
                  selected: selectedFilter == 'user',
                  onSelected: (selected) {
                    setState(() => selectedFilter = 'user');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pengelola'),
                  selected: selectedFilter == 'pengelola',
                  onSelected: (selected) {
                    setState(() => selectedFilter = 'pengelola');
                  },
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: UserRepo().allUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var users = (snapshot.data ?? [])
                    .where((u) => u.role != 'admin')
                    .toList();

                // Apply filter
                if (selectedFilter == 'user') {
                  users = users.where((u) => u.role == 'user').toList();
                } else if (selectedFilter == 'pengelola') {
                  users = users.where((u) => u.role == 'pengelola').toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada user',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.role == 'pengelola'
              ? Colors.blue
              : Colors.green,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Icon(
                  user.role == 'pengelola' ? Icons.business : Icons.person,
                  color: Colors.white,
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('📧 ${user.email}'),
            Text('👤 @${user.username}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.role == 'pengelola'
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role == 'pengelola' ? 'Pengelola' : 'User',
                style: TextStyle(
                  color: user.role == 'pengelola' ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Detail'),
                ],
              ),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  _showUserDetail(user);
                });
              },
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  _confirmDeleteUser(user);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetail(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('UID', user.uid),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Username', user.username),
            _buildDetailRow('Role', user.role),
            _buildDetailRow(
              'Komunitas',
              user.joinedCommunities.isEmpty
                  ? 'Belum ada'
                  : '${user.joinedCommunities.length} komunitas',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text(
          'Yakin ingin menghapus ${user.name}?\n\n'
          'User akan dihapus dari:\n'
          '• Firebase Authentication\n'
          '• Database Firestore\n\n'
          'Tindakan ini tidak dapat dibatalkan!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserRepo().delete(user.uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'User berhasil dihapus dari database.\n'
                        'User tidak akan bisa akses aplikasi lagi.',
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error menghapus user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
