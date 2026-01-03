import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../../../data/models/field_model.dart';
import '../../../data/repositories/field_repo.dart';

final fieldRepoProvider = Provider<FieldRepo>((ref) => FieldRepo());

/// Filter state
class ExploreFilter {
  final List<String> facilities;
  final int? minPrice;
  final int? maxPrice;

  ExploreFilter({this.facilities = const [], this.minPrice, this.maxPrice});

  ExploreFilter copyWith({
    List<String>? facilities,
    int? minPrice,
    int? maxPrice,
  }) {
    return ExploreFilter(
      facilities: facilities ?? this.facilities,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

final exploreFilterProvider = StateProvider<ExploreFilter>(
  (ref) => ExploreFilter(),
);

/// Search query provider (with debounce handled in ViewModel below)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Map view toggle
final mapViewProvider = StateProvider<bool>((ref) => false);

/// Sort option: none, price_asc, price_desc, distance
final sortOptionProvider = StateProvider<String>((ref) => 'none');

/// User location provider
final userLocationProvider = FutureProvider<Position?>((ref) async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  } catch (e) {
    return null;
  }
});

/// Helper to calculate distance
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  final a =
      0.5 -
      math.cos((lat2 - lat1) * p) / 2 +
      math.cos(lat1 * p) *
          math.cos(lat2 * p) *
          (1 - math.cos((lon2 - lon1) * p)) /
          2;
  return 12742 * math.asin(math.sqrt(a));
}

/// Stream provider that returns fields based on current search & filter
final exploreFieldsProvider = StreamProvider.autoDispose<List<FieldModel>>((
  ref,
) {
  final repo = ref.read(fieldRepoProvider);
  final filter = ref.watch(exploreFilterProvider);
  final query = ref.watch(searchQueryProvider);
  final sortOption = ref.watch(sortOptionProvider);
  final userLocationAsync = ref.watch(userLocationProvider);

  // create a stream based on repo.queryFields
  final stream = repo.queryFields(
    searchQuery: query.isEmpty ? null : query,
    facilities: filter.facilities.isEmpty ? null : filter.facilities,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
  );

  // Apply sorting
  return stream.map((fields) {
    final sorted = List<FieldModel>.from(fields);

    if (sortOption == 'price_asc') {
      sorted.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
    } else if (sortOption == 'price_desc') {
      sorted.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
    } else if (sortOption == 'distance') {
      userLocationAsync.whenData((pos) {
        if (pos != null) {
          sorted.sort((a, b) {
            final distA = calculateDistance(
              pos.latitude,
              pos.longitude,
              a.locationLatLng.latitude,
              a.locationLatLng.longitude,
            );
            final distB = calculateDistance(
              pos.latitude,
              pos.longitude,
              b.locationLatLng.latitude,
              b.locationLatLng.longitude,
            );
            return distA.compareTo(distB);
          });
        }
      });
    }

    return sorted;
  });
});
