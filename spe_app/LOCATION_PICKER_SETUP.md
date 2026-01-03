# Location Picker Setup and Usage

This guide explains how to use the new **Location Picker** feature with center pin behavior (Shopee-style), including geocoding and GPS.

## Features

- Forward geocoding: type an address → map centers to result
- Center pin UX: static pin in the middle while map drags
- Reverse geocoding: shows address for pin coordinates when map idle
- Confirm: return accurate coordinates + address
- My Location: center to GPS (permissions handled)
- Open in Google Maps: routing URL (driving) with fallback search
- Null-safety, error/loading-friendly, consistent with app theme

## Files

- `lib/features/location/location_picker_page.dart` (UI + map)
- `lib/core/services/geocoding_service.dart` (Google Geocoding API)
- Router wired at `lib/router/app_router.dart` with `AppRouter.locationPicker`

## How to Use in Code

Push the picker and await result:

```dart
final result = await Navigator.pushNamed(
  context,
  AppRouter.locationPicker,
  arguments: {
    'lat': initialLat, // optional
    'lon': initialLon, // optional
    'address': initialAddress, // optional
    'viewOnly': false, // true to only view
  },
);

if (result is LocationPickerResult) {
  print('Chosen: ${result.latitude}, ${result.longitude}');
  print('Address: ${result.address}');
  // Save to Firestore or local state
}
```

For view-only (user can only see location without confirming):

```dart
Navigator.pushNamed(
  context,
  AppRouter.locationPicker,
  arguments: {
    'lat': lapanganLat,
    'lon': lapanganLon,
    'address': lapanganAddress,
    'viewOnly': true,
  },
);
```

## Permissions and Platform Setup

### Android

`geolocator` usually auto-injects permissions. If needed, confirm these in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

For Android 10+ background location (optional):

```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### iOS

Add these to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to center the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We use your location to center the map.</string>
```

### Web

For web support, ensure `google_maps_flutter` web setup if used. This page targets mobile primarily.

## Geocoding Notes

- This uses **Google Maps Geocoding API**
- You must provide an API key via dart-define
- Steps:
  1. In Google Cloud Console, enable "Geocoding API"
  2. Create an API key and restrict it (Android/iOS bundle, IPs, etc.)
  3. Run the app with:
     ```powershell
     flutter run --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY
     ```
  4. For release builds, add `--dart-define` similarly or store via env/config

## UI/Behavior

- Search field at top → type full address and press search → map centers
- Map drag keeps pin static at center; camera target updates
- When map stops moving, reverse geocoding fetches address
- Bottom card shows current address; displays loading bar while fetching
- Action chips:
  - **Lokasi Saya**: centers map to GPS
  - **Buka di Google Maps**: shows routing URL (can integrate `url_launcher`)
  - **Konfirmasi Lokasi**: returns `LocationPickerResult` (hidden in view-only mode)

## Error/Loading Handling

- Snackbar messages for permission denials, geocode failures, GPS issues
- Progress indicators shown for reverse geocoding
- Safe null-handling throughout

## Optional Enhancements

- Add `url_launcher` and open routing URL directly
- Debounce search queries and show autocomplete list
- Cache reverse geocode results locally
- Replace Nominatim with Google API for reliability at scale

## Troubleshooting

- If GPS fails: ensure location services are enabled and permissions granted
- If geocoding fails: check network and API key validity / quota
- If map does not show: verify `google_maps_flutter` platform setup
