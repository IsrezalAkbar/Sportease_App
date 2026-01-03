# 📋 Langkah-Langkah Manual Xendit & Payment UI

## Tahap 1: Setup Xendit Account & API Key ✅ (SUDAH SELESAI)

### Langkah 1.1: Register Xendit Account

- Buka https://xendit.co
- Klik "Sign Up"
- Isi informasi bisnis Anda
- Verify email
- Setup authentication (2FA recommended)

### Langkah 1.2: Generate API Key

- Login ke Xendit Dashboard
- Navigasi ke: Settings → API Keys
- Copy **Test API Key** (dimulai dengan `xnd_development_`)
- Ada di file: `lib/core/config/xendit_config.dart`
- **Current API Key:** `xnd_development_tYOaBm9qcWyjqxnR5znpaAnhm4sDc1zgqmFZlNs3asfrrrPjKn3bMujK6EPM8Cw` ✅

---

## Tahap 2: Integrasi Xendit ke Flutter Project ✅ (SUDAH SELESAI)

### Langkah 2.1: Tambah Dependencies

**File: `pubspec.yaml`**

```yaml
dependencies:
  # ... existing packages ...
  http: ^1.1.0 # Untuk HTTP requests ke Xendit API
  url_launcher: ^6.2.0 # Untuk buka URL pembayaran
  firebase_core: ^4.2.0 # Firebase integration
  firebase_auth: ^6.1.0 # Firebase auth
```

**Status:** ✅ Sudah ditambahkan di pubspec.yaml

### Langkah 2.2: Update AndroidManifest.xml

**File: `android/app/src/main/AndroidManifest.xml`**

Tambahkan permission untuk url_launcher:

```xml
<uses-permission android:name="android.permission.INTERNET" />

<!-- Queries untuk url_launcher -->
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

**Status:** ✅ Sudah ditambahkan

---

## Tahap 3: Buat Models & Services ✅ (SUDAH SELESAI)

### Langkah 3.1: Xendit Invoice Model

**File: `lib/data/models/xendit_invoice_model.dart`**

Model untuk represent invoice dari Xendit API:

- `XenditInvoiceItem`: Item dalam invoice (name, quantity, price)
- `XenditInvoice`: Represent invoice response dari Xendit

**Status:** ✅ Sudah dibuat

### Langkah 3.2: Payment Method Model

**File: `lib/data/models/payment_method_model.dart`**

Mendefinisikan semua metode pembayaran:

- E-Wallet (GoPay, OVO, DANA, LinkAja, ShopeePay)
- Bank VA (BCA, BNI, Mandiri, BRI, Permata)
- Retail (Alfamart, Indomaret)
- QRIS & Kartu Kredit

**Status:** ✅ Sudah dibuat

### Langkah 3.3: Xendit Configuration

**File: `lib/core/config/xendit_config.dart`**

Centralized configuration untuk Xendit:

```dart
class XenditConfig {
  static const apiKey = 'xnd_development_tYOaBm9qcWyjqxnR5znpaAnhm4sDc1zgqmFZlNs3asfrrrPjKn3bMujK6EPM8Cw';
  static const baseUrl = 'https://api.xendit.co';
  // ... configuration lainnya
}
```

**Status:** ✅ Sudah dikonfigurasi dengan API Key

### Langkah 3.4: Xendit Service

**File: `lib/core/services/xendit_service.dart`**

Service layer untuk interact dengan Xendit API:

- `createInvoice()`: Buat invoice pembayaran
- `getInvoice()`: Ambil status invoice
- `expireInvoice()`: Expire invoice
- `mapXenditStatusToAppStatus()`: Map status Xendit ke app status

**Status:** ✅ Sudah dibuat

---

## Tahap 4: Payment UI dengan BNI & Mandiri ✅ (SUDAH SELESAI)

### Langkah 4.1: Redesign Payment Page

**File: `lib/features/booking/pages/payment_page.dart`**

Implementasi payment page dengan:

1. **Progress Indicator (3 Step)**

   - Pilih Jadwal ✓
   - Review Order ✓
   - Pembayaran (active)

2. **Total Pembayaran**

   - Format: Rp 650.000
   - Display amount dengan formatting
   - Daftar items yang dipesan

3. **Payment Method Selection**
   - Kategorisasi 4 section:
     - E-Wallet
     - Bank Transfer (Virtual Account) ← BNI & Mandiri di sini
     - Toko (Retail)
     - Lainnya
4. **Radio Button Selection**

   - Visual feedback saat dipilih
   - Border highlight (#8D153A)
   - Inner circle indicator

5. **Bayar Button**
   - Large button (56px)
   - Loading state dengan spinner
   - Disabled saat processing

**Status:** ✅ Sudah di-redesign

### Langkah 4.2: Bank BNI Virtual Account

**Implementasi:**

```dart
static const bni = PaymentMethod(
  id: 'bni',
  name: 'BNI Virtual Account',
  displayName: 'BNI',
  description: 'Transfer ke Virtual Account BNI',
  xenditCode: 'BNI',
);
```

**Posisi UI:** Bagian "Bank Transfer (Virtual Account)"
**Status:** ✅ Sudah ditambahkan

### Langkah 4.3: Bank Mandiri Virtual Account

**Implementasi:**

```dart
static const mandiri = PaymentMethod(
  id: 'mandiri',
  name: 'Mandiri Virtual Account',
  displayName: 'Mandiri',
  description: 'Transfer ke Virtual Account Mandiri',
  xenditCode: 'MANDIRI',
);
```

**Posisi UI:** Bagian "Bank Transfer (Virtual Account)"
**Status:** ✅ Sudah ditambahkan

---

## Tahap 5: Integrasi ke Booking Flow ✅ (SUDAH SELESAI)

### Langkah 5.1: Update Booking Model

**File: `lib/data/models/booking_model.dart`**

Tambah field untuk tracking pembayaran:

```dart
class BookingModel {
  // ... existing fields ...
  String? xenditInvoiceId;      // ID invoice dari Xendit
  String? xenditInvoiceUrl;     // URL pembayaran
  String? paymentMethod;         // Metode pembayaran yang dipilih
  DateTime? paidAt;              // Waktu pembayaran sukses
}
```

**Status:** ✅ Sudah ditambahkan

### Langkah 5.2: Navigation ke Payment Page

**Dari: `booking_review_page.dart` atau sejenisnya**
**Ke: `payment_page.dart`**

```dart
Navigator.pushNamed(
  context,
  '/payment',
  arguments: {
    'slots': selectedSlots,       // List slot yang dipesan
    'total': totalPrice,          // Total harga
    'fieldId': fieldId,           // ID lapangan
    'fieldName': fieldName,       // Nama lapangan
    'fieldAddress': fieldAddress, // Alamat lapangan
  },
);
```

**Status:** ✅ Sudah siap di routing

---

## Tahap 6: Testing & Verification ✅ (READY)

### Langkah 6.1: Test dengan Payment Method BNI

```
1. Buka app
2. Navigasi ke Payment Page
3. Cari section "Bank Transfer (Virtual Account)"
4. Pilih "BNI"
5. Klik "Bayar"
6. Verifikasi: Invoice dibuat dengan paymentMethod: 'BNI'
```

### Langkah 6.2: Test dengan Payment Method Mandiri

```
1. Buka app
2. Navigasi ke Payment Page
3. Cari section "Bank Transfer (Virtual Account)"
4. Pilih "Mandiri"
5. Klik "Bayar"
6. Verifikasi: Invoice dibuat dengan paymentMethod: 'MANDIRI'
```

### Langkah 6.3: Verifikasi Xendit Dashboard

```
1. Login ke Xendit Dashboard
2. Navigasi ke: Transactions
3. Lihat invoice yang baru dibuat
4. Cek payment method yang digunakan
5. Status harus: PENDING (tunggu pembayaran)
```

---

## Tahap 7: Production Setup (BELUM DILAKUKAN)

### Ketika siap production:

#### Langkah 7.1: Generate Production API Key

- Login ke Xendit Dashboard
- Settings → API Keys
- Generate **Live/Production API Key** (dimulai dengan `xnd_live_`)
- Simpan dengan aman (JANGAN share di public code!)

#### Langkah 7.2: Update Config

**File: `lib/core/config/xendit_config.dart`**

```dart
static const String environment = 'production'; // ubah dari 'development'
static const String apiKey = 'xnd_live_xxxxx'; // Ganti dengan production key
```

#### Langkah 7.3: Firebase Webhook Setup

Setup webhook di Xendit untuk update booking status:

- Webhook URL: `https://your-domain.com/webhooks/xendit`
- Events: `payment.succeeded`, `payment.failed`
- Header: Include API Key untuk verification

#### Langkah 7.4: Booking Status Update

**File: `lib/features/booking/pages/payment_page.dart`**

Di method `_processPayment()`, setelah pembayaran:

```dart
// Update booking status dari 'pending' ke 'paid'
await _bookingRepo.updatePaymentStatus(
  bookingId: bookingId,
  status: 'paid',
  xenditInvoiceId: invoice.id,
  paidAt: DateTime.now(),
);
```

---

## 🔍 File Checklist

### Core Files Dibuat:

- [x] `lib/core/config/xendit_config.dart` - Xendit configuration
- [x] `lib/core/services/xendit_service.dart` - Xendit API service
- [x] `lib/data/models/xendit_invoice_model.dart` - Invoice model
- [x] `lib/data/models/payment_method_model.dart` - Payment method model

### UI Files Diupdate:

- [x] `lib/features/booking/pages/payment_page.dart` - Payment UI dengan bank VA
- [x] `lib/data/models/booking_model.dart` - Tambah payment fields

### Config Files Updated:

- [x] `pubspec.yaml` - Dependencies (http, url_launcher)
- [x] `android/app/src/main/AndroidManifest.xml` - URL launcher permission

### Documentation:

- [x] `PAYMENT_IMPLEMENTATION.md` - Dokumentasi implementasi
- [x] `XENDIT_SETUP.md` - Setup guide (dari sebelumnya)
- [x] Langkah-langkah manual ini

---

## 📞 Support & Troubleshooting

### Error: "API Key is invalid"

- Verifikasi API key di `xendit_config.dart`
- Pastikan tidak ada spasi extra di awal/akhir key

### Error: "Cannot launch payment URL"

- Pastikan `url_launcher` dependency sudah ditambahkan
- Android: Update `AndroidManifest.xml` dengan url launcher queries
- iOS: Update `Info.plist` dengan LSApplicationQueriesSchemes

### Payment tidak ter-create di Xendit

- Cek network connection
- Cek Xendit API status: https://status.xendit.co
- Lihat error message di console untuk detail

### Bank Transfer Virtual Account tidak muncul

- Pastikan bank sudah di-enable di Xendit account settings
- Cek list `PaymentMethods.banks` di `payment_method_model.dart`
- Verifikasi Xendit code untuk bank (e.g., 'BNI', 'MANDIRI')

---

## ✨ Next Steps (Optional Enhancements)

1. **Payment Icons**: Replace emoji dengan proper icons/logos dari assets
2. **Animation**: Tambah smooth transition saat select payment method
3. **Payment History**: Show previous transactions
4. **Receipt**: Auto-generate receipt setelah pembayaran sukses
5. **Email Notification**: Send payment confirmation ke user email
6. **Webhook Integration**: Auto-update booking status saat payment received
7. **Dispute Handling**: Handle payment disputes & refunds

---

**Status Keseluruhan: ✅ SIAP UNTUK TESTING & DEPLOYMENT**

Semua fitur sudah diimplementasikan sesuai request!
