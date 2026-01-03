import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/field_model.dart';
import '../../../router/app_router.dart';

class FieldDetailPage extends ConsumerWidget {
  const FieldDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print('DEBUG: FieldDetailPage args = $args');
    final field = args?['field'] as FieldModel?;
    print('DEBUG: FieldDetailPage field = $field');
    if (field == null) {
      return const Scaffold(
        body: Center(child: Text('Data lapangan tidak ditemukan')),
      );
    }

    const primary = Color(0xFF8D153A);
    final photos = field.photos.isNotEmpty
        ? field.photos
        : const [
            'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=1200',
          ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(child: _HeaderCarousel(photos: photos)),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            field.locationName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                tabs: const [
                  Tab(text: 'Booking'),
                  Tab(text: 'Komunitas'),
                ],
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black45,
                indicatorColor: primary,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _BookingTab(field: field, primary: primary),
                    const _CommunityTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomAction(
          price: field.pricePerHour,
          primary: primary,
          onPickSchedule: () {
            Navigator.pushNamed(
              context,
              AppRouter.booking,
              arguments: {
                'id': field.fieldId,
                'name': field.name,
                'address': field.locationName,
                'pricePerHour': field.pricePerHour,
                'image': photos.first,
              },
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCarousel extends StatefulWidget {
  const _HeaderCarousel({required this.photos});
  final List<String> photos;

  @override
  State<_HeaderCarousel> createState() => _HeaderCarouselState();
}

class _HeaderCarouselState extends State<_HeaderCarousel> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: widget.photos.length,
          onPageChanged: (i) => setState(() => index = i),
          itemBuilder: (_, i) {
            return Image.network(
              widget.photos[i],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 40),
              ),
            );
          },
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${index + 1}/${widget.photos.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingTab extends StatelessWidget {
  const _BookingTab({required this.field, required this.primary});
  final FieldModel field;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final facilities = field.facilityList.isEmpty
        ? const [
            'Cafe dan Resto',
            'Parkir Mobil',
            'Ruang Ganti',
            'Toilet',
            'Musholla',
            'Tribun Penonton',
          ]
        : field.facilityList;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            field.description.isEmpty
                ? 'Lapangan tersedia untuk berbagai jenis olahraga. Hubungi pengelola untuk info lebih lanjut.'
                : field.description,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fasilitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: facilities
                .map(
                  (f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        f,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ulasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text('4.8/5.0', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(width: 8),
              Icon(Icons.star, color: Colors.amber, size: 18),
              Icon(Icons.star, color: Colors.amber, size: 18),
              Icon(Icons.star, color: Colors.amber, size: 18),
              Icon(Icons.star, color: Colors.amber, size: 18),
              Icon(Icons.star_half, color: Colors.amber, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressRow(label: 'Kebersihan', value: 0.92, color: primary),
          const SizedBox(height: 8),
          _ProgressRow(label: 'Kondisi Lapangan', value: 0.88, color: primary),
          const SizedBox(height: 8),
          _ProgressRow(label: 'Komunikasi', value: 0.91, color: primary),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    final communities = [
      {'name': 'Prayoga Futsal Squad', 'members': 32},
      {'name': 'Sunday Soccer Club', 'members': 21},
      {'name': 'Amateur League', 'members': 18},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: communities.length,
      itemBuilder: (_, i) {
        final c = communities[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.groups, color: Colors.black54),
          ),
          title: Text(c['name'] as String),
          subtitle: Text('${c['members']} anggota'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.price,
    required this.primary,
    required this.onPickSchedule,
  });

  final int price;
  final Color primary;
  final VoidCallback onPickSchedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mulai Dari', style: TextStyle(fontSize: 12)),
              Text(
                'Rp${_formatRupiah(price)}',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: onPickSchedule,
            child: const Text('Pilih Jadwal'),
          ),
        ],
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
