import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sparring/pages/create_sparring_page.dart';
import '../../auth/auth_controller.dart';
import '../../../data/repositories/sparring_repo.dart';
import '../../../data/repositories/field_repo.dart';
import '../../../data/models/sparring_model.dart';
import '../../../data/models/field_model.dart';

class ManagerSparringPage extends ConsumerWidget {
  const ManagerSparringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sparring Saya')),
        body: const Center(child: Text('User tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sparring Saya')),
      body: StreamBuilder<List<SparringModel>>(
        stream: SparringRepo().getByOwner(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sparringList = snapshot.data ?? [];

          if (sparringList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_note_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada sparring',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat sparring untuk komunitas Anda',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sparringList.length,
            itemBuilder: (context, index) {
              final sparring = sparringList[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.sports_soccer,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StreamBuilder<List<FieldModel>>(
                              stream: FieldRepo().fields,
                              builder: (context, fieldSnapshot) {
                                FieldModel? field;
                                try {
                                  field = fieldSnapshot.data?.firstWhere(
                                    (f) => f.fieldId == sparring.fieldId,
                                  );
                                } catch (e) {
                                  // Field not found
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      field?.name ?? 'Lapangan',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      field?.locationName ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${sparring.date.day}/${sparring.date.month}/${sparring.date.year}',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sparring.time,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            '${sparring.participantList.length}/${sparring.maxPlayer} pemain',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value:
                            sparring.participantList.length /
                            sparring.maxPlayer,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          sparring.participantList.length >= sparring.maxPlayer
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSparringPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Sparring'),
      ),
    );
  }
}
