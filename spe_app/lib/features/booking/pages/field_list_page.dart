import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/field_model.dart';
import '../../../data/repositories/field_repo.dart';
import '../../../router/app_router.dart';

class FieldListPage extends ConsumerWidget {
  const FieldListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primary = Color(0xFF8D153A);
    final repo = FieldRepo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lapangan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<FieldModel>>(
        stream: repo.fields,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat lapangan: ${snap.error}'));
          }
          final fields = snap.data ?? [];
          if (fields.isEmpty) {
            return const Center(child: Text('Belum ada lapangan tersedia'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final field = fields[index];
              final photo = (field.photos.isNotEmpty)
                  ? field.photos.first
                  : 'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=800';

              return GestureDetector(
                onTap: () {
                  print('DEBUG: Tapping field: ${field.name}');
                  Navigator.pushNamed(
                    context,
                    AppRouter.fieldDetail,
                    arguments: {'field': field},
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                        child: Image.network(
                          photo,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    field.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    field.locationName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp${_formatRupiah(field.pricePerHour)}/jam',
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: fields.length,
          );
        },
      ),
    );
  }
}

String _formatRupiah(int value) {
  final buffer = StringBuffer();
  final chars = value.toString().split('').reversed.toList();
  for (int i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) buffer.write('.');
    buffer.write(chars[i]);
  }
  return buffer.toString().split('').reversed.join();
}
