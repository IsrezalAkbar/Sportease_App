import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/models/community_model.dart';
import '../../../data/models/field_model.dart';
import '../../../data/repositories/community_repo.dart';
import '../../../data/repositories/field_repo.dart';

class CommunityListPage extends StatefulWidget {
  const CommunityListPage({super.key});

  @override
  State<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  final _communityRepo = CommunityRepo();
  final _fieldRepo = FieldRepo();
  late final String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Bareng')),
      body: StreamBuilder<List<FieldModel>>(
        stream: _fieldRepo.allFields,
        builder: (context, fieldSnap) {
          if (fieldSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final fieldMap = {
            for (final f in fieldSnap.data ?? <FieldModel>[]) f.fieldId: f.name,
          };

          return StreamBuilder<List<CommunityModel>>(
            stream: _communityRepo.communities,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final communities = snap.data ?? [];
              if (communities.isEmpty) {
                return const Center(child: Text('Belum ada komunitas.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final c = communities[index];
                  final isMember =
                      _userId != null && c.memberList.contains(_userId);
                  final isFull = c.memberList.length >= 50;
                  final fieldName =
                      fieldMap[c.fieldId] ?? 'Lapangan tidak diketahui';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: c.photo.isNotEmpty
                                    ? NetworkImage(c.photo)
                                    : null,
                                child: c.photo.isEmpty
                                    ? const Icon(
                                        Icons.groups,
                                        color: Colors.black54,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fieldName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if (c.weeklyWeekday != null &&
                                        c.weeklyStart != null &&
                                        c.weeklyEnd != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        ([
                                              '',
                                              'Senin',
                                              'Selasa',
                                              'Rabu',
                                              'Kamis',
                                              'Jumat',
                                              'Sabtu',
                                              'Minggu',
                                            ][c.weeklyWeekday!] +
                                            ' ${c.weeklyStart} - ${c.weeklyEnd}'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      '${c.memberList.length}/50 anggota',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            c.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_userId == null || isMember || isFull)
                                  ? null
                                  : () async {
                                      try {
                                        await _communityRepo.join(
                                          _userId,
                                          c.communityId,
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Berhasil bergabung',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Gagal bergabung: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: Text(
                                isMember
                                    ? 'Sudah Bergabung'
                                    : isFull
                                    ? 'Penuh (50)'
                                    : 'Gabung Komunitas',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: communities.length,
              );
            },
          );
        },
      ),
    );
  }
}
