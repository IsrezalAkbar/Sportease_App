# 🎯 INSTRUKSI LENGKAP - Xendit Payment Integration

## 📌 RINGKASAN

Integrasi pembayaran Xendit **SUDAH SELESAI DIKODE**.
Yang perlu Anda lakukan hanya **langkah-langkah manual** di bawah ini.

---

## ✅ APA YANG SUDAH SELESAI (TIDAK PERLU DILAKUKAN LAGI)

- ✅ Install package dependencies (url_launcher, webview_flutter)
- ✅ Buat model XenditInvoice
- ✅ Buat XenditService untuk API integration
- ✅ Update BookingModel dengan field payment
- ✅ Update PaymentPage dengan Xendit integration
- ✅ Konfigurasi AndroidManifest.xml untuk url_launcher
- ✅ Dokumentasi lengkap

**Status Code**: ✅ **100% SIAP!** Tidak perlu coding lagi.

---

## ⚠️ YANG HARUS ANDA LAKUKAN SECARA MANUAL

### 🔴 WAJIB (Untuk Testing)

#### 1️⃣ Registrasi Akun Xendit (5 menit)

**Langkah:**

1. Buka browser: https://dashboard.xendit.co/register
2. Klik **"Sign Up for Free"**
3. Isi form:
   - Email: (email Anda)
   - Password: (buat password)
   - Nama bisnis: (contoh: "SPE App Testing")
   - Nomor HP: (nomor Anda)
4. Klik **"Sign Up"**
5. Cek email Anda dan klik link verifikasi
6. Login ke dashboard: https://dashboard.xendit.co/login

**Catatan**: Untuk testing, Anda **TIDAK PERLU** verifikasi bisnis lengkap.

---

#### 2️⃣ Dapatkan Test API Key (2 menit)

**Langkah:**

1. Di dashboard Xendit, klik menu **"Settings"** di sidebar kiri
2. Pilih **"Developers"** atau **"API Keys"**
3. Pilih tab **"Test"** atau **"Development"**
4. Klik tombol **"Generate Secret Key"** atau **"Create Key"**
5. **COPY** API Key yang muncul
   - Format: `xnd_development_O46ARSfGX1r21EA...`
   - ⚠️ **PENTING**: API Key hanya ditampilkan SEKALI! Simpan dengan aman.

---

#### 3️⃣ Update Konfigurasi di Aplikasi (1 menit)

**Langkah:**

1. Buka file: **`lib/core/config/xendit_config.dart`**
2. Cari baris:
   ```dart
   static const String apiKey = 'YOUR_XENDIT_SECRET_API_KEY_HERE';
   ```
3. Ganti dengan API Key Anda:
   ```dart
   static const String apiKey = 'xnd_development_O46ARSfGX1r21EA...';
   ```
4. Save file (Ctrl+S)

---

#### 4️⃣ Jalankan Aplikasi (1 menit)

**Langkah:**

```bash
flutter run
```

Atau tekan **F5** di VS Code.

---

#### 5️⃣ Test Pembayaran (2 menit)

**Langkah di Aplikasi:**

1. Buka aplikasi di emulator/device
2. Login jika belum
3. Pilih lapangan
4. Pilih jadwal booking
5. Klik **"Bayar dengan Xendit"**
6. Browser akan terbuka dengan halaman pembayaran Xendit
7. Pilih metode pembayaran (contoh: Virtual Account BCA)

---

#### 6️⃣ Simulasi Pembayaran (1 menit)

Karena menggunakan Test API Key, pembayaran adalah simulasi (tidak pakai uang real).

**Metode 1: Virtual Account**

1. Copy nomor Virtual Account yang muncul di halaman pembayaran
2. Buka tab baru: https://dashboard.xendit.co/
3. Di sidebar, klik **"Test Payments"** atau **"Invoices"**
4. Cari invoice Anda (berdasarkan jumlah atau waktu)
5. Klik **"Simulate Payment"** atau **"Mark as Paid"**
6. Status berubah menjadi **"PAID"** ✅

**Metode 2: E-Wallet (OVO/DANA)**

1. Di halaman pembayaran Xendit, pilih OVO atau DANA
2. Masukkan nomor HP test: `081234567890`
3. Masukkan OTP test: `123456`
4. Pembayaran otomatis berhasil

**Metode 3: Kartu Kredit**

1. Di halaman pembayaran, pilih Credit Card
2. Masukkan:
   - Card Number: `4000000000000002` (untuk success)
   - CVV: `123`
   - Expiry: Pilih tanggal masa depan (contoh: 12/25)
3. Submit
4. Pembayaran otomatis berhasil

---

### 🟡 OPSIONAL (Untuk Production Nanti)

Ini bisa dilakukan nanti ketika sudah siap production:

#### 7️⃣ Verifikasi Bisnis (1-3 hari)

**Tujuan**: Untuk mendapatkan Live API Key dan terima pembayaran real.

**Langkah:**

1. Login dashboard Xendit
2. Lengkapi profil bisnis:
   - Jenis bisnis
   - Alamat lengkap
   - Informasi pemilik/direktur
3. Upload dokumen:
   - KTP
   - NPWP
   - Dokumen legalitas (jika ada)
4. Submit untuk review
5. Tunggu approval dari tim Xendit (1-3 hari kerja)
6. Anda akan dapat email notifikasi status

---

#### 8️⃣ Setup Webhook (30 menit)

**Tujuan**: Agar status pembayaran otomatis terupdate tanpa perlu manual refresh.

**Langkah:**

1. Buat Firebase Cloud Functions:
   - Copy kode dari file: `XENDIT_WEBHOOK_EXAMPLE.js`
   - Paste ke project Firebase Functions Anda
   - Deploy: `firebase deploy --only functions`
2. Daftarkan Webhook di Xendit:
   - Dashboard > Settings > Webhooks
   - Klik "Add Webhook"
   - URL: `https://REGION-PROJECT.cloudfunctions.net/xenditWebhook`
   - Events: Pilih `invoice.paid` dan `invoice.expired`
   - Save

**Detail lengkap**: Baca file **`XENDIT_SETUP.md`** bagian 4.

---

#### 9️⃣ Switch ke Production (15 menit)

Setelah bisnis verified:

**Langkah:**

1. Generate Live API Key:

   - Dashboard > Settings > API Keys > Live tab
   - Generate Secret Key
   - Copy API Key (format: `xnd_production_...`)

2. Update config:

   - Buka: `lib/core/config/xendit_config.dart`
   - Ganti API Key dengan Live API Key
   - Ubah: `static const bool isDevelopment = false;`

3. Test dengan pembayaran real (pakai amount kecil dulu!)

---

## 📖 DOKUMENTASI YANG TERSEDIA

### Mulai dari sini:

1. **`QUICK_START_XENDIT.md`** ← **BACA INI DULU!**
   - Panduan cepat 5 menit
   - Langkah paling esensial
2. **`XENDIT_SETUP.md`** ← Setup lengkap step-by-step
   - Semua detail dari awal sampai production
   - Troubleshooting
   - Best practices

### Referensi tambahan:

3. **`XENDIT_INTEGRATION.md`** ← Technical overview
4. **`XENDIT_WEBHOOK_EXAMPLE.js`** ← Webhook code
5. **`XENDIT_SUMMARY.md`** ← Summary semua perubahan

---

## 🔍 CHECKLIST TESTING

Copy checklist ini dan centang setiap langkah:

```
SETUP:
[ ] Registrasi akun Xendit
[ ] Verifikasi email
[ ] Login ke dashboard Xendit
[ ] Generate Test API Key
[ ] Copy API Key
[ ] Update lib/core/config/xendit_config.dart
[ ] Save file

TESTING:
[ ] Run aplikasi (flutter run)
[ ] Aplikasi jalan tanpa error
[ ] Login ke aplikasi
[ ] Pilih lapangan
[ ] Pilih jadwal booking
[ ] Klik "Bayar dengan Xendit"
[ ] Browser terbuka dengan halaman Xendit
[ ] Halaman pembayaran muncul dengan benar
[ ] Coba Virtual Account
[ ] Simulasi pembayaran di dashboard Xendit
[ ] Status berubah jadi PAID di dashboard
[ ] Cek Firestore: booking status = "pending"
[ ] Test E-Wallet (OVO/DANA)
[ ] Test Credit Card

OPTIONAL (PRODUCTION):
[ ] Submit verifikasi bisnis
[ ] Tunggu approval
[ ] Generate Live API Key
[ ] Setup webhook (Cloud Functions)
[ ] Daftarkan webhook di Xendit
[ ] Switch config ke production
[ ] Test pembayaran real
```

---

## 🐛 TROUBLESHOOTING CEPAT

### ❌ Error: "Xendit API Key belum dikonfigurasi"

**Solusi**:

- Pastikan sudah update `lib/core/config/xendit_config.dart`
- API Key tidak boleh masih `YOUR_XENDIT_SECRET_API_KEY_HERE`

### ❌ Browser tidak terbuka saat klik "Bayar dengan Xendit"

**Solusi**:

- AndroidManifest.xml sudah diupdate (sudah selesai ✅)
- Restart aplikasi: Stop → flutter run lagi
- Cek permission di device

### ❌ Error: "Invalid API Key"

**Solusi**:

- Pastikan API Key benar (tidak ada spasi di awal/akhir)
- Format harus: `xnd_development_...` atau `xnd_production_...`
- Coba regenerate API Key baru di dashboard

### ❌ Status pembayaran tidak update setelah bayar

**Solusi**:

- Ini normal jika webhook belum di-setup
- Untuk testing, cek manual di Firestore atau dashboard
- Untuk production, setup webhook (langkah opsional #8)

### ❌ "Cannot launch URL" atau "No Activity found"

**Solusi**:

- Pastikan ada browser di device/emulator
- Restart device/emulator
- Cek AndroidManifest.xml (sudah diupdate ✅)

---

## 💳 DATA TEST UNTUK SIMULASI

### Virtual Account

- Semua bank support: BCA, BNI, Mandiri, BRI, Permata
- Simulasi: Dashboard Xendit > Test Payments > Simulate Payment

### E-Wallet

- **Nomor HP test**: `081234567890`
- **OTP test**: `123456`

### Credit Card

- **Success**: `4000000000000002`
- **Failed**: `4000000000000010`
- **CVV**: `123`
- **Expiry**: Any future date (contoh: 12/25)

### QRIS

- Scan QR yang muncul
- Di dashboard Xendit: Simulate Payment

---

## ✅ SELESAI!

Setelah mengikuti langkah 1-6 di atas, aplikasi Anda **SUDAH BISA MENERIMA PEMBAYARAN**! 🎉

**Total waktu setup**: 10-15 menit  
**Biaya**: GRATIS untuk testing (menggunakan Test API Key)

---

## 📞 BANTUAN & SUPPORT

**Jika ada masalah:**

1. **Cek dokumentasi lokal**:

   - `QUICK_START_XENDIT.md`
   - `XENDIT_SETUP.md`

2. **Xendit Resources**:

   - Dashboard: https://dashboard.xendit.co/
   - API Docs: https://developers.xendit.co/
   - Help Center: https://help.xendit.co/

3. **Contact Xendit**:
   - Email: support@xendit.co
   - Live chat di dashboard (working hours)

---

## 🎯 NEXT STEPS

Setelah berhasil testing:

1. ✅ Coba berbagai metode pembayaran
2. 🔄 Setup webhook untuk auto-update (opsional)
3. 📱 Add deep linking untuk better UX (opsional)
4. 🚀 Verifikasi bisnis untuk production (saat siap go live)

---

**Happy Coding! 🚀**

_Last Updated: 18 Desember 2025_
