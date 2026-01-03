# PANDUAN DEPLOY CLOUD FUNCTIONS

## Cara Tercepat (Otomatis)

1. Buka PowerShell di folder root proyek ini
2. Jalankan:
   ```powershell
   .\deploy.ps1
   ```
3. Ikuti instruksi login Firebase di browser
4. Tunggu sampai selesai

## Cara Manual (Jika Script Gagal)

### Step 1: Install Firebase CLI

```powershell
npm install -g firebase-tools
```

### Step 2: Login

```powershell
firebase login
```

### Step 3: Set Project

```powershell
firebase use speapp-f3936
```

### Step 4: Deploy

```powershell
firebase deploy --only functions:sendApprovalEmail
```

## Setelah Deploy Berhasil

1. Install Flutter dependencies:

   ```powershell
   flutter pub get
   ```

2. Jalankan aplikasi:

   ```powershell
   flutter run
   ```

3. Test email:
   - Login sebagai admin (adminspe/admin123)
   - Masuk "Persetujuan Lapangan"
   - Klik "Setujui" pada lapangan pending
   - Cek console untuk log 🔔📧⚽📤📋✅
   - Cek email penerima

## Troubleshooting

### Error: Firebase CLI not found

Jalankan: `npm install -g firebase-tools`

### Error: Not logged in

Jalankan: `firebase login`

### Error: Build failed

Cek file `functions/src/index.ts` untuk syntax error

### Email tidak terkirim

- Cek log: `firebase functions:log --only sendApprovalEmail`
- Pastikan SendGrid API Key benar
- Pastikan sender email terverifikasi di SendGrid

## Keamanan

⚠️ PENTING:

- API Key SendGrid ada di `functions/src/index.ts`
- Jangan commit file ini ke Git public
- Tambahkan ke `.gitignore` atau regenerate API Key setelah deploy

## SendGrid Setup

1. Buka: https://sendgrid.com/
2. Verify sender email di Settings → Sender Authentication
3. Generate API Key di Settings → API Keys
4. Update API Key di `functions/src/index.ts` jika perlu

## Support

Jika ada masalah:

1. Cek Firebase Console → Functions untuk error log
2. Cek SendGrid Dashboard → Activity untuk status email
3. Jalankan: `firebase functions:log --only sendApprovalEmail`
