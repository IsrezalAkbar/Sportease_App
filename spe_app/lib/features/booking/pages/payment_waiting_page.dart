import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/xendit_service.dart';
import '../../../data/repositories/booking_repo.dart';
import '../../../data/models/xendit_invoice_model.dart';
import '../../../router/app_router.dart';

class PaymentWaitingPage extends StatefulWidget {
  const PaymentWaitingPage({super.key});

  @override
  State<PaymentWaitingPage> createState() => _PaymentWaitingPageState();
}

class _PaymentWaitingPageState extends State<PaymentWaitingPage> {
  final _xenditService = XenditService();
  final _bookingRepo = BookingRepo();
  Timer? _pollTimer;
  bool _isPaid = false;
  bool _pollingActive = false;
  final Duration _pollInterval = const Duration(seconds: 10);

  String? _invoiceId;
  String? _userId;
  String? _methodLabel;
  DateTime? _expiresAt;
  List<dynamic>? _availableBanks;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('Argumen tidak ditemukan')),
      );
    }

    if (!_initialized) {
      _invoiceId = args['invoiceId'] as String?;
      _userId = args['userId'] as String?;
      _methodLabel = args['methodLabel'] as String? ?? 'Bank Transfer';
      _expiresAt = args['expiresAt'] as DateTime?;
      _availableBanks = args['availableBanks'] as List<dynamic>?;
      _initialized = true;
      // Start polling once when initialized
      _startPollingIfNeeded();
    }

    if (_invoiceId == null || _userId == null) {
      return const Scaffold(
        body: Center(child: Text('Data pembayaran tidak lengkap')),
      );
    }

    const primaryColor = Color(0xFF8D153A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menunggu Pembayaran'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfer ke Virtual Account',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (_availableBanks != null && _availableBanks!.isNotEmpty)
                    ..._availableBanks!.map((bank) {
                      final bankCode = bank['bank_code'] as String? ?? '-';
                      final accountNumber = bank['account_number'] as String?;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Bank: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(bankCode),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'Nomor VA: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Expanded(
                                  child: Text(
                                    accountNumber ?? '-',
                                    style: const TextStyle(letterSpacing: 0.5),
                                  ),
                                ),
                                if (accountNumber != null)
                                  IconButton(
                                    tooltip: 'Copy VA',
                                    icon: const Icon(Icons.copy, size: 20),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: accountNumber),
                                      );
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('VA $bankCode disalin'),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    const Text(
                      'Nomor VA sedang disiapkan...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Sisa waktu: ${_formatCountdown()}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _checkStatusNow(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('Saya sudah bayar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isPaid ? null : _cancelInvoice,
                    child: const Text('Batalkan Pemesanan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startPollingIfNeeded() {
    if (_pollTimer != null || _invoiceId == null || _userId == null) return;
    _pollingActive = true;
    _pollTimer = Timer.periodic(_pollInterval, (t) async {
      final expired =
          _expiresAt != null && _expiresAt!.isBefore(DateTime.now());
      if (expired) {
        t.cancel();
        await _expireInvoice();
        if (!mounted) return;
        _pollingActive = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu pembayaran habis. Slot dibuka kembali.'),
          ),
        );
        Navigator.pop(context);
        return;
      }
      try {
        final invoice = await _xenditService.getInvoice(_invoiceId!);
        final status = invoice.status;
        if (status?.toUpperCase() == 'PAID' ||
            status?.toUpperCase() == 'SETTLED') {
          t.cancel();
          await _markPaid();
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            AppRouter.receipt,
            arguments: {"invoiceId": _invoiceId},
          );
        }
      } catch (_) {}
      if (mounted) setState(() {}); // refresh countdown
    });
  }

  Future<void> _checkStatusNow() async {
    if (_invoiceId == null || _userId == null) return;
    try {
      final invoice = await _xenditService.getInvoice(_invoiceId!);
      final status = invoice.status;
      if (status?.toUpperCase() == 'PAID' ||
          status?.toUpperCase() == 'SETTLED') {
        await _markPaid();
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          AppRouter.receipt,
          arguments: {"invoiceId": _invoiceId},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status saat ini: ${status ?? "PENDING"}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal cek status: $e')));
    }
  }

  Future<void> _markPaid() async {
    if (_invoiceId == null || _userId == null) return;
    final bookings = await _bookingRepo.getBookingsByInvoice(
      userId: _userId!,
      invoiceId: _invoiceId!,
    );
    for (final b in bookings) {
      await _bookingRepo.updatePaymentSuccess(
        bookingId: b.bookingId,
        paymentMethod: _methodLabel ?? 'Bank Transfer',
        paidAt: DateTime.now(),
      );
    }
    _isPaid = true;
    _pollTimer?.cancel();
  }

  Future<void> _expireInvoice() async {
    if (_invoiceId == null || _userId == null) return;
    final bookings = await _bookingRepo.getBookingsByInvoice(
      userId: _userId!,
      invoiceId: _invoiceId!,
    );
    for (final b in bookings) {
      await _bookingRepo.updateStatus(b.bookingId, 'expired');
    }
  }

  Future<void> _cancelInvoice() async {
    if (_isPaid) return;
    if (_invoiceId == null || _userId == null) return;
    _pollTimer?.cancel();
    final bookings = await _bookingRepo.getBookingsByInvoice(
      userId: _userId!,
      invoiceId: _invoiceId!,
    );
    for (final b in bookings) {
      await _bookingRepo.updateStatus(b.bookingId, 'cancelled');
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pemesanan dibatalkan. Slot dibuka.')),
    );
    Navigator.pop(context);
  }

  String _formatCountdown() {
    if (_expiresAt == null) return '-';
    final remaining = _expiresAt!.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return '00:00';
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _updateAvailableBanks(dynamic invoice) {
    try {
      if (invoice is XenditInvoiceModel) {
        final banks = invoice.availableBanks;
        if (banks != null && banks.isNotEmpty && mounted) {
          setState(() {
            _availableBanks = banks.map((b) => b.toJson()).toList();
          });
        }
      }
    } catch (_) {}
  }
}
