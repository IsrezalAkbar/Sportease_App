# Enable Geocoding API - Langkah Mudah ✅

## Masalah yang Dialami

- Pencarian alamat tidak menemukan hasil
- Reverse geocoding (konversi koordinat ke alamat) tidak bekerja
- Error: "Alamat tidak ditemukan"

## Solusi: Aktifkan Geocoding API

### Langkah 1: Buka Google Cloud Console

```
https://console.cloud.google.com/apis/library
```

### Langkah 2: Cari dan Enable Geocoding API

1. Di search box, ketik: **Geocoding API**
2. Klik pada hasil **Geocoding API**
3. Klik tombol biru **ENABLE**
4. Tunggu beberapa detik hingga status berubah menjadi "API enabled"

### Langkah 3: Verifikasi API Key Restriction (Opsional tapi Disarankan)

1. Buka: https://console.cloud.google.com/apis/credentials
2. Klik pada API Key Anda: **AIzaSyD7OXgZBlTBur6ZTAu5DWW_x5OhD_n-DFE**
3. Scroll ke **API restrictions**
4. Pastikan **Geocoding API** sudah ter-checklist di daftar API yang diizinkan
5. Jika belum, tambahkan dengan cara:
   - Select "Restrict key"
   - Checklist: ✅ Geocoding API
   - Checklist: ✅ Maps SDK for Android
   - Klik **Save**

### Langkah 4: Tunggu Propagasi

- Tunggu **2-5 menit** agar perubahan API propagate ke semua server Google
- Setelah itu coba restart aplikasi

### Langkah 5: Test

```bash
flutter run --dart-define-from-file=dart_defines.txt
```

Coba:

1. Buka menu **"Lapangan Terdekat"**
2. Maps akan menampilkan marker hijau untuk semua lapangan terdaftar
3. Ketuk marker untuk melihat info lapangan (nama, alamat, harga)
4. Coba cari alamat di search box (contoh: "Jakarta Selatan")
5. Klik "Lokasi Saya" untuk pergi ke lokasi GPS Anda

## Fitur Baru yang Sudah Ditambahkan ✨

### 1. Marker Lapangan di Peta

- Semua lapangan yang sudah disetujui akan muncul dengan **marker hijau**
- Tap marker untuk melihat:
  - Nama lapangan
  - Alamat lengkap
  - Harga per jam

### 2. Info Window

- Setiap marker menampilkan info window ketika di-tap
- Format info:
  ```
  [Nama Lapangan]
  [Lokasi Lengkap]
  Rp [Harga]/jam
  ```

### 3. Search Alamat

- User bisa mencari alamat dengan mengetik di search box
- Peta akan otomatis zoom ke lokasi tersebut
- Reverse geocoding otomatis menampilkan alamat lengkap

### 4. Lokasi GPS User

- Tombol "Lokasi Saya" untuk pergi ke posisi GPS user
- Menampilkan lapangan terdekat dari posisi user

## Troubleshooting

### Jika masih error "Alamat tidak ditemukan":

1. ✅ Pastikan Geocoding API sudah enabled
2. ✅ Pastikan billing account sudah linked (gratis $200/bulan)
3. ✅ Tunggu 5 menit untuk propagasi
4. ✅ Restart aplikasi Flutter
5. ✅ Cek koneksi internet device

### Jika marker tidak muncul:

1. ✅ Pastikan ada lapangan yang sudah **approved** di database
2. ✅ Pastikan lapangan memiliki **locationLatLng** (GeoPoint) valid
3. ✅ Restart aplikasi

### Jika Maps masih blank/kosong:

1. ✅ Pastikan Maps SDK for Android sudah enabled
2. ✅ Pastikan billing account sudah linked
3. ✅ Cek SHA-1 fingerprint sudah ditambahkan ke API key restrictions

## Status Checklist ✅

- [x] Maps SDK for Android - Enabled
- [x] API Key dikonfigurasi di AndroidManifest.xml
- [x] SHA-1 fingerprint ditambahkan ke API key
- [x] Billing account linked
- [ ] **Geocoding API - BELUM ENABLED** ⬅️ **LAKUKAN INI!**

## Link Penting

- **Enable Geocoding API**: https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com
- **API Credentials**: https://console.cloud.google.com/apis/credentials
- **Billing Setup**: https://console.cloud.google.com/billing

## Hasil Akhir yang Diharapkan

Setelah Geocoding API enabled:

- ✅ Search alamat berfungsi normal
- ✅ Reverse geocoding menampilkan alamat lengkap
- ✅ Marker lapangan muncul di peta dengan warna hijau
- ✅ Info window menampilkan detail lapangan
- ✅ User bisa navigasi ke lokasi GPS mereka
- ✅ Fitur "Lapangan Terdekat" fully functional

---

**Catatan Penting:** Geocoding API adalah GRATIS untuk penggunaan normal. Google memberikan kredit $200/bulan yang lebih dari cukup untuk aplikasi skala development dan production.
