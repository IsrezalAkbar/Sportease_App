# Fitur Username Unik

## Deskripsi

Sistem login sekarang mendukung username unik sebagai alternatif login selain email.

## Fitur yang Ditambahkan

### 1. Username Unik

- Username **WAJIB** diisi saat registrasi (required field)
- Username harus unik di seluruh sistem
- Jika username sudah digunakan, registrasi akan gagal dengan pesan error
- Username dapat digunakan untuk login sebagai alternatif email

### 2. Login dengan Username atau Email

- User dapat login menggunakan email atau username
- Sistem otomatis mendeteksi apakah input adalah email (mengandung @) atau username
- Jika username, sistem akan mencari email yang terkait dan login dengan email tersebut

### 3. Google Sign-In Auto-Generate Username

- Saat login dengan Google, sistem otomatis generate username dari email
- Format: bagian sebelum @ pada email
- Jika username sudah dipakai, akan ditambahkan angka (contoh: user1, user2, dst)

## Cara Penggunaan

### Registrasi

1. Buka halaman Register
2. Isi form:
   - Nama Lengkap (wajib)
   - Username (opsional, harus unik)
   - Email (wajib)
   - Password (wajib)
3. Pilih role (User atau Pengelola Lapangan)
4. Klik "Daftar"

Jika username sudah dipakai, akan muncul error:

```
Username "namauser" sudah digunakan. Silakan pilih username lain.
```

### Login

1. Buka halaman Login
2. Masukkan Email ATAU Username
3. Masukkan Password
4. Pilih role
5. Klik "Masuk"

Sistem akan otomatis mendeteksi apakah input adalah email atau username.

### Google Sign-In

1. Pilih role "Pengelola Lapangan"
2. Klik "Daftar dengan Google" atau "Masuk dengan Google"
3. Pilih akun Google
4. Username akan otomatis dibuat dari email Anda

## Perubahan Database

### Firestore Collection: users

Ditambahkan field baru:

```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "role": "string",
  "joinedCommunities": ["array"],
  "photoUrl": "string|null",
  "username": "string|null" // ← Field baru
}
```

## Perbaikan Lainnya

### 1. Fix Infinite Loading Pengelola

**Masalah:** Pengelola tidak bisa login, loading terus menerus
**Penyebab:** Penggunaan `.first` pada stream di listener yang blocking
**Solusi:** Mengubah logic di `check_auth_page.dart` menggunakan `FutureBuilder` untuk async check

### 2. Email Notification Debug

**Ditambahkan:** Logging lengkap untuk debug email notification
**Log yang ditampilkan:**

- 🔔 Email tujuan
- 📧 Nama penerima
- ⚽ Nama lapangan
- 📤 Status pengiriman request
- 📋 Data yang dikirim
- 📬 Response status dan data
- ✅ Success atau ❌ Error

**Cara debug email:**

1. Approve lapangan di admin dashboard
2. Lihat console/terminal untuk log email
3. Cek response status dan data
4. Verifikasi credentials EmailJS sudah benar

### 3. Admin Dashboard - Pending Fields

**Perbaikan:** Admin sekarang bisa melihat lapangan yang belum disetujui
**Perubahan:** Query dari `FieldRepo().fields` (approved only) ke `FieldRepo().allFields` (all fields)

## Testing

### Test Username Unik

1. Daftar user baru dengan username "testuser"
2. Coba daftar lagi dengan username yang sama
3. Verifikasi error muncul

### Test Login dengan Username

1. Daftar dengan username "testuser" dan email "test@email.com"
2. Logout
3. Login dengan "testuser" (bukan email)
4. Verifikasi berhasil login

### Test Login dengan Email

1. Login dengan "test@email.com"
2. Verifikasi tetap berhasil login

### Test Google Sign-In Username

1. Login dengan Google
2. Cek Firestore, verifikasi username otomatis dibuat
3. Login dengan Google lagi (user yang sama)
4. Verifikasi username tidak berubah

## Catatan Teknis

### Files yang Dimodifikasi

1. `lib/data/models/user_model.dart` - Added username field
2. `lib/data/datasources/firestore_user_ds.dart` - Added username queries
3. `lib/data/repositories/user_repo.dart` - Added username methods
4. `lib/features/auth/auth_service.dart` - Added username methods
5. `lib/features/auth/auth_controller.dart` - Updated login, register, Google sign-in
6. `lib/features/auth/register_page.dart` - Added username field
7. `lib/features/auth/login_page.dart` - Updated placeholder text
8. `lib/features/auth/check_auth_page.dart` - Fixed infinite loading
9. `lib/features/notifications/email_notification_service.dart` - Added debug logs

### Method Baru

- `UserDataSource.isUsernameExists(String username)` - Cek username ada atau tidak
- `UserDataSource.getUserByUsername(String username)` - Get user by username
- `UserRepo.isUsernameExists(String username)` - Wrapper untuk datasource
- `UserRepo.getUserByUsername(String username)` - Wrapper untuk datasource
- `AuthService.isUsernameExists(String username)` - Check via Firestore
- `AuthService.getUserByUsername(String username)` - Query via Firestore

### Validasi

- Username bersifat case-sensitive
- Username tidak boleh duplikat
- Username opsional (boleh null)
- Jika tidak diisi saat register email/password, username akan null
- Jika Google sign-in, username auto-generate

## Troubleshooting

### Email Tidak Terkirim

1. Cek console log untuk error detail
2. Verifikasi EmailJS credentials (service_id, template_id, public_key)
3. Pastikan template EmailJS memiliki field yang sesuai
4. Cek quota EmailJS (free tier: 200 emails/bulan)

### Username Sudah Dipakai

- Error normal jika username memang sudah ada
- Pilih username lain
- Username case-sensitive: "User" berbeda dengan "user"

### Loading Terus Menerus

- Sudah diperbaiki dengan FutureBuilder
- Jika masih terjadi, cek console untuk error
- Restart aplikasi

### Login Gagal dengan Username

- Pastikan username ditulis dengan benar (case-sensitive)
- Coba login dengan email
- Cek apakah username memang terdaftar di Firestore
