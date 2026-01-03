import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/config/colors.dart';
import '../../core/services/geocoding_service.dart';
import '../../data/repositories/field_repo.dart';
import '../../data/models/field_model.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String? address;
  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  final String? initialAddress;
  final bool viewOnly; // if true, show view mode (no confirm), for users

  const LocationPickerPage({
    super.key,
    this.initialLat,
    this.initialLon,
    this.initialAddress,
    this.viewOnly = false,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final _searchCtrl = TextEditingController();
  final _geocoding = GeocodingService();
  final _fieldRepo = FieldRepo();
  GoogleMapController? _mapCtrl;
  LatLng _cameraTarget = const LatLng(-6.200000, 106.816666); // Jakarta default
  String? _currentAddress;
  String? _geocodingSource; // 'google', 'osm', or null
  bool _isLoading = false;
  bool _isReverseLoading = false;
  Timer? _idleDebounce;
  Set<Marker> _markers = {};
  List<FieldModel> _allFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _cameraTarget = LatLng(widget.initialLat!, widget.initialLon!);
      _currentAddress = widget.initialAddress;
    }
    _loadFields();
  }

  void _loadFields() {
    _fieldRepo.fields.listen((fields) {
      if (!mounted) return;
      setState(() {
        _allFields = fields;
        _buildMarkers();
      });
    });
  }

  void _buildMarkers() {
    final markers = <Marker>{};
    for (var field in _allFields) {
      final geoPoint = field.locationLatLng;
      markers.add(
        Marker(
          markerId: MarkerId(field.fieldId),
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          infoWindow: InfoWindow(
            title: field.name,
            snippet: '${field.locationName}\nRp ${field.pricePerHour}/jam',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
    setState(() {
      _markers = markers;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _idleDebounce?.cancel();
    super.dispose();
  }

  Future<void> _forwardGeocodeAndCenter() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;

    print('=== FORWARD GEOCODE START ===');
    print('Query: $q');

    setState(() {
      _isLoading = true;
      _geocodingSource = null;
    });

    final result = await _geocoding.forwardGeocode(q);

    print('Result: $result');

    if (result != null && _mapCtrl != null) {
      final target = LatLng(result.lat, result.lon);
      _mapCtrl!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 17),
        ),
      );
      setState(() {
        _cameraTarget = target;
        _currentAddress = result.displayName;
        _geocodingSource = result.source;
      });
      if (mounted) {
        final sourceIcon = result.source == 'google' ? '🔑' : '🗺️';
        final sourceName = result.source == 'google'
            ? 'Google'
            : 'OpenStreetMap';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$sourceIcon Ditemukan via $sourceName\n${result.displayName}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Alamat tidak ditemukan dari Google dan OpenStreetMap.\nCoba alamat yang lebih spesifik.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
    print('=== FORWARD GEOCODE END ===');
  }

  Future<void> _reverseGeocodeCenter() async {
    print('=== REVERSE GEOCODE START ===');
    print('Lat: ${_cameraTarget.latitude}, Lon: ${_cameraTarget.longitude}');

    setState(() {
      _isReverseLoading = true;
      _geocodingSource = null;
    });

    final addr = await _geocoding.reverseGeocode(
      lat: _cameraTarget.latitude,
      lon: _cameraTarget.longitude,
    );

    print('Address result: $addr');

    if (addr != null) {
      setState(() {
        _currentAddress = addr;
        _isReverseLoading = false;
        // Detect source from address format or response
        // OSM typically returns longer, more detailed addresses
        _geocodingSource = addr.contains(',') && addr.length > 100
            ? 'osm'
            : 'google';
      });
    } else {
      setState(() {
        _currentAddress = 'Alamat tidak ditemukan';
        _isReverseLoading = false;
        _geocodingSource = null;
      });
    }
    print('=== REVERSE GEOCODE END ===');
  }

  Future<void> _goToMyLocation() async {
    try {
      setState(() => _isLoading = true);
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied ||
            req == LocationPermission.deniedForever) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak')),
            );
          }
          return;
        }
      }
      if (!(await Geolocator.isLocationServiceEnabled())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan lokasi nonaktif. Aktifkan GPS.'),
            ),
          );
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final target = LatLng(pos.latitude, pos.longitude);
      _mapCtrl?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 17),
        ),
      );
      setState(() => _cameraTarget = target);
      await _reverseGeocodeCenter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onCameraMove(CameraPosition pos) {
    _cameraTarget = pos.target;
    print('Camera moved to: ${pos.target.latitude}, ${pos.target.longitude}');
  }

  void _onCameraIdle() {
    print('Camera idle - starting reverse geocode...');
    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        print('Timer triggered - calling reverse geocode');
        _reverseGeocodeCenter();
      }
    });
  }

  void _confirm() {
    Navigator.pop(
      context,
      LocationPickerResult(
        latitude: _cameraTarget.latitude,
        longitude: _cameraTarget.longitude,
        address: _currentAddress,
      ),
    );
  }

  void _openInGoogleMaps() {
    final lat = _cameraTarget.latitude;
    final lon = _cameraTarget.longitude;
    final dirUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving';
    // In-app just copy or launch via url_launcher (not added). For now, show snackbar with URL.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Buka di Google Maps:\n$dirUrl')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.viewOnly ? 'Lapangan Terdekat' : 'Pilih Lokasi Akurat',
        ),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _forwardGeocodeAndCenter(),
                    decoration: const InputDecoration(
                      hintText: 'Cari alamat lengkap',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _forwardGeocodeAndCenter,
                  icon: const Icon(Icons.my_location),
                  tooltip: 'Cari',
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _cameraTarget,
                    zoom: 16,
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (c) => _mapCtrl = c,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  markers: _markers,
                ),
                // Center pin overlay
                IgnorePointer(
                  child: Center(
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Action chips
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.place,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _currentAddress ??
                                              'Mengambil alamat...',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        if (_isReverseLoading)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 6),
                                            child: LinearProgressIndicator(
                                              minHeight: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Geocoding Source Indicator
                              if (_geocodingSource != null &&
                                  !_isReverseLoading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _geocodingSource == 'google'
                                              ? Colors.blue.shade50
                                              : Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _geocodingSource == 'google'
                                                ? Colors.blue.shade200
                                                : Colors.green.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _geocodingSource == 'google'
                                                  ? '🔑'
                                                  : '🗺️',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _geocodingSource == 'google'
                                                  ? 'Google Geocoding'
                                                  : 'OpenStreetMap',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    _geocodingSource == 'google'
                                                    ? Colors.blue.shade700
                                                    : Colors.green.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Lokasi Saya'),
                            avatar: const Icon(Icons.my_location),
                            onPressed: _isLoading ? null : _goToMyLocation,
                          ),
                          ActionChip(
                            label: const Text('Test Geocode'),
                            avatar: const Icon(Icons.bug_report),
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Testing geocoding...'),
                                ),
                              );
                              await _reverseGeocodeCenter();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _currentAddress ?? 'Gagal geocoding',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          if (!widget.viewOnly)
                            ActionChip(
                              label: const Text('Konfirmasi Lokasi'),
                              avatar: const Icon(Icons.check_circle),
                              onPressed: _confirm,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
