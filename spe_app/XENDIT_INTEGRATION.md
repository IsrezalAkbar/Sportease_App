# Integrasi Xendit Payment Gateway

Dokumentasi lengkap untuk integrasi pembayaran Xendit pada aplikasi SPE App.

## 📦 File yang Ditambahkan/Diubah

### File Baru:

1. **`lib/data/models/xendit_invoice_model.dart`**

   - Model untuk data invoice Xendit
   - Mendukung parsing JSON dari API Xendit

2. **`lib/core/services/xendit_service.dart`**

   - Service untuk integrasi dengan Xendit API
   - Fungsi create invoice, get invoice, expire invoice

3. **`XENDIT_SETUP.md`**

   - Panduan lengkap setup Xendit dari awal
   - Langkah-langkah manual yang harus dilakukan

4. **`XENDIT_WEBHOOK_EXAMPLE.js`**
   - Contoh kode Firebase Cloud Functions untuk webhook
   - Handler untuk notifikasi pembayaran dari Xendit

### File yang Dimodifikasi:

1. **`pubspec.yaml`**

   - Ditambahkan dependency: `url_launcher`, `webview_flutter`

2. **`lib/data/models/booking_model.dart`**

   - Ditambahkan field: `xenditInvoiceId`, `xenditInvoiceUrl`, `paymentMethod`, `paidAt`

3. **`lib/features/booking/pages/payment_page.dart`**
   - Diubah dari StatelessWidget ke StatefulWidget
   - Integrasi dengan XenditService
   - Flow pembayaran lengkap dengan Xendit

## 🚀 Cara Penggunaan

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Setup Xendit Account

Ikuti panduan lengkap di [`XENDIT_SETUP.md`](XENDIT_SETUP.md)

Ringkasan:

- Daftar akun di https://dashboard.xendit.co/register
- Verifikasi email dan lengkapi profil bisnis
- Dapatkan Test API Key dari dashboard
- Update API Key di `lib/core/services/xendit_service.dart`

### 3. Update API Key

Buka file `lib/core/services/xendit_service.dart` dan ganti:

```dart
static const String _apiKey = 'YOUR_XENDIT_SECRET_API_KEY_HERE';
```

Dengan API Key Anda dari Xendit Dashboard:

```dart
static const String _apiKey = 'xnd_development_xxxxxxxxxxxxxxxxxxxxx';
```

### 4. Jalankan Aplikasi

```bash
flutter run
```

## 🎯 Flow Pembayaran

1. **User memilih lapangan dan jadwal**

   - Di halaman booking, user pilih slot waktu yang tersedia

2. **Konfirmasi pembayaran**

   - User diarahkan ke PaymentPage
   - Melihat detail booking dan total pembayaran

3. **Klik "Bayar dengan Xendit"**

   - Aplikasi membuat invoice di Xendit
   - Booking disimpan ke Firestore dengan status "pending"
   - Browser terbuka dengan halaman pembayaran Xendit

4. **User melakukan pembayaran**

   - Pilih metode pembayaran (VA, E-Wallet, Kartu Kredit, dll)
   - Selesaikan pembayaran sesuai instruksi

5. **Update status otomatis (dengan webhook)**
   - Xendit mengirim notifikasi ke webhook
   - Cloud Function update status booking menjadi "paid"
   - User dapat melihat status booking di aplikasi

## 💳 Metode Pembayaran yang Didukung

- **Virtual Account**: BCA, BNI, Mandiri, BRI, Permata
- **E-Wallet**: OVO, DANA, LinkAja, ShopeePay
- **Kartu Kredit/Debit**: Visa, Mastercard, JCB
- **QRIS**: Pembayaran dengan scan QR
- **Retail Outlet**: Alfamart, Indomaret

## 🔧 Konfigurasi Lanjutan

### Setup Webhook (Recommended)

Untuk update status pembayaran otomatis, Anda perlu setup webhook:

1. **Deploy Cloud Function**

   - Copy kode dari `XENDIT_WEBHOOK_EXAMPLE.js` ke project Firebase Functions
   - Deploy dengan: `firebase deploy --only functions`

2. **Daftarkan Webhook di Xendit**
   - Login ke Dashboard Xendit
   - Settings > Webhooks
   - Tambahkan URL Cloud Function Anda
   - Pilih events: `invoice.paid`, `invoice.expired`

Detail lengkap ada di [`XENDIT_SETUP.md`](XENDIT_SETUP.md) bagian 4.

### Konfigurasi URL Redirect

Di `lib/core/services/xendit_service.dart`, sesuaikan URL:

```dart
'success_redirect_url': 'https://your-app.com/payment/success',
'failure_redirect_url': 'https://your-app.com/payment/failure',
```

Atau gunakan Flutter deep linking untuk redirect ke aplikasi.

## 🧪 Testing

### Mode Development (Test API Key)

Gunakan Test API Key untuk testing tanpa uang real.

**Simulasi Pembayaran:**

1. **Virtual Account**

   - Generate VA number di Xendit
   - Di Dashboard Xendit > Test Payments
   - Klik "Simulate Payment" untuk VA tersebut

2. **E-Wallet**

   - Nomor test: `081234567890`
   - OTP: `123456`

3. **Kartu Kredit**
   - Success: `4000000000000002`
   - Failed: `4000000000000010`
   - CVV: `123`, Expiry: any future date

Detail lengkap di [`XENDIT_SETUP.md`](XENDIT_SETUP.md) bagian 5.

## 🔐 Keamanan

**PENTING:**

- ❌ Jangan commit API Key ke Git
- ❌ Jangan share API Key
- ✅ Gunakan environment variables untuk production
- ✅ Gunakan Test API Key untuk development
- ✅ Setup webhook verification token

## 📊 Monitoring

### Dashboard Xendit

- Monitor semua transaksi
- Lihat status pembayaran real-time
- Export laporan keuangan

### Firebase Console

- Monitor Firestore untuk update booking
- Cek Cloud Functions logs untuk webhook
- Setup alerts untuk error

## 🐛 Troubleshooting

### Error: "Invalid API Key"

**Solusi:**

- Pastikan API Key benar dan tidak ada spasi
- Cek apakah menggunakan Test/Live key yang sesuai
- Regenerate API Key jika perlu

### Payment berhasil tapi status tidak update

**Solusi:**

- Cek apakah webhook sudah di-setup
- Lihat webhook logs di Dashboard Xendit
- Cek Firebase Functions logs
- Verifikasi webhook verification token

### Browser tidak buka URL pembayaran

**Solusi:**

- Pastikan `url_launcher` sudah ter-install
- Cek permission di AndroidManifest.xml:
  ```xml
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="https" />
    </intent>
  </queries>
  ```
- Untuk iOS, cek Info.plist

## 📚 Referensi

- **Xendit Documentation**: https://developers.xendit.co/
- **Xendit Dashboard**: https://dashboard.xendit.co/
- **Xendit Help Center**: https://help.xendit.co/
- **url_launcher package**: https://pub.dev/packages/url_launcher

## 📝 Checklist Implementasi

### Development:

- [x] Install dependencies
- [x] Tambah model XenditInvoice
- [x] Buat XenditService
- [x] Update BookingModel
- [x] Update PaymentPage
- [ ] Dapatkan Test API Key dari Xendit
- [ ] Update API Key di `xendit_service.dart`
- [ ] Test flow pembayaran

### Production (Opsional):

- [ ] Setup Firebase Cloud Functions untuk webhook
- [ ] Deploy Cloud Function
- [ ] Daftarkan webhook di Xendit
- [ ] Verifikasi akun bisnis Xendit
- [ ] Dapatkan Live API Key
- [ ] Switch ke Live API Key
- [ ] Test dengan pembayaran real

## 💡 Tips

1. **Mulai dengan Test API Key** - Jangan langsung ke production
2. **Setup Webhook** - Sangat recommended untuk update status otomatis
3. **Monitor Logs** - Selalu cek logs untuk debugging
4. **Handle Errors** - Tambahkan try-catch dan error handling yang baik
5. **User Experience** - Berikan feedback yang jelas ke user tentang status pembayaran

## 📞 Support

Jika ada pertanyaan atau masalah:

- Cek dokumentasi di `XENDIT_SETUP.md`
- Hubungi Xendit Support: support@xendit.co
- Cek Xendit Help Center: https://help.xendit.co/

---

**Status Implementasi**: ✅ Selesai  
**Last Updated**: 18 Desember 2025
