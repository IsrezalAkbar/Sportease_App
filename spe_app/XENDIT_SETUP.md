# Setup Pembayaran Xendit - Panduan Lengkap

## 📋 Daftar Isi

1. [Registrasi Akun Xendit](#1-registrasi-akun-xendit)
2. [Mendapatkan API Key](#2-mendapatkan-api-key)
3. [Konfigurasi Aplikasi](#3-konfigurasi-aplikasi)
4. [Setup Webhook (Opsional)](#4-setup-webhook-opsional)
5. [Testing](#5-testing)
6. [Deployment Production](#6-deployment-production)

---

## 1. Registrasi Akun Xendit

### Langkah Manual:

1. **Buka Website Xendit**
   - Kunjungi: https://dashboard.xendit.co/register
2. **Daftar Akun Baru**
   - Pilih "Sign Up for Free"
   - Isi form registrasi:
     - Email bisnis Anda
     - Password
     - Nama bisnis
     - Nomor telepon
3. **Verifikasi Email**
   - Cek email Anda
   - Klik link verifikasi dari Xendit
4. **Lengkapi Profil Bisnis**

   - Login ke dashboard Xendit
   - Lengkapi informasi bisnis:
     - Jenis bisnis
     - Alamat bisnis
     - Informasi pemilik/direktur
     - Upload dokumen (KTP, NPWP, dll)

5. **Tunggu Approval**
   - Tim Xendit akan melakukan verifikasi (biasanya 1-3 hari kerja)
   - Anda akan menerima email notifikasi status approval

---

## 2. Mendapatkan API Key

### Langkah Manual:

1. **Login ke Dashboard Xendit**
   - Kunjungi: https://dashboard.xendit.co/login
2. **Akses Settings**
   - Di sidebar kiri, klik menu **Settings**
   - Pilih submenu **Developers** atau **API Keys**
3. **Generate API Key**

   **Untuk Development/Testing:**

   - Di tab "Test Environment" atau "Sandbox"
   - Klik tombol **"Generate Secret Key"**
   - Catat API Key yang muncul (hanya ditampilkan sekali!)
   - Format: `xnd_development_xxxxxxxxxxxxxxxxxxxxx`

   **Untuk Production (setelah akun disetujui):**

   - Di tab "Live Environment" atau "Production"
   - Klik tombol **"Generate Secret Key"**
   - Catat API Key yang muncul
   - Format: `xnd_production_xxxxxxxxxxxxxxxxxxxxx`

4. **Simpan API Key dengan Aman**
   - Jangan share API Key ke siapapun
   - Jangan commit API Key ke Git
   - Simpan di environment variables atau secure storage

---

## 3. Konfigurasi Aplikasi

### Langkah Manual:

1. **Install Dependencies**

   ```bash
   cd "d:\kuliah\tugas semester 5\prak sistem bergerak\spe_app"
   flutter pub get
   ```

2. **Konfigurasi API Key**

   **File:** `lib/core/services/xendit_service.dart`

   Buka file tersebut dan ganti baris:

   ```dart
   static const String _apiKey = 'YOUR_XENDIT_SECRET_API_KEY_HERE';
   ```

   Menjadi (gunakan API Key dari step 2):

   ```dart
   static const String _apiKey = 'xnd_development_xxxxxxxxxxxxxxxxxxxxx';
   ```

3. **Konfigurasi URL Redirect (Opsional)**

   Di file yang sama, sesuaikan URL redirect:

   ```dart
   'success_redirect_url': 'https://your-app.com/payment/success',
   'failure_redirect_url': 'https://your-app.com/payment/failure',
   ```

   Ganti dengan URL aplikasi Anda atau gunakan deep link Flutter.

4. **Aktifkan Metode Pembayaran**

   Login ke Dashboard Xendit:

   - Masuk ke menu **Settings > Payment Methods**
   - Aktifkan metode pembayaran yang diinginkan:
     - ✓ Virtual Account (BCA, BNI, Mandiri, BRI, Permata)
     - ✓ E-Wallet (OVO, DANA, LinkAja, ShopeePay)
     - ✓ Kartu Kredit/Debit
     - ✓ QRIS
     - ✓ Retail Outlet (Alfamart, Indomaret)

---

## 4. Setup Webhook (Opsional)

Webhook diperlukan untuk update otomatis status pembayaran.

### Langkah Manual:

1. **Setup Backend/Cloud Function**

   Anda perlu membuat endpoint backend untuk menerima webhook dari Xendit.

   **Contoh dengan Firebase Cloud Functions:**

   ```javascript
   const functions = require("firebase-functions");
   const admin = require("firebase-admin");
   admin.initializeApp();

   exports.xenditWebhook = functions.https.onRequest(async (req, res) => {
     // Verify webhook token
     const xenditCallbackToken = "YOUR_WEBHOOK_VERIFICATION_TOKEN";
     const callbackToken = req.headers["x-callback-token"];

     if (callbackToken !== xenditCallbackToken) {
       return res.status(401).send("Unauthorized");
     }

     const { external_id, status, payment_method } = req.body;

     try {
       // Update booking status di Firestore
       const bookingsSnapshot = await admin
         .firestore()
         .collection("bookings")
         .where("bookingId", ">=", external_id)
         .where("bookingId", "<=", external_id + "\uf8ff")
         .get();

       const batch = admin.firestore().batch();

       bookingsSnapshot.forEach((doc) => {
         batch.update(doc.ref, {
           paymentStatus: status === "PAID" ? "paid" : status.toLowerCase(),
           paymentMethod: payment_method,
           paidAt: admin.firestore.FieldValue.serverTimestamp(),
         });
       });

       await batch.commit();
       res.status(200).send("OK");
     } catch (error) {
       console.error("Error:", error);
       res.status(500).send("Error");
     }
   });
   ```

2. **Deploy Cloud Function**

   ```bash
   firebase deploy --only functions:xenditWebhook
   ```

3. **Konfigurasi Webhook di Xendit**

   - Login ke Dashboard Xendit
   - Masuk ke **Settings > Webhooks**
   - Klik **"Add Webhook"**
   - Isi form:
     - **Webhook URL**: URL cloud function Anda
       (contoh: `https://us-central1-your-project.cloudfunctions.net/xenditWebhook`)
     - **Events**: Pilih events yang ingin di-track:
       - ✓ invoice.paid
       - ✓ invoice.expired
   - Klik **"Create"**

4. **Catat Verification Token**
   - Setelah webhook dibuat, salin **Verification Token**
   - Gunakan token ini di backend untuk verifikasi request

---

## 5. Testing

### Langkah Manual:

1. **Run Aplikasi**

   ```bash
   flutter run
   ```

2. **Test Flow Pembayaran**

   - Buka aplikasi
   - Pilih lapangan
   - Pilih jadwal booking
   - Klik "Bayar dengan Xendit"
   - Browser akan terbuka dengan halaman pembayaran Xendit

3. **Simulasi Pembayaran (Test Mode)**

   Xendit menyediakan data test untuk simulasi:

   **Virtual Account:**

   - Gunakan nomor VA yang di-generate
   - Di dashboard Xendit, buka menu **Test Payments**
   - Klik **"Simulate Payment"** untuk VA tersebut

   **E-Wallet (Test):**

   - Pilih OVO/DANA
   - Gunakan nomor test: `081234567890`
   - OTP test: `123456`

   **Kartu Kredit (Test):**

   - Card Number: `4000000000000002` (Success)
   - CVV: `123`
   - Expiry: Any future date

4. **Verifikasi Status**
   - Cek dashboard Xendit untuk melihat status pembayaran
   - Cek Firestore untuk memastikan booking status ter-update
   - Cek di aplikasi apakah booking muncul dengan status yang benar

---

## 6. Deployment Production

### Langkah Manual:

1. **Verifikasi Akun Xendit Approved**

   - Pastikan akun bisnis Anda sudah diapprove oleh Xendit
   - Status akan terlihat di dashboard

2. **Ganti ke Live API Key**

   Di `lib/core/services/xendit_service.dart`:

   ```dart
   static const String _apiKey = 'xnd_production_xxxxxxxxxxxxxxxxxxxxx';
   ```

3. **Update Webhook ke Production URL**

   - Pastikan webhook URL mengarah ke production backend
   - Update di Dashboard Xendit

4. **Testing Production**

   - Lakukan test dengan pembayaran real (minimal amount)
   - Pastikan semua flow berjalan dengan baik

5. **Monitoring**
   - Pantau dashboard Xendit untuk transaksi
   - Setup notifikasi email untuk transaksi penting
   - Monitor Firebase Firestore untuk konsistensi data

---

## 🔒 Keamanan

**PENTING - Jangan Lakukan Ini:**

- ❌ Commit API Key ke Git
- ❌ Share API Key ke orang lain
- ❌ Simpan API Key di client-side code (production)
- ❌ Log API Key di console

**Best Practices:**

- ✅ Simpan API Key di environment variables
- ✅ Gunakan Test API Key untuk development
- ✅ Gunakan webhook verification token
- ✅ Validasi semua input dari user
- ✅ Log semua transaksi untuk audit

---

## 📱 Metode Pembayaran yang Didukung

Setelah setup, user dapat bayar dengan:

1. **Virtual Account**

   - BCA
   - BNI
   - Mandiri
   - BRI
   - Permata
   - BJB
   - Sahabat Sampoerna

2. **E-Wallet**

   - OVO
   - DANA
   - LinkAja
   - ShopeePay

3. **Kartu Kredit/Debit**

   - Visa
   - Mastercard
   - JCB
   - American Express

4. **QRIS**

   - Scan QR untuk bayar dari berbagai e-wallet

5. **Retail Outlet**
   - Alfamart
   - Indomaret

---

## 🐛 Troubleshooting

### Error: "Invalid API Key"

- Pastikan API Key sudah benar
- Pastikan tidak ada spasi di awal/akhir API Key
- Cek apakah menggunakan Test/Live API Key yang sesuai

### Error: "Invoice creation failed"

- Cek koneksi internet
- Cek format data yang dikirim
- Cek log error untuk detail

### Pembayaran berhasil tapi status tidak update

- Pastikan webhook sudah di-setup dengan benar
- Cek webhook logs di Dashboard Xendit
- Cek Firebase Cloud Functions logs

### Browser tidak membuka URL pembayaran

- Pastikan permission untuk open URL sudah di-grant
- Cek AndroidManifest.xml dan Info.plist untuk url_launcher config

---

## 📞 Support

Jika ada masalah:

- **Xendit Help Center**: https://help.xendit.co/
- **Xendit Support Email**: support@xendit.co
- **Xendit API Documentation**: https://developers.xendit.co/

---

## ✅ Checklist Setup

- [ ] Registrasi akun Xendit
- [ ] Verifikasi email
- [ ] Lengkapi profil bisnis
- [ ] Tunggu approval (untuk production)
- [ ] Generate Test API Key
- [ ] Install dependencies (`flutter pub get`)
- [ ] Update API Key di `xendit_service.dart`
- [ ] Aktifkan metode pembayaran di dashboard
- [ ] Setup webhook (opsional tapi recommended)
- [ ] Test pembayaran di development
- [ ] Generate Live API Key (setelah approval)
- [ ] Switch ke Live API Key untuk production
- [ ] Deploy dan monitor

---

**Selamat! Integrasi Xendit sudah siap digunakan. 🎉**
