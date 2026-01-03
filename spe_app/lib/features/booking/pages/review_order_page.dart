import 'package:flutter/material.dart';
import '../../../router/app_router.dart';
import '../../../data/repositories/field_community_rating_repo.dart';

class ReviewOrderPage extends StatefulWidget {
  const ReviewOrderPage({super.key});

  @override
  State<ReviewOrderPage> createState() => _ReviewOrderPageState();
}

class _ReviewOrderPageState extends State<ReviewOrderPage> {
  final List<String> _selectedServices = [];
  double _fieldRating = 0.0;
  bool _loadingRating = true;
  bool _hasLoadedRating = false;

  final List<Map<String, dynamic>> _additionalServices = [
    {
      'id': 'photographer',
      'name': 'Fotografer',
      'price': 150000,
      'description': 'Dokumentasi profesional',
    },
    {
      'id': 'referee',
      'name': 'Wasit',
      'price': 100000,
      'description': 'Wasit profesional',
    },
    {
      'id': 'equipment',
      'name': 'Peralatan Tambahan',
      'price': 50000,
      'description': 'Bola, cone, dll',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedRating) {
      _hasLoadedRating = true;
      _loadFieldRating();
    }
  }

  Future<void> _loadFieldRating() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fieldId = args?['fieldId'] as String? ?? '';

    if (fieldId.isEmpty) {
      setState(() => _loadingRating = false);
      return;
    }

    try {
      final repo = FieldCommunityAndRatingRepo();
      final rating = await repo.getAverageRating(fieldId);
      if (mounted) {
        setState(() {
          _fieldRating = rating;
          _loadingRating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingRating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final fieldName = args?['fieldName'] as String? ?? 'Lapangan';
    final fieldLocation = args?['fieldLocation'] as String? ?? '';
    final fieldImage = args?['fieldImage'] as String? ?? '';
    final slots = (args?['slots'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final totalPrice = args?['total'] as int? ?? 0;
    final fieldId = args?['fieldId'] as String? ?? '';

    // Use loaded rating or default fallback
    final displayRating = _loadingRating ? 0.0 : _fieldRating;

    const primaryColor = Color(0xFF8D153A);

    // Calculate additional services price
    int additionalServicesPrice = 0;
    for (final service in _selectedServices) {
      final serviceData = _additionalServices.firstWhere(
        (s) => s['id'] == service,
        orElse: () => {'price': 0},
      );
      additionalServicesPrice += serviceData['price'] as int? ?? 0;
    }

    int grandTotal = totalPrice + additionalServicesPrice;

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
                          primaryColor: primaryColor,
                        ),
                        Expanded(
                          child: Container(height: 2, color: primaryColor),
                        ),
                        _StepIndicator(
                          step: 2,
                          isActive: true,
                          isCompleted: false,
                          primaryColor: primaryColor,
                        ),
                        Expanded(
                          child: Container(height: 2, color: Colors.grey[300]),
                        ),
                        _StepIndicator(
                          step: 3,
                          isActive: false,
                          isCompleted: false,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Text('Pilih Jadwal', style: TextStyle(fontSize: 12)),
                        Spacer(),
                        Text(
                          'Review Order',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8D153A),
                          ),
                        ),
                        Spacer(),
                        Text('Pembayaran', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Field Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                      if (fieldImage.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            fieldImage,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Icon(Icons.sports_soccer),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fieldName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                if (_loadingRating)
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.amber[600],
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    displayRating == 0.0
                                        ? '-'
                                        : '$displayRating',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '• $fieldLocation',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Jadwal Booking Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jadwal Booking',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int i = 0; i < slots.length; i++) ...[
                        _BookingSlotItem(
                          slot: slots[i],
                          index: i + 1,
                          onEdit: () => Navigator.pop(context),
                          onRemove: () {
                            setState(() {
                              slots.removeAt(i);
                            });
                            // If no slots left, go back
                            if (slots.isEmpty) {
                              Navigator.pop(context);
                            } else {
                              // Recalculate total
                              final newTotal = slots.fold<int>(
                                0,
                                (sum, slot) =>
                                    sum + (slot['price'] as int? ?? 0),
                              );
                              // Update args
                              args?['slots'] = slots;
                              args?['total'] = newTotal;
                            }
                          },
                        ),
                        if (i < slots.length - 1) const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate back to booking page to add more slots
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Color(0xFF8D153A)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tambah Booking',
                                    style: TextStyle(
                                      color: Color(0xFF8D153A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Ringkasan Pembayaran Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Biaya Sewa',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Rp ${_formatRupiah(totalPrice)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Biaya Jasa Tambahan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            additionalServicesPrice == 0
                                ? 'Rp 0'
                                : 'Rp ${_formatRupiah(additionalServicesPrice)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Rp ${_formatRupiah(grandTotal)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8D153A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Jasa Tambahan Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jasa Tambahan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final service in _additionalServices)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _selectedServices.contains(
                                    service['id'],
                                  ),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedServices.add(service['id']);
                                      } else {
                                        _selectedServices.remove(service['id']);
                                      }
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  activeColor: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      service['description'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${_formatRupiah(service['price'])}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final arguments = {
                    'fieldId': fieldId,
                    'fieldName': fieldName,
                    'slots': slots,
                    'total': grandTotal,
                    'additionalServices': _selectedServices,
                  };

                  // Forward sparringId if exists
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>?;
                  if (args?['sparringId'] != null) {
                    arguments['sparringId'] = args!['sparringId'];
                  }

                  Navigator.pushNamed(
                    context,
                    AppRouter.payment,
                    arguments: arguments,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Bayar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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

class _BookingSlotItem extends StatelessWidget {
  final Map<String, dynamic> slot;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _BookingSlotItem({
    required this.slot,
    required this.index,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(slot['date'] as String);
    final time = slot['time'] as String;
    final price = slot['price'] as int;

    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final weekdays = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    final dateStr =
        '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp ${_formatRupiah(price)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

class _StepIndicator extends StatelessWidget {
  final int step;
  final bool isActive;
  final bool isCompleted;
  final Color primaryColor;

  const _StepIndicator({
    required this.step,
    required this.isActive,
    required this.isCompleted,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isActive ? primaryColor : Colors.grey[300],
        border: isActive ? Border.all(color: primaryColor, width: 2) : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                step.toString(),
                style: TextStyle(
                  color: isActive || isCompleted
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
