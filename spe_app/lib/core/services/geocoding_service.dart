import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final double lat;
  final double lon;
  final String displayName;
  final String source; // 'google' atau 'osm'

  GeocodingResult({
    required this.lat,
    required this.lon,
    required this.displayName,
    this.source = 'unknown',
  });
}

class GeocodingService {
  // Read Google Maps Geocoding API key from dart-define
  static const String _googleApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  // OpenStreetMap Nominatim API
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'SPE_App/1.0';

  /// Forward geocoding dengan fallback: Google -> OpenStreetMap
  Future<GeocodingResult?> forwardGeocode(String query) async {
    if (query.trim().isEmpty) {
      print('🔍 Geocoding: Query kosong');
      return null;
    }

    // Try Google Geocoding first
    print('🔍 Trying Google Geocoding first...');
    final googleResult = await _forwardGeocodeGoogle(query);
    if (googleResult != null) {
      print('✅ Google Geocoding berhasil!');
      return googleResult;
    }

    // Fallback to OpenStreetMap Nominatim
    print('⚠️ Google Geocoding gagal, mencoba OpenStreetMap...');
    final osmResult = await _forwardGeocodeOSM(query);
    if (osmResult != null) {
      print('✅ OpenStreetMap Geocoding berhasil!');
      return osmResult;
    }

    print('❌ Semua geocoding provider gagal');
    return null;
  }

  /// Google Geocoding
  Future<GeocodingResult?> _forwardGeocodeGoogle(String query) async {
    try {
      if (_googleApiKey.isEmpty) {
        print('⚠️ Google API key kosong, skip Google Geocoding');
        return null;
      }

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$_googleApiKey',
      );
      print('🔑 Google Geocoding request: $uri');

      final res = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Google Geocoding timeout');
              throw Exception('Timeout');
            },
          );

      print('📡 Google status: ${res.statusCode}');

      if (res.statusCode != 200) {
        print('❌ Google Geocoding HTTP error: ${res.statusCode}');
        return null;
      }

      final data = jsonDecode(res.body);
      final status = data['status'];
      print('📊 Google API status: $status');

      if (status == 'REQUEST_DENIED') {
        print('❌ Google REQUEST_DENIED: ${data['error_message']}');
        return null;
      }

      if (status == 'OK' && (data['results'] as List).isNotEmpty) {
        final first = data['results'][0];
        final loc = first['geometry']['location'];
        return GeocodingResult(
          lat: (loc['lat'] as num).toDouble(),
          lon: (loc['lng'] as num).toDouble(),
          displayName: first['formatted_address'] ?? query,
          source: 'google',
        );
      }

      print('⚠️ Google Geocoding: No results found');
      return null;
    } catch (e) {
      print('❌ Google Geocoding error: $e');
      return null;
    }
  }

  /// OpenStreetMap Nominatim Geocoding
  Future<GeocodingResult?> _forwardGeocodeOSM(String query) async {
    try {
      final uri = Uri.parse(
        '$_nominatimBaseUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=1&addressdetails=1',
      );
      print('🗺️ OSM Geocoding request: $uri');

      final res = await http
          .get(
            uri,
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ OSM Geocoding timeout');
              throw Exception('Timeout');
            },
          );

      print('📡 OSM status: ${res.statusCode}');

      if (res.statusCode != 200) {
        print('❌ OSM Geocoding HTTP error: ${res.statusCode}');
        return null;
      }

      final data = jsonDecode(res.body);
      if (data is List && data.isNotEmpty) {
        final first = data[0];
        return GeocodingResult(
          lat: double.parse(first['lat'].toString()),
          lon: double.parse(first['lon'].toString()),
          displayName: first['display_name'] ?? query,
          source: 'osm',
        );
      }

      print('⚠️ OSM Geocoding: No results found');
      return null;
    } catch (e) {
      print('❌ OSM Geocoding error: $e');
      return null;
    }
  }

  /// Reverse geocoding dengan fallback: Google -> OpenStreetMap
  Future<String?> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    print('🔍 reverseGeocode called with lat=$lat, lon=$lon');

    // Try Google Reverse Geocoding first
    print('🔍 Trying Google Reverse Geocoding first...');
    final googleResult = await _reverseGeocodeGoogle(lat: lat, lon: lon);
    if (googleResult != null) {
      print('✅ Google Reverse Geocoding berhasil!');
      return googleResult;
    }

    // Fallback to OpenStreetMap Nominatim
    print('⚠️ Google Reverse Geocoding gagal, mencoba OpenStreetMap...');
    final osmResult = await _reverseGeocodeOSM(lat: lat, lon: lon);
    if (osmResult != null) {
      print('✅ OpenStreetMap Reverse Geocoding berhasil!');
      return osmResult;
    }

    print('❌ Semua reverse geocoding provider gagal');
    return null;
  }

  /// Google Reverse Geocoding
  Future<String?> _reverseGeocodeGoogle({
    required double lat,
    required double lon,
  }) async {
    try {
      if (_googleApiKey.isEmpty) {
        print('⚠️ Google API key kosong, skip Google Reverse Geocoding');
        return null;
      }

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$_googleApiKey',
      );
      print('🔑 Google Reverse Geocoding request: $uri');

      final res = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Google Reverse Geocoding timeout');
              throw Exception('Timeout');
            },
          );

      print('📡 Google status: ${res.statusCode}');

      if (res.statusCode != 200) {
        print('❌ Google Reverse Geocoding HTTP error: ${res.statusCode}');
        return null;
      }

      final data = jsonDecode(res.body);
      final status = data['status'];
      print('📊 Google API status: $status');

      if (status == 'REQUEST_DENIED') {
        print('❌ Google REQUEST_DENIED: ${data['error_message']}');
        return null;
      }

      if (status == 'OK' && (data['results'] as List).isNotEmpty) {
        final address = data['results'][0]['formatted_address'] as String?;
        print('✅ Google Reverse result: $address');
        return address;
      }

      print('⚠️ Google Reverse Geocoding: No results found');
      return null;
    } catch (e) {
      print('❌ Google Reverse Geocoding error: $e');
      return null;
    }
  }

  /// OpenStreetMap Nominatim Reverse Geocoding
  Future<String?> _reverseGeocodeOSM({
    required double lat,
    required double lon,
  }) async {
    try {
      final uri = Uri.parse(
        '$_nominatimBaseUrl/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
      );
      print('🗺️ OSM Reverse Geocoding request: $uri');

      final res = await http
          .get(
            uri,
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ OSM Reverse Geocoding timeout');
              throw Exception('Timeout');
            },
          );

      print('📡 OSM status: ${res.statusCode}');

      if (res.statusCode != 200) {
        print('❌ OSM Reverse Geocoding HTTP error: ${res.statusCode}');
        return null;
      }

      final data = jsonDecode(res.body);
      if (data is Map && data.containsKey('display_name')) {
        final address = data['display_name'] as String?;
        print('✅ OSM Reverse result: $address');
        return address;
      }

      print('⚠️ OSM Reverse Geocoding: No results found');
      return null;
    } catch (e) {
      print('❌ OSM Reverse Geocoding error: $e');
      return null;
    }
  }
}
