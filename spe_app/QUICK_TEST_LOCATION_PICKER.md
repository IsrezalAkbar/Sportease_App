# Quick Test Guide - Hybrid Geocoding Location Picker

## 🚀 Cara Cepat Test Fitur

### Test 1: Forward Geocoding (Search Address)

1. ✅ Buka aplikasi sebagai Manager
2. ✅ Pilih menu "Tambah Lapangan" atau "First Field Registration"
3. ✅ Tekan tombol "Pilih Lokasi di Peta"
4. ✅ Ketik alamat di search bar: **"Monas Jakarta"**
5. ✅ Tekan Enter atau icon search
6. ✅ Perhatikan:
   - Toast muncul dengan emoji provider (🔑 atau 🗺️)
   - Map bergerak ke lokasi Monas
   - Card bawah update dengan alamat
   - Badge provider muncul (biru=Google, hijau=OSM)

**Expected Result:**

```
Toast: "🔑 Ditemukan via Google"
       "Monumen Nasional, Jakarta Pusat"

Card: 📍 Monumen Nasional, Jl. Silang Monas...
      🔑 Google Geocoding ✓
```

### Test 2: Reverse Geocoding (Move Pin)

1. ✅ Masih di Location Picker
2. ✅ Geser map ke lokasi lain (drag)
3. ✅ Berhenti menggeser → tunggu 500ms
4. ✅ Perhatikan:
   - Progress bar muncul di card
   - Card update dengan alamat baru
   - Badge provider muncul

**Expected Result:**

```
Card: 📍 [Alamat baru sesuai posisi pin]
      🔑 Google Geocoding ✓

      atau

      🗺️ OpenStreetMap ✓
```

### Test 3: GPS Location

1. ✅ Tekan chip "Lokasi Saya"
2. ✅ Beri izin GPS jika diminta
3. ✅ Perhatikan:
   - Map center ke lokasi Anda
   - Reverse geocoding otomatis
   - Alamat lokasi Anda muncul

**Expected Result:**

```
Map: Center ke koordinat GPS Anda
Card: 📍 [Alamat lokasi Anda saat ini]
      🔑 Google Geocoding ✓
```

### Test 4: Test Geocode Button

1. ✅ Geser map ke lokasi mana saja
2. ✅ Tekan chip "Test Geocode"
3. ✅ Perhatikan snackbar muncul 2x:
   - Pertama: "Testing geocoding..."
   - Kedua: Hasil alamat

**Expected Result:**

```
Snackbar 1: "Testing geocoding..."
Snackbar 2: "[Alamat hasil geocoding]"
```

### Test 5: Fallback Mechanism (Google → OSM)

#### Scenario A: Google API Belum Fix (REQUEST_DENIED)

1. ✅ Search alamat: "Jakarta"
2. ✅ Cek log console:
   ```
   🔍 Trying Google Geocoding first...
   ❌ Google REQUEST_DENIED: ...
   ⚠️ Google Geocoding gagal, mencoba OpenStreetMap...
   🗺️ OSM Geocoding request: ...
   ✅ OpenStreetMap Geocoding berhasil!
   ```
3. ✅ Perhatikan:
   - Toast: "🗺️ Ditemukan via OpenStreetMap"
   - Badge hijau: "🗺️ OpenStreetMap ✓"

**Expected Result:**

```
Toast: "🗺️ Ditemukan via OpenStreetMap"
       "Jakarta, DKI Jakarta, Java, Indonesia"

Card: 📍 Jakarta, DKI Jakarta, Java, Indonesia
      🗺️ OpenStreetMap ✓
```

#### Scenario B: Google API Sudah Fix

1. ✅ Google API restrictions sudah benar
2. ✅ Search alamat: "Gelora Bung Karno"
3. ✅ Cek log console:
   ```
   🔍 Trying Google Geocoding first...
   🔑 Google Geocoding request: ...
   ✅ Google Geocoding berhasil!
   ```
4. ✅ Perhatikan:
   - Toast: "🔑 Ditemukan via Google"
   - Badge biru: "🔑 Google Geocoding ✓"

**Expected Result:**

```
Toast: "🔑 Ditemukan via Google"
       "Gelora Bung Karno, Jakarta"

Card: 📍 Gelora Bung Karno, Jakarta
      🔑 Google Geocoding ✓
```

### Test 6: Error Handling (Both Fail)

1. ✅ Search alamat yang tidak ada: "xyzabc12345notexist"
2. ✅ Perhatikan:
   - Loading selesai
   - Toast error muncul

**Expected Result:**

```
Toast: "❌ Alamat tidak ditemukan dari Google dan OpenStreetMap.
        Coba alamat yang lebih spesifik."
```

### Test 7: Complete Flow - Add Field

1. ✅ Buka aplikasi as Manager
2. ✅ Go to First Field Registration
3. ✅ Tekan "Pilih Lokasi di Peta"
4. ✅ Search "Stadion Gelora Bung Karno"
5. ✅ Map center ke GBK
6. ✅ Geser pin sedikit untuk adjust (optional)
7. ✅ Tunggu reverse geocoding update alamat
8. ✅ Tekan "Konfirmasi Lokasi"
9. ✅ Form terisi dengan:
   - Koordinat: (lat, lon)
   - Alamat: "Gelora Bung Karno, Jakarta"

**Expected Result:**

```
Form Field Registration:
- Lokasi: ✓ Sudah dipilih
- Alamat: "Gelora Bung Karno, Jl. Pintu 1 Senayan..."
- Koordinat tersimpan di background
```

## 📊 Checklist Testing

### Basic Functionality

- [ ] Forward geocoding dengan alamat valid
- [ ] Reverse geocoding saat geser map
- [ ] GPS location detection
- [ ] Test geocode button works
- [ ] Konfirmasi lokasi return data

### Hybrid System

- [ ] Google berhasil → badge biru muncul
- [ ] Google gagal → fallback ke OSM
- [ ] OSM berhasil → badge hijau muncul
- [ ] Both fail → error message muncul

### User Experience

- [ ] Loading indicator muncul saat geocoding
- [ ] Toast notification informatif
- [ ] Badge provider muncul setelah success
- [ ] Map smooth animation
- [ ] Debounce berfungsi (reverse geocode setelah 500ms idle)

### Edge Cases

- [ ] Empty search query → tidak crash
- [ ] Very long address → text ellipsis works
- [ ] No internet → error handled gracefully
- [ ] GPS permission denied → error message muncul
- [ ] Invalid coordinates → error handled

### Integration

- [ ] Data return ke caller page (coordinates + address)
- [ ] Data bisa disimpan ke Firestore
- [ ] View-only mode works (no confirm button)
- [ ] Initial location works (edit mode)

## 🐛 Known Issues & Solutions

### Issue 1: Badge Kadang Tidak Akurat

**Symptom**: Badge menunjukkan provider yang salah

**Root Cause**: Reverse geocoding detection menggunakan heuristic (panjang string)

**Solution**: Will be fixed ketika GeocodingService return source explicitly

**Workaround**: Cek log console untuk source yang benar

### Issue 2: Reverse Geocoding Delayed

**Symptom**: Alamat tidak update langsung setelah geser map

**Root Cause**: By design - ada 500ms debounce untuk avoid spam API

**Solution**: This is expected behavior

**Workaround**: Tunggu 500ms atau tekan "Test Geocode" untuk force refresh

### Issue 3: OSM Address Sangat Panjang

**Symptom**: Alamat dari OSM sangat detail dan panjang

**Root Cause**: OSM returns full hierarchical address

**Solution**: Acceptable - more detail is better for location accuracy

**Workaround**: Text ellipsis sudah di-handle di UI (maxLines: 3)

## 📝 Log Patterns to Watch

### Success Pattern (Google)

```
=== FORWARD GEOCODE START ===
Query: Jakarta
🔍 Trying Google Geocoding first...
🔑 Google Geocoding request: https://maps.googleapis.com/...
📡 Google status: 200
📊 Google API status: OK
✅ Google Geocoding berhasil!
=== FORWARD GEOCODE END ===
```

### Fallback Pattern (Google → OSM)

```
=== FORWARD GEOCODE START ===
Query: Jakarta
🔍 Trying Google Geocoding first...
🔑 Google Geocoding request: https://maps.googleapis.com/...
📡 Google status: 200
📊 Google API status: REQUEST_DENIED
❌ Google REQUEST_DENIED: This API project is not authorized...
⚠️ Google Geocoding gagal, mencoba OpenStreetMap...
🗺️ OSM Geocoding request: https://nominatim.openstreetmap.org/...
📡 OSM status: 200
✅ OpenStreetMap Geocoding berhasil!
=== FORWARD GEOCODE END ===
```

### Failure Pattern (Both Failed)

```
=== FORWARD GEOCODE START ===
Query: xyznotexist123
🔍 Trying Google Geocoding first...
❌ Google Geocoding error: ...
⚠️ Google Geocoding gagal, mencoba OpenStreetMap...
🗺️ OSM Geocoding request: https://nominatim.openstreetmap.org/...
⚠️ OSM Geocoding: No results found
❌ Semua geocoding provider gagal
=== FORWARD GEOCODE END ===
```

## 🎯 Success Criteria

Test dianggap **PASS** jika:

1. ✅ Forward geocoding berhasil (Google atau OSM)
2. ✅ Reverse geocoding berhasil (Google atau OSM)
3. ✅ Badge provider muncul dan informatif
4. ✅ Fallback mechanism berfungsi otomatis
5. ✅ Error handling graceful (no crash)
6. ✅ Data bisa dikonfirmasi dan return ke caller
7. ✅ Integration dengan field registration works

Test dianggap **FAIL** jika:

1. ❌ App crash saat geocoding
2. ❌ Geocoding tidak return result padahal alamat valid
3. ❌ Fallback tidak jalan (stuck di Google error)
4. ❌ UI freeze atau hang
5. ❌ Data tidak bisa dikonfirmasi
6. ❌ Toast/badge tidak muncul sama sekali

## 🚨 Troubleshooting During Test

### "Alamat tidak ditemukan" terus

1. Cek log console - cari pattern error
2. Cek internet connection
3. Coba alamat yang lebih umum ("Jakarta" instead of detail address)
4. Test dengan GPS location ("Lokasi Saya")

### Badge tidak muncul

1. Tunggu sampai loading selesai (progress bar hilang)
2. Cek log - apakah geocoding berhasil?
3. Test dengan "Test Geocode" button

### App hang/freeze

1. Force close app
2. Cek log - ada timeout?
3. Cek internet connection
4. Restart app dan test lagi

### GPS tidak bekerja

1. Pastikan GPS device aktif
2. Pastikan app permission granted
3. Coba di outdoor (GPS signal lebih bagus)

## 📞 Need Help?

Jika menemukan issue:

1. Screenshot error (jika ada)
2. Copy log console (pattern emoji memudahkan tracking)
3. Note alamat yang di-test
4. Note provider mana yang gagal/berhasil
5. Report dengan detail lengkap

---

**Happy Testing!** 🎉

Remember: Hybrid system = **More reliable** = **Better UX** = **Happy Users** 😊
