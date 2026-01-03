import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/field_model.dart';
import '../../../data/repositories/field_community_rating_repo.dart';
import '../../../router/app_router.dart';

class FieldDetailPageSimple extends StatefulWidget {
  const FieldDetailPageSimple({super.key});

  @override
  State<FieldDetailPageSimple> createState() => _FieldDetailPageSimpleState();
}

class _FieldDetailPageSimpleState extends State<FieldDetailPageSimple>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final field = args?['field'] as FieldModel?;

    if (field == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Data lapangan tidak ditemukan')),
      );
    }

    const primary = Color(0xFF8D153A);
    final photos = field.photos.isNotEmpty
        ? field.photos
        : const [
            'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=800',
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CarouselPhoto(photos: photos),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    field.locationName,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
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
              controller: _tabController,
              children: [
                _BookingTab(field: field, primary: primary),
                _CommunityTab(fieldId: field.fieldId),
              ],
            ),
          ),
        ],
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
    );
  }
}

class _CarouselPhoto extends StatefulWidget {
  const _CarouselPhoto({required this.photos});
  final List<String> photos;

  @override
  State<_CarouselPhoto> createState() => _CarouselPhotoState();
}

class _CarouselPhotoState extends State<_CarouselPhoto> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: PageView.builder(
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.photos[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[200]),
              );
            },
          ),
        ),
        Positioned(
          bottom: 8,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentIndex + 1}/${widget.photos.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
        ? const ['Cafe dan Resto', 'Parkir Mobil', 'Ruang Ganti', 'Toilet']
        : field.facilityList;

    final repo = FieldCommunityAndRatingRepo();

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
                ? 'Lapangan tersedia untuk berbagai jenis olahraga.'
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
            spacing: 12,
            runSpacing: 8,
            children: facilities.map((f) => Chip(label: Text(f))).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ulasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          StreamBuilder(
            stream: repo.ratingsForField(field.fieldId),
            builder: (context, snapshot) {
              final ratings = snapshot.data ?? [];
              final avg = ratings.isEmpty
                  ? 0.0
                  : ratings.fold<double>(0, (sum, r) => sum + r.rating) /
                        ratings.length;
              final fullStars = avg.floor();
              final hasHalfStar = (avg - fullStars) >= 0.5;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${avg.toStringAsFixed(1)}/5.0',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(5, (i) {
                          if (i < fullStars) {
                            return const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            );
                          } else if (i == fullStars && hasHalfStar) {
                            return const Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 18,
                            );
                          }
                          return const Icon(
                            Icons.star_outline,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ratings.length} ulasan',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _RatingInputWidget(fieldId: field.fieldId, primary: primary),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RatingInputWidget extends StatefulWidget {
  const _RatingInputWidget({required this.fieldId, required this.primary});
  final String fieldId;
  final Color primary;

  @override
  State<_RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<_RatingInputWidget> {
  double _userRating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;
  String? _existingRatingId; // ID rating yang sudah ada
  final repo = FieldCommunityAndRatingRepo();

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final existing = await repo.getUserRating(widget.fieldId, user.uid);
    if (existing != null && mounted) {
      setState(() {
        _userRating = existing.rating;
        _commentController.text = existing.comment;
        _existingRatingId = existing.ratingId; // Simpan ID
      });
    }
  }

  void _submitRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rating terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cek apakah user sudah pernah rating
      if (_existingRatingId != null) {
        // Update rating yang sudah ada
        await repo.updateRating(
          ratingId: _existingRatingId!,
          rating: _userRating,
          comment: _commentController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating berhasil diupdate')),
          );
        }
      } else {
        // Buat rating baru
        await repo.createRating(
          fieldId: widget.fieldId,
          userId: user.uid,
          rating: _userRating,
          comment: _commentController.text,
        );

        // Reload untuk mendapatkan ratingId yang baru dibuat
        await _loadUserRating();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating berhasil disimpan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _existingRatingId == null ? 'Berikan Rating' : 'Edit Rating Anda',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: Icon(
                  i < _userRating ? Icons.star : Icons.star_outline,
                  color: widget.primary,
                  size: 28,
                ),
                onPressed: () => setState(() => _userRating = i + 1.0),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Tambah komentar (opsional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primary,
                disabledBackgroundColor: Colors.grey,
              ),
              onPressed: _isLoading ? null : _submitRating,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _existingRatingId == null
                          ? 'Kirim Rating'
                          : 'Update Rating',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab({required this.fieldId});
  final String fieldId;

  @override
  Widget build(BuildContext context) {
    final repo = FieldCommunityAndRatingRepo();

    return StreamBuilder(
      stream: repo.communitiesForField(fieldId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final communities = snapshot.data ?? [];

        if (communities.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada komunitas untuk lapangan ini',
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final c = communities[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage: c.photo.isNotEmpty
                    ? NetworkImage(c.photo)
                    : null,
                child: c.photo.isEmpty
                    ? const Icon(Icons.groups, color: Colors.black54)
                    : null,
              ),
              title: Text(c.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.weeklyWeekday != null &&
                      c.weeklyStart != null &&
                      c.weeklyEnd != null)
                    Text(
                      [
                            '',
                            'Senin',
                            'Selasa',
                            'Rabu',
                            'Kamis',
                            'Jumat',
                            'Sabtu',
                            'Minggu',
                          ][c.weeklyWeekday!] +
                          ' ${c.weeklyStart} - ${c.weeklyEnd}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  Text(
                    '${c.memberList.length} anggota',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
        );
      },
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
            mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
