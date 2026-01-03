import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../explore/widgets/field_card.dart';
import '../explore/widgets/filter_sheet.dart';
import '../field/pages/field_detail_page.dart';
import 'providers/explore_providers.dart';
import '../../data/models/field_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
export 'providers/explore_providers.dart' show calculateDistance;

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  FieldModel? _selectedField;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = val.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapView = ref.watch(mapViewProvider);
    final fieldsAsync = ref.watch(exploreFieldsProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final userLocationAsync = ref.watch(userLocationProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Explore',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sort, size: 20),
            ),
            tooltip: 'Sort',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              ref.read(sortOptionProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'none',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 12),
                    Text('Default'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price_asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 20),
                    SizedBox(width: 12),
                    Text('Harga: Terendah'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price_desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 20),
                    SizedBox(width: 12),
                    Text('Harga: Tertinggi'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'distance',
                enabled: userLocationAsync.value != null,
                child: Row(
                  children: [
                    Icon(
                      Icons.near_me,
                      size: 20,
                      color: userLocationAsync.value == null
                          ? Colors.grey
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Jarak: Terdekat',
                      style: TextStyle(
                        color: userLocationAsync.value == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari lapangan...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8D153A).withOpacity(0.1),
                        const Color(0xFF8D153A).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8D153A).withOpacity(0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFF8D153A)),
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => const FilterSheet(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Map toggle button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: mapView
                          ? [Colors.blue.shade400, Colors.blue.shade600]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: mapView
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(
                      mapView ? Icons.list : Icons.map,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(mapViewProvider.notifier).state = !mapView;
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: fieldsAsync.when(
              data: (fields) {
                if (fields.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada lapangan ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (mapView) {
                  return _buildMapView(fields);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: fields.length,
                  itemBuilder: (_, idx) {
                    final f = fields[idx];
                    String? distanceText;

                    userLocationAsync.whenData((pos) {
                      if (pos != null) {
                        final distance = calculateDistance(
                          pos.latitude,
                          pos.longitude,
                          f.locationLatLng.latitude,
                          f.locationLatLng.longitude,
                        );
                        distanceText = '${distance.toStringAsFixed(1)} km';
                      }
                    });

                    return FieldCard(
                      field: f,
                      distance: distanceText,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FieldDetailPage(field: f),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(List<FieldModel> fields) {
    final markers = fields.map((f) {
      final pos = LatLng(f.locationLatLng.latitude, f.locationLatLng.longitude);
      return Marker(
        markerId: MarkerId(f.fieldId),
        position: pos,
        onTap: () {
          setState(() => _selectedField = f);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();

    final initial = fields.isNotEmpty
        ? CameraPosition(
            target: LatLng(
              fields.first.locationLatLng.latitude,
              fields.first.locationLatLng.longitude,
            ),
            zoom: 13,
          )
        : const CameraPosition(target: LatLng(-6.200000, 106.816666), zoom: 11);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initial,
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
        ),
        if (_selectedField != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildFieldPreviewCard(_selectedField!),
          ),
      ],
    );
  }

  Widget _buildFieldPreviewCard(FieldModel field) {
    final userLocationAsync = ref.watch(userLocationProvider);
    String? distanceText;

    userLocationAsync.whenData((pos) {
      if (pos != null) {
        final distance = calculateDistance(
          pos.latitude,
          pos.longitude,
          field.locationLatLng.latitude,
          field.locationLatLng.longitude,
        );
        distanceText = '${distance.toStringAsFixed(1)} km';
      }
    });

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    field.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _selectedField = null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    field.locationName,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                if (distanceText != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      distanceText!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp ${_formatRupiah(field.pricePerHour)}/jam',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D153A),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FieldDetailPage(field: field),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D153A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Lihat Detail'),
                ),
              ],
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
