import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/shared/image_picker_helper.dart';
import '../../../features/media/cloudinary_controller.dart';
import '../../../data/repositories/community_repo.dart';
import '../../../data/models/community_model.dart';
import '../../../data/repositories/field_repo.dart';
import '../../../data/models/field_model.dart';
import '../../auth/auth_controller.dart';
import 'package:uuid/uuid.dart';

class CreateCommunityPage extends ConsumerStatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityPageState();
}

class _CreateCommunityPageState extends ConsumerState<CreateCommunityPage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? photo;
  String? selectedFieldId;
  int? selectedWeekday; // 1..7 (Mon..Sun)
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    final cloudState = ref.watch(cloudinaryProvider);
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.uid;

    // Jika user belum login
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Daftarkan Komunitas")),
        body: const Center(child: Text('User tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Daftarkan Komunitas")),
      body: StreamBuilder<List<FieldModel>>(
        stream: FieldRepo().getByOwner(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final fields = snapshot.data ?? [];
          final hasField = fields.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasField) ...[
                  const Text(
                    'Anda belum memiliki lapangan.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buat atau ajukan lapangan terlebih dahulu sebelum membuat komunitas.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ] else ...[
                  const Text(
                    'Pilih Lapangan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedFieldId,
                    items: fields
                        .map(
                          (f) => DropdownMenuItem(
                            value: f.fieldId,
                            child: Text(f.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedFieldId = val),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Pilih lapangan',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jadwal Mingguan Komunitas',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedWeekday,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Hari',
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Senin')),
                            DropdownMenuItem(value: 2, child: Text('Selasa')),
                            DropdownMenuItem(value: 3, child: Text('Rabu')),
                            DropdownMenuItem(value: 4, child: Text('Kamis')),
                            DropdownMenuItem(value: 5, child: Text('Jumat')),
                            DropdownMenuItem(value: 6, child: Text('Sabtu')),
                            DropdownMenuItem(value: 7, child: Text('Minggu')),
                          ],
                          onChanged: (v) => setState(() => selectedWeekday = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime:
                                  startTime ??
                                  const TimeOfDay(hour: 17, minute: 0),
                            );
                            if (picked != null)
                              setState(() => startTime = picked);
                          },
                          child: Text(
                            startTime == null
                                ? 'Mulai'
                                : '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime:
                                  endTime ??
                                  const TimeOfDay(hour: 18, minute: 0),
                            );
                            if (picked != null)
                              setState(() => endTime = picked);
                          },
                          child: Text(
                            endTime == null
                                ? 'Selesai'
                                : '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      hintText: "Nama Komunitas",
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(hintText: "Deskripsi"),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final file = await ImagePickerHelper.pickImage();
                      if (file == null) return;

                      final url = await ref
                          .read(cloudinaryProvider.notifier)
                          .upload(file);
                      if (url != null) setState(() => photo = url);
                    },
                    child: const Text("Upload Foto Komunitas"),
                  ),

                  if (cloudState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),

                  if (photo != null) Image.network(photo!, height: 120),

                  const Spacer(),

                  ElevatedButton(
                    onPressed:
                        (!hasField ||
                            selectedFieldId == null ||
                            selectedWeekday == null ||
                            startTime == null ||
                            endTime == null)
                        ? null
                        : () async {
                            if (photo == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Foto belum di-upload"),
                                ),
                              );
                              return;
                            }

                            final startMinutes =
                                startTime!.hour * 60 + startTime!.minute;
                            final endMinutes =
                                endTime!.hour * 60 + endTime!.minute;
                            if (endMinutes <= startMinutes) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Waktu selesai harus setelah waktu mulai',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (startTime!.minute != 0 ||
                                endTime!.minute != 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Gunakan jam penuh (contoh 17:00 - 18:00)',
                                  ),
                                ),
                              );
                              return;
                            }

                            final id = const Uuid().v4();
                            final model = CommunityModel(
                              communityId: id,
                              fieldId: selectedFieldId!,
                              createdBy: userId,
                              name: nameCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              photo: photo!,
                              memberList: [],
                              isApproved: true,
                              weeklyWeekday: selectedWeekday,
                              weeklyStart:
                                  '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                              weeklyEnd:
                                  '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                            );

                            await CommunityRepo().create(model);

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Komunitas berhasil ditambahkan!",
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          },
                    child: const Text("Simpan"),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
