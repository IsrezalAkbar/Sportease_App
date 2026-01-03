# Email Verification Setup Guide

## Fitur Email Verification

Aplikasi sekarang sudah dilengkapi dengan **email verification** untuk semua registrasi user dan pengelola menggunakan email manual (bukan Google Sign-in).

### Cara Kerja

1. **Registrasi Manual (Email + Password)**

   - User mendaftar dengan email dan password
   - Sistem otomatis mengirim email verifikasi ke alamat email yang didaftarkan
   - User diarahkan ke halaman verifikasi email
   - Sistem akan mengecek status verifikasi setiap 3 detik
   - Setelah user klik link verifikasi di email, otomatis masuk ke aplikasi

2. **Google Sign-in**

   - Email otomatis terverifikasi karena sudah diverifikasi oleh Google
   - Langsung masuk ke aplikasi tanpa perlu verifikasi tambahan

3. **Login**
   - Jika email belum diverifikasi, user akan diarahkan ke halaman verifikasi email
   - User tidak bisa masuk aplikasi sebelum email terverifikasi

### Konfigurasi Firebase

Agar email verification berfungsi dengan baik, lakukan langkah berikut di **Firebase Console**:

#### 1. Setup Email Templates (Opsional - untuk customize email)

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Klik **Authentication** di sidebar kiri
4. Klik tab **Templates**
5. Pilih **Email address verification**
6. Anda bisa customize:
   - **Sender name**: Nama pengirim (contoh: "SPE App")
   - **From email**: Email pengirim (default: noreply@your-project.firebaseapp.com)
   - **Subject**: Subject email
   - **Email body**: Isi email dengan variabel dinamis:
     - `%DISPLAY_NAME%` - Nama user
     - `%EMAIL%` - Email user
     - `%LINK%` - Link verifikasi
     - `%APP_NAME%` - Nama aplikasi

**Contoh Template Email:**

```
Subject: Verifikasi Email Anda di SPE App

Halo %DISPLAY_NAME%,

Terima kasih telah mendaftar di SPE App!

Untuk menyelesaikan pendaftaran, silakan verifikasi alamat email Anda dengan mengklik link di bawah ini:

%LINK%

Link ini akan kedaluwarsa dalam 1 jam.

Jika Anda tidak melakukan pendaftaran ini, abaikan email ini.

Terima kasih,
Tim SPE App
```

#### 2. Authorized Domains (untuk Production)

1. Di **Firebase Console → Authentication**
2. Klik tab **Settings**
3. Scroll ke **Authorized domains**
4. Tambahkan domain website Anda (untuk web deployment)
5. Default sudah ada:
   - `localhost` (untuk development)
   - `*.firebaseapp.com`
   - `*.web.app`

#### 3. Email Link Configuration

1. Di **Firebase Console → Authentication → Settings**
2. Scroll ke **User actions**
3. Pastikan **Email link sign-in** diaktifkan (jika ingin menggunakan email link)
4. Set **Action URL** jika perlu (default sudah OK)

### Fitur di Aplikasi

#### Halaman Email Verification

- Menampilkan instruksi verifikasi email
- Auto-check status verifikasi setiap 3 detik
- Tombol "Kirim Ulang Email" dengan countdown 60 detik
- Tombol "Kembali ke Login" untuk logout dan kembali ke halaman login

#### Flow Registrasi

```
User Register → Email Sent → Verification Page → Auto Check → Verified → Redirect to App
```

#### Flow Login

```
User Login → Check Verified?
  → Yes: Go to App
  → No: Go to Verification Page
```

### Testing

1. **Test Registrasi**

   ```
   - Buka aplikasi
   - Pilih "Daftar"
   - Isi form dengan email valid (bisa Gmail, Yahoo, dll)
   - Klik "Daftar"
   - Cek email inbox (atau spam folder)
   - Klik link verifikasi di email
   - Otomatis redirect ke aplikasi
   ```

2. **Test Login (Email Belum Verified)**

   ```
   - Register tapi jangan verifikasi email
   - Logout
   - Login kembali
   - Akan diarahkan ke halaman verifikasi
   ```

3. **Test Google Sign-in**
   ```
   - Pilih "Daftar dengan Google"
   - Email otomatis terverifikasi
   - Langsung masuk aplikasi
   ```

### Catatan Penting

1. **Development Mode**: Firebase mengirim email langsung, pastikan email valid
2. **Email Verification Link**: Valid selama 1 jam
3. **Google Sign-in**: Tidak perlu verifikasi email tambahan
4. **Admin**: Tidak perlu verifikasi email (hardcoded login)
5. **Resend Email**: Ada cooldown 60 detik untuk mencegah spam

### Troubleshooting

**Email tidak masuk?**

- Cek folder Spam/Junk
- Pastikan email valid dan benar
- Tunggu beberapa menit
- Coba "Kirim Ulang Email"

**Link verifikasi expired?**

- Link valid 1 jam
- Klik "Kirim Ulang Email" untuk mendapatkan link baru

**Stuck di halaman verifikasi?**

- Pastikan sudah klik link di email
- Refresh/reload halaman
- Logout dan login kembali

### Security Benefits

✅ Memastikan email user valid
✅ Mengurangi fake accounts
✅ Melindungi dari bot registrations
✅ User dapat reset password dengan aman (email terverifikasi)

### Next Steps (Opsional)

1. **Custom Email Domain**: Setup SMTP untuk kirim email dari domain sendiri
2. **Email Templates**: Customize tampilan email lebih menarik dengan HTML
3. **Analytics**: Track berapa user yang verify vs tidak verify
4. **Reminder**: Kirim reminder email jika user belum verify setelah X hari

---

## Code Changes Summary

### Files Modified:

1. `lib/features/auth/auth_service.dart` - Added email verification methods
2. `lib/features/auth/auth_controller.dart` - Updated register & login flow
3. `lib/features/auth/check_auth_page.dart` - Added email verification check
4. `lib/router/app_router.dart` - Added email verification route

### Files Created:

1. `lib/features/auth/email_verification_page.dart` - Email verification UI

### Dependencies:

No additional dependencies required - menggunakan Firebase Auth bawaan.
