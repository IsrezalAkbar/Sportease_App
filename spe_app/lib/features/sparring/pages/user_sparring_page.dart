import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/field_repo.dart';
import '../../../data/repositories/sparring_repo.dart';
import '../../../data/models/sparring_model.dart';
import '../../../router/app_router.dart';

class UserSparringPage extends StatefulWidget {
  const UserSparringPage({super.key});

  @override
  State<UserSparringPage> createState() => _UserSparringPageState();
}

class _UserSparringPageState extends State<UserSparringPage> {
  final _teamNameCtrl = TextEditingController();
  String? _selectedFieldId;
  bool _isLoading = false;

  @override
  void dispose() {
    _teamNameCtrl.dispose();
    super.dispose();
  }

  void _proceedToBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User tidak ditemukan')));
      return;
    }

    final teamName = _teamNameCtrl.text.trim();
    if (teamName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan nama tim')));
      return;
    }

    if (_selectedFieldId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih lapangan')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get field details
      final fieldsSnapshot = await FieldRepo().fields.first;
      final field = fieldsSnapshot.firstWhere(
        (f) => f.fieldId == _selectedFieldId,
      );

      // Create sparring first with temporary date/time (will be set in booking page)
      final sparringId = const Uuid().v4();
      final sparring = SparringModel(
        sparringId: sparringId,
        fieldId: _selectedFieldId!,
        ownerId: user.uid,
        date: DateTime.now(),
        time: '00:00',
        maxPlayer: 12,
        participantList: [user.uid],
        ownerTeamName: teamName,
      );

      await SparringRepo().create(sparring);

      // Redirect to booking page with sparring info
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRouter.booking,
          arguments: {
            'id': _selectedFieldId,
            'name': field.name,
            'address': field.locationName,
            'pricePerHour': field.pricePerHour,
            'image': field.photos.isNotEmpty ? field.photos.first : '',
            'sparringId': sparringId,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buat Sparring')),
        body: const Center(child: Text('User tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Sparring')),
      body: StreamBuilder(
        stream: FieldRepo().fields,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final fields = snapshot.data ?? [];
          if (fields.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Tidak ada lapangan tersedia'),
                  const SizedBox(height: 8),
                  Text(
                    'Coba lagi nanti',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nama Tim',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _teamNameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama tim Anda',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih Lapangan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedFieldId,
                  decoration: const InputDecoration(
                    hintText: 'Pilih lapangan',
                    border: OutlineInputBorder(),
                  ),
                  items: fields
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.fieldId,
                          child: Text(f.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedFieldId = val),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      (_teamNameCtrl.text.trim().isNotEmpty &&
                          _selectedFieldId != null &&
                          !_isLoading)
                      ? _proceedToBooking
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lanjut'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
