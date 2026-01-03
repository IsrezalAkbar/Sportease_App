import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/xendit_service.dart';
import '../../../data/models/xendit_invoice_model.dart';
import '../../../core/config/colors.dart';
import '../../profile/pages/transaction_history_page.dart';
import '../../main/main_tab_page.dart';
import '../../main/main_tab_controller.dart';

class ReceiptPage extends ConsumerStatefulWidget {
  const ReceiptPage({super.key});

  @override
  ConsumerState<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends ConsumerState<ReceiptPage> {
  final _xendit = XenditService();
  Future<XenditInvoiceModel>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final invoiceId = args?['invoiceId'] as String?;
    if (invoiceId != null && _future == null) {
      _future = _xendit.getInvoice(invoiceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF8D153A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice/Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to MainTabPage (Profile tab)
            ref.read(mainTabIndexProvider.notifier).state = 2;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainTabPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: FutureBuilder<XenditInvoiceModel>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final inv = snap.data;
          if (inv == null) {
            return const Center(child: Text('Invoice tidak ditemukan'));
          }

          Color statusColor(String s) {
            switch (s.toUpperCase()) {
              case 'PAID':
              case 'SETTLED':
                return Colors.green;
              case 'EXPIRED':
              case 'FAILED':
                return Colors.red;
              case 'PENDING':
                return Colors.orange;
              default:
                return Colors.grey;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(inv.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              inv.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor(inv.status),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Invoice ID'),
                          Text(inv.id ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Merchant'),
                          Text(inv.merchantName ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Email'),
                          Text(inv.payerEmail ?? '-'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...[
                        for (final item in inv.items ?? <XenditInvoiceItem>[])
                          _ItemRow(item: item),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Rp ${_formatRupiah(inv.amount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (inv.invoiceUrl != null)
                  SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(inv.invoiceUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Lihat di Xendit'),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to MainTabPage (Profile tab)
                            ref.read(mainTabIndexProvider.notifier).state = 2;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainTabPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text('Kembali'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Go to transaction history
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransactionHistoryPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text('Riwayat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile tab
        onTap: (index) {
          // Set the tab index and navigate to MainTabPage
          ref.read(mainTabIndexProvider.notifier).state = index;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainTabPage()),
            (route) => false,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 12,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore_outlined),
            activeIcon: Icon(Icons.travel_explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
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
}

class _ItemRow extends StatelessWidget {
  final XenditInvoiceItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('x${item.quantity}'),
          const SizedBox(width: 8),
          Text(
            'Rp ${_formatRupiah(item.price)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
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
}
