# Fitur Manajemen User oleh Admin

## Deskripsi

Admin dapat melihat dan menghapus user dan pengelola dari sistem.

## Fitur yang Ditambahkan

### 1. Daftar User & Pengelola

- Admin dapat melihat semua user yang terdaftar (kecuali admin)
- Menampilkan informasi:
  - Nama
  - Email
  - Username
  - Role (User/Pengelola)
- Icon berbeda untuk membedakan user dan pengelola:
  - 🟢 User: icon person dengan background hijau
  - 🔵 Pengelola: icon business dengan background biru

### 2. Hapus User

- Tombol hapus (🗑️) di setiap user card
- Konfirmasi sebelum menghapus
- User dihapus dari:
  - ✅ Firestore database
  - ⚠️ Firebase Authentication (dengan catatan khusus)

## Cara Menggunakan

### Melihat Daftar User

1. Login sebagai admin (`adminspe` / `admin123`)
2. Scroll ke bawah ke section "Manajemen User & Pengelola"
3. Akan muncul list semua user dan pengelola

### Menghapus User

1. Klik tombol hapus (🗑️) di user yang ingin dihapus
2. Konfirmasi dengan klik "Hapus"
3. User akan dihapus dari database

## Catatan Teknis Penting

### Tentang Firebase Authentication

**Keterbatasan Flutter:**
Firebase Authentication tidak mengizinkan client-side app (Flutter) untuk menghapus user lain. Hanya user yang sedang login yang bisa menghapus akun mereka sendiri.

**Solusi yang Diimplementasi:**

1. **User dihapus dari Firestore** ✅

   - Data user dihapus dari collection `users`
   - User tidak akan muncul di aplikasi lagi

2. **Proteksi Login** ✅

   - Saat user yang sudah dihapus mencoba login
   - Sistem cek Firestore, jika user tidak ada → logout otomatis
   - User tidak bisa akses aplikasi

3. **Auto-logout jika dihapus** ✅
   - Jika user sedang login dan dihapus oleh admin
   - Auth listener detect user tidak ada di Firestore
   - Otomatis logout

**Untuk Hapus dari Firebase Auth (Optional):**

Jika ingin benar-benar menghapus dari Firebase Auth, perlu setup:

1. Firebase Cloud Functions
2. Firebase Admin SDK
3. API endpoint untuk delete user

**Contoh Cloud Function (Node.js):**

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.deleteUser = functions.https.onCall(async (data, context) => {
  // Verify caller is admin
  if (!context.auth || context.auth.token.role !== "admin") {
    throw new functions.https.HttpsError("permission-denied");
  }

  const uid = data.uid;

  try {
    // Delete from Auth
    await admin.auth().deleteUser(uid);

    // Delete from Firestore
    await admin.firestore().collection("users").doc(uid).delete();

    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});
```

Namun untuk kebutuhan saat ini, solusi yang diimplementasi **sudah cukup** karena:

- User tidak bisa akses app setelah dihapus
- Data user sudah hilang dari database
- Auto-logout jika user dihapus saat sedang login

## Testing

### Test Hapus User

1. Daftar user baru (test@email.com)
2. Login sebagai admin
3. Lihat di "Manajemen User & Pengelola"
4. Hapus user tersebut
5. Coba login dengan test@email.com → akan logout otomatis

### Test Hapus Pengelola

1. Daftar pengelola baru
2. Login sebagai admin
3. Hapus pengelola
4. Verifikasi pengelola tidak bisa akses app

### Test Auto-Logout

1. Login sebagai user A di device/browser A
2. Login sebagai admin di device/browser B
3. Admin hapus user A
4. Lihat di device A → otomatis logout

## Files yang Dimodifikasi

1. **admin_dashboard_page.dart**

   - Added `_buildUserCard()` method
   - Added user management section
   - StreamBuilder untuk UserRepo().allUsers

2. **firestore_user_ds.dart**

   - Updated `deleteUser()` dengan dokumentasi lengkap
   - Penjelasan tentang Firebase Auth limitations

3. **auth_controller.dart**
   - Updated `_init()` untuk auto-logout jika user null di Firestore
   - Proteksi untuk user yang dihapus

## Security

- ✅ Hanya admin yang bisa akses admin dashboard
- ✅ Admin tidak bisa menghapus admin lain (filter `role != 'admin'`)
- ✅ Konfirmasi dialog sebelum hapus
- ✅ Auto-logout untuk user yang dihapus
- ✅ Error handling yang proper

## Troubleshooting

### User masih bisa login setelah dihapus

- Pastikan auth_controller sudah updated
- Check apakah `_init()` method sudah handle userData == null
- Restart aplikasi

### Error saat hapus user

- Check console untuk error detail
- Pastikan Firestore rules mengizinkan admin untuk delete
- Verifikasi user.uid valid

### User tidak muncul di list

- Pastikan user sudah terdaftar dengan benar
- Check apakah StreamBuilder connected
- Lihat Firestore console untuk data users
