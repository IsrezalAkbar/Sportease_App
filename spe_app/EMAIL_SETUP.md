# Setup Email Notifikasi untuk SPE App

Aplikasi menggunakan Google Sign-In untuk pendaftaran pengelola lapangan dan mengirim notifikasi email saat lapangan disetujui.

## 🔧 Setup Google Sign-In

### 1. Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project `spe_app`
3. Masuk ke **Authentication** → **Sign-in method**
4. Aktifkan **Google** provider
5. Isi **Project support email**
6. Klik **Save**

### 2. Android Configuration (SHA-1)

```bash
cd android
./gradlew signingReport
```

- Copy SHA-1 fingerprint
- Di Firebase Console → **Project Settings** → **Your apps** → Android app
- Klik **Add fingerprint**, paste SHA-1
- Download ulang `google-services.json` dan replace di `android/app/`

### 3. iOS Configuration (optional)

- Download `GoogleService-Info.plist` dari Firebase Console
- Place di `ios/Runner/`

---

## 📧 Setup Email Notifikasi

Ada 3 opsi untuk mengirim email:

### **Opsi 1: EmailJS (Recommended - Gratis & Mudah)**

1. **Daftar di [EmailJS](https://www.emailjs.com/)**

   - Sign up dengan akun Google
   - Free tier: 200 emails/bulan

2. **Setup Email Service**

   - Dashboard → Email Services → Add New Service
   - Pilih Gmail/Outlook/dll
   - Connect dengan email Anda
   - Copy **Service ID**

3. **Buat Email Template**

   - Dashboard → Email Templates → Create New Template
   - Template content:

   ```
   Subject: Lapangan {{field_name}} Disetujui!

   Halo {{to_name}},

   Selamat! Lapangan "{{field_name}}" Anda telah disetujui oleh admin.

   Anda sekarang dapat:
   - Melihat lapangan di dashboard pengelola
   - Menambahkan lapangan baru
   - Membuat komunitas dan sparring

   Terima kasih,
   Tim SPE
   ```

   - Copy **Template ID**

4. **Get Public Key**

   - Dashboard → Account → API Keys
   - Copy **Public Key**

5. **Update Kode**

   Edit `lib/features/notifications/email_notification_service.dart`:

   ```dart
   const serviceId = 'service_xxxxxxx';  // Ganti dengan Service ID Anda
   const templateId = 'template_xxxxxx'; // Ganti dengan Template ID Anda
   const publicKey = 'xxxxxxxxxxxxxx';   // Ganti dengan Public Key Anda
   ```

---

### **Opsi 2: Firebase Cloud Functions + SendGrid**

1. **Setup SendGrid**

   - Daftar di [SendGrid](https://sendgrid.com/)
   - Free tier: 100 emails/hari
   - Buat API Key

2. **Deploy Cloud Function**

   Buat file `functions/index.js`:

   ```javascript
   const functions = require("firebase-functions");
   const sgMail = require("@sendgrid/mail");

   sgMail.setApiKey("YOUR_SENDGRID_API_KEY");

   exports.sendFieldApprovedEmail = functions.firestore
     .document("fields/{fieldId}")
     .onUpdate(async (change, context) => {
       const before = change.before.data();
       const after = change.after.data();

       // Cek jika isApproved berubah dari false ke true
       if (!before.isApproved && after.isApproved) {
         const ownerDoc = await admin
           .firestore()
           .collection("users")
           .doc(after.ownerId)
           .get();

         const owner = ownerDoc.data();

         const msg = {
           to: owner.email,
           from: "noreply@spe-app.com",
           subject: `Lapangan ${after.name} Disetujui!`,
           text: `Halo ${owner.name}, lapangan Anda telah disetujui!`,
         };

         await sgMail.send(msg);
       }
     });
   ```

3. **Deploy**
   ```bash
   firebase deploy --only functions
   ```

---

### **Opsi 3: Backend Custom dengan Nodemailer**

Jika Anda punya backend sendiri, gunakan endpoint:

```dart
// Di email_notification_service.dart
await _dio.post(
  'https://your-backend.com/send-email',
  data: {
    'to': recipientEmail,
    'subject': 'Lapangan Disetujui',
    'body': 'Selamat! Lapangan Anda disetujui...'
  },
);
```

---

## 🚀 Testing

### Test Google Sign-In:

1. Pilih **Pengelola Lapangan** di register page
2. Klik **Daftar dengan Google**
3. Pilih akun Google
4. Verify masuk ke halaman registrasi lapangan pertama

### Test Email Notifikasi:

1. Login sebagai pengelola (dengan Google)
2. Daftarkan lapangan
3. Login sebagai admin (`adminspe` / `admin123`)
4. Approve lapangan
5. Cek email pengelola → harus ada notifikasi

---

## 📝 Notes

- **Google Sign-In** hanya untuk pengelola, user biasa tetap pakai email/password
- **Email notifikasi** hanya dikirim saat lapangan disetujui
- Jika email gagal terkirim, approval tetap berjalan (tidak throw error)
- Pastikan email pengelola valid dan aktif

---

## 🔍 Troubleshooting

**Google Sign-In tidak muncul:**

- Pastikan sudah `flutter pub get`
- Cek SHA-1 sudah ditambahkan di Firebase
- Download ulang `google-services.json`

**Email tidak terkirim:**

- Cek API keys sudah benar
- Verify email service aktif (EmailJS/SendGrid)
- Lihat console log untuk error details

**CORS error di web:**

- Tambahkan domain Anda di Firebase Console → Authentication → Authorized domains
