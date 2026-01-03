import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/field_repo.dart';
import '../../../data/repositories/active_booking_repo.dart';
import '../../../data/repositories/field_community_rating_repo.dart';

class ManagerFieldBookingPage extends StatefulWidget {
  const ManagerFieldBookingPage({super.key});

  @override
  State<ManagerFieldBookingPage> createState() =>
      _ManagerFieldBookingPageState();
}

class _ManagerFieldBookingPageState extends State<ManagerFieldBookingPage> {
  String? _selectedFieldId;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Jadwal Lapangan')),
        body: const Center(child: Text('User tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Lapangan')),
      body: StreamBuilder(
        stream: FieldRepo().getByOwner(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final fields = snapshot.data ?? [];
          if (fields.isEmpty) {
            return const Center(child: Text('Anda belum memiliki lapangan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pilih Lapangan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedFieldId,
                  items: fields
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.fieldId,
                          child: Text(f.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedFieldId = val;
                      _selectedDate = DateTime.now();
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Pilih lapangan',
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedFieldId != null) ...[
                  const Text(
                    'Pilih Tanggal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        locale: const Locale('id', 'ID'),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate == null
                          ? 'Pilih Tanggal'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleView(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleView() {
    if (_selectedFieldId == null || _selectedDate == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder(
      stream: ActiveBookingRepo().activeForFieldOnDateStream(
        fieldId: _selectedFieldId!,
        date: _selectedDate!,
      ),
      builder: (context, bookingSnapshot) {
        return StreamBuilder(
          stream: FieldCommunityAndRatingRepo().communitiesForField(
            _selectedFieldId!,
          ),
          builder: (context, communitySnapshot) {
            final active = bookingSnapshot.data ?? const [];
            final communities = communitySnapshot.data ?? const [];

            final timeSlots = <String>[
              '06:00 - 07:00',
              '07:00 - 08:00',
              '08:00 - 09:00',
              '09:00 - 10:00',
              '10:00 - 11:00',
              '11:00 - 12:00',
              '12:00 - 13:00',
              '13:00 - 14:00',
              '14:00 - 15:00',
              '15:00 - 16:00',
              '16:00 - 17:00',
              '17:00 - 18:00',
              '18:00 - 19:00',
              '19:00 - 20:00',
              '20:00 - 21:00',
              '21:00 - 22:00',
              '22:00 - 23:00',
              '23:00 - 00:00',
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jadwal Pemesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: timeSlots.map((slot) {
                    final parts = slot.split(' - ');
                    final startHour = int.parse(parts[0].split(':')[0]);
                    final start = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      startHour,
                    );
                    final end = start.add(const Duration(hours: 1));

                    // Check if booking exists
                    bool isBooked = false;
                    for (final b in active) {
                      if (start.isBefore(b.endAt) && end.isAfter(b.startAt)) {
                        isBooked = true;
                        break;
                      }
                    }

                    // Check if community schedule exists on this day/time
                    if (!isBooked) {
                      final weekday = _selectedDate!.weekday;
                      for (final community in communities) {
                        if (community.weeklyWeekday != null &&
                            community.weeklyStart != null &&
                            community.weeklyEnd != null) {
                          if (community.weeklyWeekday == weekday) {
                            final startParts = community.weeklyStart!.split(
                              ':',
                            );
                            final endParts = community.weeklyEnd!.split(':');
                            final communityStart = int.parse(startParts[0]);
                            final communityEnd = int.parse(endParts[0]);

                            if (startHour >= communityStart &&
                                startHour < communityEnd) {
                              isBooked = true;
                              break;
                            }
                          }
                        }
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: isBooked ? Colors.red[100] : Colors.green[100],
                        border: Border.all(
                          color: isBooked ? Colors.red : Colors.green,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isBooked
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBooked ? 'Pesan' : 'Kosong',
                            style: TextStyle(
                              fontSize: 11,
                              color: isBooked
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
