import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final mapControllerProvider =
    StateNotifierProvider<MapControllerNotifier, LatLng?>(
      (_) => MapControllerNotifier(),
    );

class MapControllerNotifier extends StateNotifier<LatLng?> {
  MapControllerNotifier() : super(null);

  void setLocation(LatLng latLng) {
    state = latLng;
  }
}
