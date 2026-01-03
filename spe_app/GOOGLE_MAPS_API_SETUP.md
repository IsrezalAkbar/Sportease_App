# Google Maps API Configuration

API Key berhasil ditambahkan ke:

## Android

- File: `android/app/src/main/AndroidManifest.xml`
- Location: Meta-data dengan name `com.google.android.geo.API_KEY`

## iOS

- File: `ios/Runner/Info.plist`
- Key: `GMSApiKey`

## Dart Code

- Service menggunakan: `String.fromEnvironment('GOOGLE_MAPS_API_KEY')`

## Cara Run dengan API Key:

### Otomatis (Recommended):

```bash
flutter run --dart-define-from-file=dart_defines.txt
```

### Manual:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=
```

## Build Release:

```bash
flutter build apk --dart-define-from-file=dart_defines.txt
```

## Catatan Keamanan:

- Jangan commit `dart_defines.txt` ke Git
- Sudah ditambahkan ke `.gitignore`
- API key sudah di-embed di AndroidManifest.xml dan Info.plist untuk kemudahan development
