import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/xendit_service.dart';
import '../../../core/utils/booking_cleanup.dart';
import '../../../data/models/xendit_invoice_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/payment_method_model.dart';
import '../../../data/repositories/booking_repo.dart';
import '../../../data/repositories/sparring_repo.dart';
import '../../../router/app_router.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _xenditService = XenditService();
  final _bookingRepo = BookingRepo();
  bool _isProcessing = false;
  PaymentMethod? _selectedMethod;
  Timer? _pollTimer;
  String? _currentInvoiceId;
  DateTime? _expiresAt;
  bool _isPaid = false;
  final Duration _paymentWindow = const Duration(minutes: 10);
  final Duration _pollInterval = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    // Set default payment method to a bank VA
    _selectedMethod = PaymentMethods.bca;
    // Clear old payment states
    _currentInvoiceId = null;
    _expiresAt = null;
    _isPaid = false;
    // Clean up expired bookings
    BookingCleanup.expireOldPendingBookings();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _processPayment(
    BuildContext context,
    Map<String, dynamic>? args,
  ) async {
    if (args == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (_selectedMethod == null) {
        throw Exception('Pilih metode bank terlebih dahulu');
      }
      final slots = (args['slots'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final total = args['total'] as int? ?? 0;
      final fieldId = args['fieldId'] as String? ?? '';
      final fieldName = args['fieldName'] as String? ?? '';
      final now = DateTime.now();
      final holdExpiresAt = now.add(_paymentWindow);

      // Generate booking ID
      final bookingId = const Uuid().v4();

      // Buat items untuk invoice
      final items = slots.map((slot) {
        final date = DateTime.parse(slot['date'] as String);
        final time = slot['time'] as String;
        final price = slot['price'] as int? ?? 0;
        return XenditInvoiceItem(
          name: '$fieldName - ${_formatDate(date)} $time',
          quantity: 1,
          price: price,
        );
      }).toList();

      // Buat invoice Xendit (web-based)
      final invoice = await _xenditService.createInvoice(
        externalId: bookingId,
        amount: total,
        payerEmail: user.email ?? 'no-email@example.com',
        description: 'Pembayaran Booking Lapangan - $fieldName',
        items: items,
      );

      // Simpan booking ke Firestore dengan status pending
      for (final slot in slots) {
        final slotBooking = BookingModel(
          bookingId: '${bookingId}_${slot['time']}',
          userId: user.uid,
          fieldId: fieldId,
          dateKey: _dateKey(DateTime.parse(slot['date'] as String)),
          date: DateTime.parse(slot['date'] as String),
          time: slot['time'] as String,
          price: slot['price'] as int? ?? 0,
          paymentStatus: 'pending',
          createdAt: now,
          holdExpiresAt: holdExpiresAt,
          xenditInvoiceId: invoice.id,
          xenditInvoiceUrl: invoice.invoiceUrl,
        );
        await _bookingRepo.create(slotBooking);
      }

      // Simpan invoice ID dan mulai polling
      setState(() {
        _currentInvoiceId = invoice.id ?? bookingId;
        _expiresAt = holdExpiresAt;
      });

      _startPollingStatus(
        invoiceId: invoice.id ?? bookingId,
        userId: user.uid,
        methodLabel: _selectedMethod?.displayName ?? 'Unknown',
        expiresAt: holdExpiresAt,
      );

      // Redirect ke URL Xendit untuk pembayaran
      if (invoice.invoiceUrl != null) {
        if (!mounted) return;
        final Uri xenditUrl = Uri.parse(invoice.invoiceUrl!);
        await launchUrl(xenditUrl, mode: LaunchMode.externalApplication);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan selesaikan pembayaran di browser. Status akan diupdate otomatis.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Invoice URL tidak tersedia');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _startPollingStatus({
    required String invoiceId,
    required String userId,
    required String methodLabel,
    required DateTime expiresAt,
  }) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (t) async {
      final remaining = expiresAt.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        t.cancel();
        await _expireInvoice(invoiceId, userId);
        if (mounted) {
          setState(() {
            _currentInvoiceId = null;
            _expiresAt = null;
            _isPaid = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Waktu pembayaran (10 menit) habis. Slot dibuka kembali.',
              ),
            ),
          );
        }
        return;
      }
      if (mounted) setState(() {}); // refresh countdown text
      try {
        final invoice = await _xenditService.getInvoice(invoiceId);
        final status = invoice.status;
        if (status?.toUpperCase() == 'PAID' ||
            status?.toUpperCase() == 'SETTLED') {
          t.cancel();
          // Update all related bookings
          final bookings = await _bookingRepo.getBookingsByInvoice(
            userId: userId,
            invoiceId: invoiceId,
          );
          for (final b in bookings) {
            await _bookingRepo.updatePaymentSuccess(
              bookingId: b.bookingId,
              paymentMethod: methodLabel,
              paidAt: DateTime.now(),
            );
          }

          // Update sparring if exists
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final sparringId = args?['sparringId'] as String?;
          if (sparringId != null && bookings.isNotEmpty) {
            final firstBooking = bookings.first;
            await SparringRepo().updateSparringPayment(
              sparringId: sparringId,
              bookingId: firstBooking.bookingId,
              paymentStatus: 'paid',
              date: firstBooking.date,
              time: firstBooking.time,
            );
          }

          if (!mounted) return;
          setState(() {
            _isPaid = true;
          });
          // Navigate to receipt page
          Navigator.pushNamed(
            context,
            AppRouter.receipt,
            arguments: {"invoiceId": invoiceId},
          );
        }
      } catch (_) {
        // ignore errors during polling
      }
    });
  }

  Future<void> _checkStatusNow(String invoiceId, String? userId) async {
    if (userId == null) return;
    try {
      final invoice = await _xenditService.getInvoice(invoiceId);
      final status = invoice.status;
      if (status?.toUpperCase() == 'PAID' ||
          status?.toUpperCase() == 'SETTLED') {
        final bookings = await _bookingRepo.getBookingsByInvoice(
          userId: userId,
          invoiceId: invoiceId,
        );
        for (final b in bookings) {
          await _bookingRepo.updatePaymentSuccess(
            bookingId: b.bookingId,
            paymentMethod: _selectedMethod?.displayName ?? 'Unknown',
            paidAt: DateTime.now(),
          );
        }
        if (!mounted) return;
        setState(() => _isPaid = true);
        Navigator.pushNamed(
          context,
          AppRouter.receipt,
          arguments: {"invoiceId": invoiceId},
        );
        _pollTimer?.cancel();
      } else {
        final expired =
            _expiresAt != null && _expiresAt!.isBefore(DateTime.now());
        if (expired) {
          await _expireInvoice(invoiceId, userId);
          if (!mounted) return;
          setState(() {
            _currentInvoiceId = null;
            _expiresAt = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waktu pembayaran habis, slot dibuka kembali.'),
            ),
          );
          return;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status saat ini: ${status ?? "PENDING"}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal cek status: $e')));
    }
  }

  Future<void> _expireInvoice(String invoiceId, String userId) async {
    final bookings = await _bookingRepo.getBookingsByInvoice(
      userId: userId,
      invoiceId: invoiceId,
    );
    for (final b in bookings) {
      await _bookingRepo.updateStatus(b.bookingId, 'expired');
    }
  }

  Future<void> _cancelInvoice() async {
    if (_isPaid || _currentInvoiceId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat dibatalkan setelah dibayar.'),
          ),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _pollTimer?.cancel();
    await _expireOrCancel(
      invoiceId: _currentInvoiceId!,
      userId: user.uid,
      status: 'cancelled',
    );
    if (!mounted) return;
    setState(() {
      _currentInvoiceId = null;
      _expiresAt = null;
      _isPaid = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pemesanan dibatalkan. Slot telah dibuka.')),
    );
  }

  Future<void> _expireOrCancel({
    required String invoiceId,
    required String userId,
    required String status,
  }) async {
    final bookings = await _bookingRepo.getBookingsByInvoice(
      userId: userId,
      invoiceId: invoiceId,
    );
    for (final b in bookings) {
      await _bookingRepo.updateStatus(b.bookingId, status);
    }
  }

  String _formatCountdown() {
    if (_expiresAt == null) return '-';
    final remaining = _expiresAt!.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return '00:00';
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final total = args?['total'] as int? ?? 0;

    const primaryColor = Color(0xFF8D153A);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _StepIndicator(
                          step: 1,
                          isActive: true,
                          isCompleted: true,
                        ),
                        Expanded(
                          child: Container(height: 2, color: Colors.grey[300]),
                        ),
                        _StepIndicator(
                          step: 2,
                          isActive: true,
                          isCompleted: true,
                        ),
                        Expanded(
                          child: Container(height: 2, color: Colors.grey[300]),
                        ),
                        _StepIndicator(
                          step: 3,
                          isActive: true,
                          isCompleted: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Text('Pilih Jadwal', style: TextStyle(fontSize: 12)),
                        Spacer(),
                        Text('Review Order', style: TextStyle(fontSize: 12)),
                        Spacer(),
                        Text(
                          'Pembayaran',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Total Pembayaran
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${_formatRupiah(total)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Pay Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _processPayment(context, args),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Selesaikan Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Step Indicator Widget
class _StepIndicator extends StatelessWidget {
  final int step;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.step,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isActive
        ? const Color(0xFF8D153A)
        : Colors.grey[300];

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// Payment Method Section Widget
class _PaymentMethodSection extends StatelessWidget {
  final String title;
  final List<PaymentMethod> methods;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onSelected;

  const _PaymentMethodSection({
    required this.title,
    required this.methods,
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: methods.map((method) {
            final isSelected = selectedMethod?.id == method.id;
            return GestureDetector(
              onTap: () => onSelected(method),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8D153A)
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon or Logo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _getMethodIcon(method.id),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Method Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            method.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Radio Button
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8D153A)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8D153A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getMethodIcon(String methodId) {
    switch (methodId) {
      case 'gopay':
        return '🔵';
      case 'ovo':
        return '🟣';
      case 'dana':
        return '🔷';
      case 'link_aja':
        return '🔶';
      case 'shopee_pay':
        return '🟠';
      case 'bca':
        return '🏦';
      case 'bni':
        return '🏦';
      case 'mandiri':
        return '🏦';
      case 'bri':
        return '🏦';
      case 'permata':
        return '🏦';
      case 'alfamart':
        return '🏪';
      case 'indomaret':
        return '🏪';
      case 'qris':
        return '📱';
      case 'credit_card':
        return '💳';
      default:
        return '💰';
    }
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

String _formatDate(DateTime date) {
  const months = [
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
}
