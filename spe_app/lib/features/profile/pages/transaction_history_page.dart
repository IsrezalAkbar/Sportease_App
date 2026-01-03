import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/booking_repo.dart';
import '../../../data/models/booking_model.dart';
import '../../../router/app_router.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: user == null
          ? const Center(child: Text('Silakan login untuk melihat transaksi'))
          : StreamBuilder<List<BookingModel>>(
              stream: BookingRepo().getForUser(user.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snap.data ?? [];
                if (bookings.isEmpty) {
                  return const Center(child: Text('Belum ada transaksi.'));
                }

                // Group by invoiceId
                final Map<String, List<BookingModel>> groups = {};
                for (final b in bookings) {
                  final key = b.xenditInvoiceId ?? b.bookingId;
                  groups.putIfAbsent(key, () => []).add(b);
                }

                final entries = groups.entries.toList()
                  ..sort(
                    (a, b) =>
                        (b.value.first.date).compareTo(a.value.first.date),
                  );

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    final invoiceId = e.key;
                    final list = e.value;
                    final status = list.any((b) => b.paymentStatus == 'paid')
                        ? 'paid'
                        : list.first.paymentStatus;
                    final total = list.fold<int>(0, (s, b) => s + b.price);
                    final firstBooking = list.first;
                    final dateStr = _formatDate(firstBooking.date);

                    Color badgeColor() => status == 'paid'
                        ? const Color(0xFF00C853)
                        : status == 'pending'
                        ? const Color(0xFFFF6D00)
                        : const Color(0xFF616161);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // If pending and not expired, go to waiting page
                          if (status == 'pending' &&
                              list.first.holdExpiresAt != null) {
                            final now = DateTime.now();
                            if (list.first.holdExpiresAt!.isAfter(now)) {
                              Navigator.pushNamed(
                                context,
                                AppRouter.paymentWaiting,
                                arguments: {
                                  'invoiceId': invoiceId,
                                  'userId': user.uid,
                                  'methodLabel': 'Bank Transfer',
                                  'expiresAt': list.first.holdExpiresAt,
                                  'availableBanks':
                                      null, // Will be fetched by polling
                                },
                              );
                              return;
                            }
                          }
                          // Otherwise go to receipt
                          Navigator.pushNamed(
                            context,
                            AppRouter.receipt,
                            arguments: {"invoiceId": invoiceId},
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Invoice ${invoiceId.substring(0, 8)}...',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeColor(),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: badgeColor().withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 24,
                                thickness: 1.5,
                                color: Colors.grey.shade200,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${list.length} item',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_rupiah(total)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Color(0xFF8D153A),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: entries.length,
                );
              },
            ),
    );
  }

  String _rupiah(int value) {
    final buffer = StringBuffer();
    final chars = value.toString().split('').reversed.toList();
    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write('.');
      buffer.write(chars[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
