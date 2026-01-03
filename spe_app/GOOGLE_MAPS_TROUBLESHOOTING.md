# Google Maps Troubleshooting - "Did Not Find Frame"

## Error: Did Not Find Frame

Ini adalah error umum yang terjadi ketika Google Maps tidak bisa render dengan benar.

## ✅ Checklist - Yang Perlu Dilakukan di Google Cloud Console:

### 1. **Aktifkan APIs yang Diperlukan**

Buka: https://console.cloud.google.com/apis/library

Aktifkan APIs berikut:

- ✅ **Maps SDK for Android** (WAJIB untuk menampilkan map)
- ✅ **Geocoding API** (untuk search alamat)
- ✅ **Places API** (optional, untuk autocomplete)

Cara mengaktifkan:

1. Buka link di atas
2. Search "Maps SDK for Android"
3. Klik "ENABLE"
4. Ulangi untuk Geocoding API

### 2. **Setup Billing Account**

Google Maps memerlukan billing account (walaupun ada free tier):

1. Buka: https://console.cloud.google.com/billing
2. Link project Anda dengan billing account
3. Jangan khawatir - Google memberikan $200 kredit gratis per bulan untuk Maps

### 3. **Restrict API Key (Recommended)**

Untuk keamanan, restrict API key Anda:

1. Buka: https://console.cloud.google.com/apis/credentials
2. Klik API key Anda: `AIzaSyD7OXgZBlTBur6ZTAu5DWW_x5OhD_n-DFE`
3. Di "Application restrictions":
   - Pilih "Android apps"
   - Tambahkan package name: `com.example.spe_app`
   - Tambahkan SHA-1 certificate fingerprint (jalankan command di bawah)
4. Di "API restrictions":
   - Pilih "Restrict key"
   - Centang: Maps SDK for Android, Geocoding API

### 4. **Dapatkan SHA-1 Certificate Fingerprint**

```bash
# Debug Certificate
keytool -list -v -keystore "C:\Users\%USERNAME%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Copy SHA-1 fingerprint yang muncul
```

## 📱 Cek di Aplikasi:

### 1. **Cek Logcat untuk Error Detail**

Jalankan saat aplikasi buka halaman maps:

```bash
adb logcat | findstr "GoogleMaps"
```

Error yang mungkin muncul:

- `Authorization failure` - API key belum benar atau belum enabled
- `BILLING_NOT_ENABLED` - Billing belum diaktifkan
- `API_NOT_ENABLED` - Maps SDK for Android belum diaktifkan

### 2. **Test API Key Manual**

Test apakah API key bekerja:

```
https://maps.googleapis.com/maps/api/geocode/json?address=Jakarta&key=AIzaSyD7OXgZBlTBur6ZTAu5DWW_x5OhD_n-DFE
```

Jika response sukses (200), API key bekerja.

## 🔧 Quick Fixes:

### Fix 1: Restart Everything

```bash
flutter clean
flutter pub get
flutter run --dart-define-from-file=dart_defines.txt
```

### Fix 2: Reinstall App

Uninstall aplikasi dari device, lalu install ulang.

### Fix 3: Cek Internet Connection

Pastikan device punya koneksi internet yang stabil.

## 📝 Current Configuration:

✅ API Key: `AIzaSyD7OXgZBlTBur6ZTAu5DWW_x5OhD_n-DFE`
✅ Package Name: `com.example.spe_app`
✅ AndroidManifest.xml: API key sudah ditambahkan
✅ Permissions: INTERNET, LOCATION sudah ditambahkan
✅ minSdkVersion: 21

## 🎯 Langkah Selanjutnya:

1. **[PENTING]** Buka Google Cloud Console: https://console.cloud.google.com
2. **[PENTING]** Aktifkan "Maps SDK for Android"
3. **[PENTING]** Setup billing account (gratis $200/bulan)
4. Restrict API key dengan package name dan SHA-1
5. Restart aplikasi

## ⚠️ Catatan:

Jika setelah mengaktifkan Maps SDK for Android masih error:

- Tunggu 5-10 menit (propagation time)
- Restart aplikasi
- Jika masih error, share screenshot error dari logcat

## 📞 Link Berguna:

- Google Cloud Console: https://console.cloud.google.com
- APIs & Services: https://console.cloud.google.com/apis/dashboard
- Billing: https://console.cloud.google.com/billing
- Credentials: https://console.cloud.google.com/apis/credentials
