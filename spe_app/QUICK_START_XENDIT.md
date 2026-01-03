# 🚀 Quick Start - Xendit Payment

Panduan cepat untuk menjalankan pembayaran Xendit dalam 5 menit!

## ⚡ Langkah Cepat (Development/Testing)

### 1. Daftar Xendit (5 menit)

1. Buka: https://dashboard.xendit.co/register
2. Isi form registrasi dengan email Anda
3. Verifikasi email
4. **Skip dulu** proses verifikasi bisnis (untuk testing)

### 2. Dapatkan Test API Key (2 menit)

1. Login ke dashboard: https://dashboard.xendit.co/login
2. Klik **Settings** di sidebar kiri
3. Pilih **Developers** atau **API Keys**
4. Di tab **"Test"** atau **"Development"**, klik **"Generate Secret Key"**
5. **Copy** API Key yang muncul (dimulai dengan `xnd_development_`)

   ⚠️ **PENTING**: API Key hanya ditampilkan sekali! Simpan dengan aman.

### 3. Update Konfigurasi (1 menit)

Buka file: `lib/core/config/xendit_config.dart`

Ganti baris ini:

```dart
static const String apiKey = 'YOUR_XENDIT_SECRET_API_KEY_HERE';
```

Dengan API Key Anda:

```dart
static const String apiKey = 'xnd_development_O46ARSfGX1r21EA...';
```

### 4. Jalankan Aplikasi (1 menit)

```bash
flutter run
```

### 5. Test Pembayaran (2 menit)

1. Buka aplikasi
2. Pilih lapangan dan jadwal
3. Klik **"Bayar dengan Xendit"**
4. Browser akan terbuka dengan halaman pembayaran Xendit
5. Pilih metode pembayaran (contoh: Virtual Account BCA)

### 6. Simulasi Pembayaran (1 menit)

Karena menggunakan Test API Key, pembayaran adalah simulasi:

**Virtual Account:**

1. Copy nomor VA yang muncul
2. Buka dashboard Xendit: https://dashboard.xendit.co/
3. Klik menu **Test Payments** di sidebar
4. Cari invoice Anda atau klik **"Simulate Payment"**
5. Status pembayaran akan berubah menjadi "PAID"

**E-Wallet (OVO/DANA):**

- Nomor HP test: `081234567890`
- OTP test: `123456`

**Kartu Kredit:**

- Card: `4000000000000002` (Success)
- CVV: `123`
- Expiry: Tanggal masa depan (contoh: 12/25)

## ✅ Selesai!

Aplikasi Anda sudah bisa menerima pembayaran via Xendit! 🎉

---

## 📖 Dokumentasi Lengkap

Untuk setup production dan fitur lanjutan, baca:

- **Setup Lengkap**: [`XENDIT_SETUP.md`](XENDIT_SETUP.md)
- **Dokumentasi Integrasi**: [`XENDIT_INTEGRATION.md`](XENDIT_INTEGRATION.md)
- **Webhook Setup**: [`XENDIT_WEBHOOK_EXAMPLE.js`](XENDIT_WEBHOOK_EXAMPLE.js)

---

## 🔧 Troubleshooting Cepat

### Error: "Xendit API Key belum dikonfigurasi"

**Solusi**: Update API Key di `lib/core/config/xendit_config.dart`

### Browser tidak terbuka

**Solusi**:

- Android: Tambahkan query di `AndroidManifest.xml`:
  ```xml
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="https" />
    </intent>
  </queries>
  ```
- Restart aplikasi

### Status pembayaran tidak update

**Solusi**: Ini normal untuk testing tanpa webhook.

- Setup webhook untuk auto-update (lihat `XENDIT_SETUP.md`)
- Atau refresh manual dengan re-open halaman booking

---

## 🎯 Next Steps

1. ✅ Test berbagai metode pembayaran
2. 📱 Setup deep linking untuk redirect
3. 🔔 Setup webhook untuk auto-update status
4. 🚀 Prepare untuk production dengan Live API Key

---

## 💡 Tips

- **Test API Key** tidak memerlukan approval bisnis
- **Live API Key** memerlukan verifikasi bisnis (1-3 hari)
- Semua transaksi test **GRATIS** dan tidak menggunakan uang real
- Dashboard Xendit menampilkan semua transaksi test

---

## 📞 Bantuan

**Dokumentasi Xendit**: https://developers.xendit.co/  
**Help Center**: https://help.xendit.co/  
**Support Email**: support@xendit.co

---

**Happy Coding! 🚀**
