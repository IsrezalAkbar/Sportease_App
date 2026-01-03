# Location Picker dengan Hybrid Geocoding

## Overview

Location Picker sekarang sudah terintegrasi dengan **Hybrid Geocoding System** (Google + OpenStreetMap) yang memberikan pengalaman pemilihan lokasi yang lebih reliable untuk pengelola lapangan.

## Fitur Baru

### 🎯 Visual Indicator Provider

- **Badge Berwarna**: Menampilkan provider geocoding yang digunakan
  - 🔑 **Biru** = Google Geocoding
  - 🗺️ **Hijau** = OpenStreetMap
- **Real-time Update**: Badge muncul setelah geocoding berhasil
- **Check Mark**: Icon centang menandakan geocoding sukses

### 🔄 Auto-Fallback System

1. **Forward Geocoding** (Search by Address):

   - Input: User mengetik alamat di search bar
   - Primary: Coba Google Geocoding dulu
   - Fallback: Jika gagal, otomatis coba OpenStreetMap
   - Output: Map center ke koordinat yang ditemukan + tampilkan alamat

2. **Reverse Geocoding** (Move Map Pin):
   - Trigger: User geser map (auto-detect after 500ms idle)
   - Primary: Coba Google Geocoding dulu
   - Fallback: Jika gagal, otomatis coba OpenStreetMap
   - Output: Update alamat berdasarkan posisi pin

### 📱 Improved User Experience

- **Loading States**: Progress indicator saat geocoding
- **Clear Feedback**: Toast notification menunjukkan provider yang digunakan
- **Error Messages**: Pesan error yang informatif jika semua provider gagal
- **Test Button**: Tombol untuk test geocoding secara manual

## Cara Penggunaan

### 1. Menambahkan Lapangan Baru (Manager)

```dart
// Navigation ke Location Picker
final result = await Navigator.push<LocationPickerResult>(
  context,
  MaterialPageRoute(
    builder: (context) => const LocationPickerPage(),
  ),
);

if (result != null) {
  // Gunakan koordinat dan alamat
  final lat = result.latitude;
  final lon = result.longitude;
  final address = result.address;

  // Save ke database
  await saveField(
    location: GeoPoint(lat, lon),
    locationName: address ?? 'Unknown',
  );
}
```

### 2. Mencari Lokasi dengan Address

1. Ketik alamat di search bar (contoh: "Jl. Sudirman Jakarta")
2. Tekan Enter atau icon search
3. System akan:
   - Coba Google Geocoding dulu
   - Jika gagal → otomatis coba OpenStreetMap
   - Tampilkan notifikasi provider mana yang berhasil
   - Pindahkan map ke lokasi yang ditemukan
   - Update alamat di card bawah

### 3. Memilih Lokasi dengan Pin

1. Geser map ke lokasi yang diinginkan
2. Pin merah di tengah menandakan lokasi yang dipilih
3. Setelah 500ms idle, reverse geocoding otomatis jalan
4. Alamat akan muncul di card bawah dengan badge provider

### 4. Menggunakan GPS Location

1. Tekan chip "Lokasi Saya"
2. Beri izin akses lokasi jika diminta
3. Map akan center ke lokasi GPS current
4. Reverse geocoding otomatis mendapatkan alamat

### 5. Test Geocoding

1. Tekan chip "Test Geocode"
2. System akan force reverse geocode posisi pin saat ini
3. Hasil ditampilkan di snackbar

### 6. Konfirmasi Lokasi

1. Pastikan pin sudah di posisi yang benar
2. Pastikan alamat sudah akurat
3. Tekan chip "Konfirmasi Lokasi"
4. Koordinat & alamat akan dikembalikan ke caller

## Visual Indicators

### Badge Provider

```
┌─────────────────────────────────────────┐
│ 📍 Jl. Sudirman No. 123, Jakarta        │
│                                         │
│ 🔑 Google Geocoding ✓                   │  ← Biru = Google
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 📍 Jalan Sudirman, Jakarta Pusat, DKI   │
│                                         │
│ 🗺️ OpenStreetMap ✓                      │  ← Hijau = OSM
└─────────────────────────────────────────┘
```

### Toast Notifications

**Success (Google)**:

```
🔑 Ditemukan via Google
Jl. Sudirman No. 123, Jakarta Pusat
```

**Success (OpenStreetMap)**:

```
🗺️ Ditemukan via OpenStreetMap
Jalan Sudirman, Tanah Abang, Jakarta Pusat, DKI Jakarta, Indonesia
```

**Error (All Failed)**:

```
❌ Alamat tidak ditemukan dari Google dan OpenStreetMap.
Coba alamat yang lebih spesifik.
```

## Best Practices

### Untuk Pengelola Lapangan

#### ✅ DO:

1. **Gunakan Alamat Lengkap**:

   - Baik: "Jl. Sudirman No. 123, Jakarta Pusat"
   - Kurang: "Sudirman"

2. **Verifikasi Visual**:

   - Setelah search, cek apakah pin sudah di lokasi yang benar
   - Geser pin manual jika perlu koreksi
   - Pastikan alamat yang muncul sudah akurat

3. **Gunakan GPS untuk Akurasi**:

   - Jika sudah di lokasi lapangan, pakai "Lokasi Saya"
   - GPS memberikan koordinat paling akurat

4. **Perhatikan Provider Badge**:
   - Badge hijau (OSM) kadang lebih detail tapi bisa lebih panjang
   - Badge biru (Google) biasanya lebih ringkas dan familiar

#### ❌ DON'T:

1. **Jangan Skip Verifikasi**:

   - Jangan langsung konfirmasi tanpa cek pin location
   - Salah lokasi = user tidak bisa temukan lapangan

2. **Jangan Pakai Alamat Ambigu**:

   - Hindari: "Lapangan", "GOR", "Stadion"
   - Harus: "GOR Sudirman, Jl. Gatot Subroto"

3. **Jangan Abaikan Error Message**:
   - Jika muncul error, coba alamat yang lebih spesifik
   - Atau gunakan GPS location

## Troubleshooting

### Alamat Tidak Ditemukan (Search)

**Penyebab**:

- Alamat terlalu singkat/ambigu
- Typo dalam penulisan
- Kedua provider tidak punya data lokasi tersebut

**Solusi**:

1. Gunakan alamat yang lebih lengkap
2. Tambahkan nama kota/kecamatan
3. Gunakan "Lokasi Saya" jika sudah di lokasi
4. Manual geser pin + cek alamat dari reverse geocoding

### Reverse Geocoding Tidak Jalan

**Penyebab**:

- Map masih bergerak (belum idle)
- Network error
- Koordinat di lokasi yang tidak ada address

**Solusi**:

1. Tunggu sampai map benar-benar berhenti (500ms)
2. Tekan "Test Geocode" untuk force refresh
3. Cek koneksi internet
4. Geser ke lokasi yang lebih umum (dekat jalan/landmark)

### Badge Provider Tidak Muncul

**Penyebab**:

- Geocoding belum selesai
- Geocoding gagal untuk kedua provider

**Solusi**:

1. Tunggu loading selesai (progress bar hilang)
2. Cek log console untuk detail error
3. Coba lagi dengan alamat berbeda

### Loading Terlalu Lama

**Penyebab**:

- Google API timeout → fallback ke OSM (10 detik)
- OSM juga lambat/timeout (10 detik)
- Total worst case: 20 detik

**Solusi**:

1. Normal behavior untuk fallback system
2. Jika terlalu lama, cek koneksi internet
3. Force stop dengan back button → coba lagi

## Technical Details

### Debounce Strategy

- **Forward Search**: No debounce (execute on submit)
- **Reverse Geocode**: 500ms debounce after camera idle
- **Reason**: Avoid too many API calls saat user geser map

### Source Detection Logic

```dart
// Forward Geocoding: Exact source from API response
_geocodingSource = result.source; // 'google' or 'osm'

// Reverse Geocoding: Heuristic detection
// OSM typically returns longer, more detailed addresses
_geocodingSource = addr.contains(',') && addr.length > 100
    ? 'osm'
    : 'google';
```

### Timeout Handling

- Each provider: 10 seconds timeout
- Total max time: 20 seconds (both providers fail)
- User can cancel anytime dengan back button

## Integration with Field Registration

### Manager First Field Registration

```dart
// Di first_field_registration_page.dart
ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _locationLatLng = GeoPoint(
          result.latitude,
          result.longitude,
        );
        _locationNameCtrl.text = result.address ?? '';
      });
    }
  },
  child: const Text('Pilih Lokasi di Peta'),
);
```

### Field Edit/Update

```dart
// Untuk edit lapangan existing
LocationPickerPage(
  initialLat: field.locationLatLng.latitude,
  initialLon: field.locationLatLng.longitude,
  initialAddress: field.locationName,
);
```

## Monitoring & Analytics

### What to Monitor

1. **Provider Usage Ratio**:

   - Count berapa kali Google berhasil
   - Count berapa kali fallback ke OSM
   - Jika OSM > 50%, ada masalah dengan Google API

2. **Success Rate**:

   - Berapa % geocoding berhasil
   - Berapa % gagal dari kedua provider

3. **Response Time**:
   - Average time untuk Google
   - Average time untuk OSM
   - Identify bottleneck

### Log Monitoring

Monitor console log dengan pattern:

```
✅ Google Geocoding berhasil!     → Good
⚠️ Google ... mencoba OSM...       → Google failed, fallback
✅ OpenStreetMap ... berhasil!     → Fallback success
❌ Semua ... provider gagal        → Both failed (rare)
```

## Future Improvements

### Prioritas Tinggi

1. [ ] Add coordinate copy button (untuk debugging)
2. [ ] Show accuracy radius indicator
3. [ ] Add history of recent searches
4. [ ] Implement caching untuk reduce API calls

### Prioritas Sedang

1. [ ] Add custom marker untuk pin center (animated)
2. [ ] Show nearby landmarks sebagai reference
3. [ ] Add compass orientation
4. [ ] Implement address suggestions (autocomplete)

### Prioritas Rendah

1. [ ] Support multiple languages untuk address
2. [ ] Add satellite view toggle
3. [ ] Export analytics dashboard

## Kesimpulan

Hybrid Geocoding di Location Picker memberikan:

- ✅ **Reliability**: Fallback otomatis jika satu provider fail
- ✅ **Transparency**: User tahu provider mana yang digunakan
- ✅ **Better UX**: Visual feedback yang jelas
- ✅ **Easy Integration**: Drop-in replacement, no major code changes
- ✅ **Production Ready**: Error handling lengkap

Pengelola lapangan sekarang bisa menambahkan lokasi dengan confidence bahwa sistem akan selalu bekerja, bahkan jika Google API bermasalah! 🎉
