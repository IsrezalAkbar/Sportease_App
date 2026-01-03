import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Temporary simple picker used to unblock builds.
class MapPickerPage extends StatelessWidget {
  const MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Default to Jakarta coordinates
            Navigator.pop(context, const GeoPoint(-6.200000, 106.816666));
          },
          child: const Text('Gunakan lokasi default'),
        ),
      ),
    );
  }
}
