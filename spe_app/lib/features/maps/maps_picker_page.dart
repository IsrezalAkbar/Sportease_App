import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  LatLng? selectedLatLng;
  bool locating = false;

  final LatLng _defaultCenter = const LatLng(-6.200000, 106.816666); // Jakarta

  @override
  void initState() {
    super.initState();
    _ensureLocationPermission();
  }

  Future<void> _ensureLocationPermission() async {
    await Geolocator.requestPermission();
  }

  Future<void> _goToMyLocation() async {
    setState(() => locating = true);
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final current = LatLng(pos.latitude, pos.longitude);
      _mapController.move(current, 16);
      setState(() {
        selectedLatLng = current;
        locating = false;
      });
    } catch (_) {
      setState(() => locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Lokasi Lapangan")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => selectedLatLng = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.spe_app',
              ),
              if (selectedLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLatLng!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            right: 16,
            top: 16,
            child: FloatingActionButton.extended(
              heroTag: 'myLocation',
              onPressed: locating ? null : _goToMyLocation,
              icon: locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Lokasi Saya'),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: selectedLatLng == null
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        GeoPoint(
                          selectedLatLng!.latitude,
                          selectedLatLng!.longitude,
                        ),
                      );
                    },
              child: const Text("Gunakan Lokasi Ini"),
            ),
          ),
        ],
      ),
    );
  }
}
