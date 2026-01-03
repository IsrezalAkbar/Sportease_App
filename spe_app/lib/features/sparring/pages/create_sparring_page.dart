import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/sparring_repo.dart';
import '../../../data/repositories/field_repo.dart';
import '../../../data/models/sparring_model.dart';
import '../../../data/models/field_model.dart';
import '../../auth/auth_controller.dart';
import 'package:uuid/uuid.dart';

class CreateSparringPage extends ConsumerStatefulWidget {
  const CreateSparringPage({super.key});

  @override
  ConsumerState<CreateSparringPage> createState() => _CreateSparringPageState();
}

class _CreateSparringPageState extends ConsumerState<CreateSparringPage> {
  final maxPlayerCtrl = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedFieldId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Sparring')),
      body: userId == null
          ? const Center(child: Text('User tidak ditemukan'))
          : StreamBuilder<List<FieldModel>>(
              stream: FieldRepo().getByOwner(userId),
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
                        const Icon(
                          Icons.info_outline,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('Anda belum memiliki lapangan'),
                        const SizedBox(height: 8),
                        Text(
                          'Tambahkan lapangan terlebih dahulu',
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
                        'Pilih Lapangan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedFieldId,
                        decoration: const InputDecoration(
                          hintText: 'Pilih lapangan Anda',
                          border: OutlineInputBorder(),
                        ),
                        items: fields.map((field) {
                          return DropdownMenuItem(
                            value: field.fieldId,
                            child: Text(field.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedFieldId = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        tileColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          selectedDate == null
                              ? 'Pilih tanggal'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Waktu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        tileColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          selectedTime == null
                              ? 'Pilih waktu'
                              : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => selectedTime = time);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Maksimal Pemain',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: maxPlayerCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 10',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _submitSparring(context, userId),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Buat Sparring'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _submitSparring(BuildContext context, String userId) async {
    if (selectedFieldId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lapangan terlebih dahulu')),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal terlebih dahulu')),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih waktu terlebih dahulu')),
      );
      return;
    }

    final maxPlayer = int.tryParse(maxPlayerCtrl.text);
    if (maxPlayer == null || maxPlayer <= 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah pemain yang valid')),
      );
      return;
    }

    final id = const Uuid().v4();
    final timeString =
        '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

    final model = SparringModel(
      sparringId: id,
      fieldId: selectedFieldId!,
      ownerId: userId,
      date: selectedDate!,
      time: timeString,
      maxPlayer: maxPlayer,
      participantList: [],
    );

    await SparringRepo().create(model);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sparring berhasil dibuat!')));
    Navigator.pop(context);
  }
}
