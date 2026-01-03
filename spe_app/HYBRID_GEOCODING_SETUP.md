# Hybrid Geocoding Setup (Google + OpenStreetMap)

## Overview

Aplikasi sekarang menggunakan **Hybrid Geocoding** yang menggabungkan Google Geocoding API dan OpenStreetMap Nominatim API dengan sistem fallback otomatis.

## Cara Kerja

### Forward Geocoding (Address → Coordinates)

1. **Primary**: Google Geocoding API dicoba terlebih dahulu
2. **Fallback**: Jika Google gagal, otomatis menggunakan OpenStreetMap Nominatim
3. **Result**: Mengembalikan koordinat dan alamat lengkap dengan label sumber (`google` atau `osm`)

### Reverse Geocoding (Coordinates → Address)

1. **Primary**: Google Reverse Geocoding API dicoba terlebih dahulu
2. **Fallback**: Jika Google gagal, otomatis menggunakan OpenStreetMap Nominatim
3. **Result**: Mengembalikan alamat lengkap dalam bentuk string

## Keuntungan Hybrid System

### ✅ Reliability (Keandalan)

- Jika Google API bermasalah (quota habis, restriction error, timeout), sistem otomatis beralih ke OpenStreetMap
- Tidak ada downtime untuk fitur geocoding

### ✅ No Additional Cost

- OpenStreetMap Nominatim API gratis dan open-source
- Tidak perlu billing untuk fallback system

### ✅ Seamless Experience

- User tidak merasakan perbedaan
- Fallback terjadi secara otomatis dan transparan
- Tetap menggunakan Google Maps untuk display (UI tidak berubah)

### ✅ Detailed Logging

- Setiap request dicatat dengan emoji untuk mudah debug:
  - 🔍 = Proses pencarian
  - 🔑 = Google API call
  - 🗺️ = OpenStreetMap API call
  - ✅ = Berhasil
  - ❌ = Gagal
  - ⚠️ = Warning/fallback
  - 📡 = HTTP response
  - 📊 = API status
  - ⏱️ = Timeout

## API Details

### Google Geocoding API

- **Endpoint**: `https://maps.googleapis.com/maps/api/geocode/json`
- **Auth**: API Key (dari environment variable)
- **Limit**: Tergantung quota Google Cloud
- **Quality**: Sangat akurat, terutama untuk Indonesia

### OpenStreetMap Nominatim API

- **Endpoint**: `https://nominatim.openstreetmap.org`
- **Auth**: Tidak perlu (cukup User-Agent header)
- **Limit**: Max 1 request/second (fair use policy)
- **Quality**: Baik, data community-driven

## Implementation Details

### Forward Geocoding

```dart
final result = await GeocodingService().forwardGeocode('Jakarta');
if (result != null) {
  print('Lat: ${result.lat}, Lon: ${result.lon}');
  print('Address: ${result.displayName}');
  print('Source: ${result.source}'); // 'google' atau 'osm'
}
```

### Reverse Geocoding

```dart
final address = await GeocodingService().reverseGeocode(
  lat: -6.2088,
  lon: 106.8456,
);
if (address != null) {
  print('Address: $address');
}
```

## Error Handling

### Timeout Protection

- Setiap API call memiliki timeout 10 detik
- Jika timeout, langsung fallback ke provider berikutnya

### Network Errors

- Semua network errors ditangkap dengan try-catch
- Error di-log untuk debugging
- Sistem otomatis mencoba provider berikutnya

### No Results

- Jika kedua provider tidak menemukan hasil, return `null`
- Aplikasi dapat menampilkan pesan error yang sesuai

## Best Practices

### 1. Usage Policy

**OpenStreetMap Nominatim** memiliki usage policy:

- Max 1 request per second
- Harus include User-Agent header
- Tidak boleh untuk heavy usage tanpa hosting sendiri

### 2. Caching (Optional)

Untuk mengurangi API calls, pertimbangkan untuk:

- Cache hasil geocoding di local storage
- Hanya call API jika lokasi berbeda signifikan

### 3. Monitoring

Monitor log untuk melihat:

- Seberapa sering fallback ke OSM terjadi
- Apakah ada pattern error dari Google API
- Response time dari masing-masing provider

## Testing

### Test Forward Geocoding

1. Buka aplikasi
2. Masuk ke Location Picker
3. Tekan tombol "Test Geocode"
4. Cek log console untuk melihat provider mana yang digunakan

### Test Reverse Geocoding

1. Buka aplikasi
2. Masuk ke Location Picker
3. Geser map ke lokasi baru
4. Tunggu 1 detik (debounce)
5. Cek log console untuk hasil reverse geocoding

### Test Fallback Mechanism

1. Sementara matikan Google API Key (atau biarkan restriction error)
2. Test geocoding
3. Seharusnya OSM digunakan sebagai fallback
4. Cek log: akan ada warning Google gagal, lalu success dari OSM

## Troubleshooting

### Google API masih REQUEST_DENIED

**Solusi**: Tidak masalah! Sistem akan otomatis fallback ke OpenStreetMap.

### OpenStreetMap too slow

**Solusi**:

- OSM Nominatim kadang lambat karena server gratis
- Pertimbangkan untuk host Nominatim sendiri (advanced)
- Atau fokus memperbaiki Google API restriction

### Tidak ada hasil dari kedua provider

**Kemungkinan penyebab**:

- Query terlalu spesifik atau salah
- Koordinat di luar jangkauan (misalnya di laut)
- Network error

**Solusi**:

- Cek log untuk detail error
- Validate input sebelum geocoding
- Tampilkan error message yang informatif ke user

## Next Steps

### Prioritas Tinggi

1. ✅ Fix Google API restriction (enable Geocoding API di API restrictions)
2. ✅ Wait for propagation (5-10 menit)
3. Test apakah Google API sudah bekerja

### Prioritas Sedang

1. Implementasi caching untuk reduce API calls
2. Add rate limiting untuk OSM (max 1 req/sec)
3. Improve error messages untuk user

### Prioritas Rendah

1. Consider self-hosting Nominatim untuk better performance
2. Add analytics untuk track provider usage
3. Implement batch geocoding untuk multiple addresses

## Kesimpulan

Dengan hybrid geocoding system ini:

- ✅ **Aplikasi tetap berjalan** meski Google API bermasalah
- ✅ **No additional cost** untuk fallback system
- ✅ **Better user experience** dengan reliability tinggi
- ✅ **Easy to maintain** dengan logging yang detail
- ✅ **Tetap menggunakan Google Maps** untuk display (tidak perlu flutter_map)

Sistem ini memberikan **best of both worlds**: kualitas Google API dengan reliability OpenStreetMap sebagai backup!
