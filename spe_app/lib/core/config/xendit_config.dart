/// Xendit Configuration
///
/// PENTING: File ini adalah template. Untuk production:
/// 1. Copy file ini ke `xendit_config_prod.dart` (jangan commit ke Git)
/// 2. Update dengan Live API Key
/// 3. Tambahkan `xendit_config_prod.dart` ke .gitignore
///
/// Untuk development, langsung update nilai di bawah dengan Test API Key

class XenditConfig {
  // ============================================================================
  // XENDIT API KEY
  // ============================================================================

  /// API Key dari Xendit Dashboard
  ///
  /// Development: xnd_development_xxxxx
  /// Production:  xnd_production_xxxxx
  ///
  /// Dapatkan dari: https://dashboard.xendit.co/settings/developers
  static const String apiKey =
      'xnd_development_tYOaBm9qcWyjqxnR5znpaAnhm4sDc1zgqmFZlNs3asfrrrPjKn3bMujK6EPM8Cw';

  /// Set ke false untuk production
  static const bool isDevelopment = true;

  /// Base URL Xendit API (jangan diubah)
  static const String baseUrl = 'https://api.xendit.co/v2';

  // ============================================================================
  // INVOICE SETTINGS
  // ============================================================================

  /// Durasi invoice dalam detik (default: 24 jam)
  static const int invoiceDuration = 86400; // 24 jam

  /// Currency (jangan diubah untuk Indonesia)
  static const String currency = 'IDR';

  // ============================================================================
  // REDIRECT URLs
  // ============================================================================

  /// URL redirect setelah pembayaran berhasil
  ///
  /// Untuk aplikasi:
  /// - Gunakan deep link: 'speapp://payment/success'
  /// - Atau URL web: 'https://your-domain.com/payment/success'
  static const String successRedirectUrl =
      'https://your-app.com/payment/success';

  /// URL redirect setelah pembayaran gagal/dibatalkan
  static const String failureRedirectUrl =
      'https://your-app.com/payment/failure';

  // ============================================================================
  // WEBHOOK SETTINGS
  // ============================================================================

  /// Webhook URL untuk notifikasi dari Xendit
  /// Format: https://<region>-<project-id>.cloudfunctions.net/xenditWebhook
  ///
  /// Leave empty jika belum setup webhook
  static const String webhookUrl = '';

  /// Webhook verification token dari Xendit Dashboard
  /// Gunakan untuk verifikasi request dari Xendit
  static const String webhookVerificationToken = '';

  // ============================================================================
  // PAYMENT METHODS
  // ============================================================================

  /// Metode pembayaran yang diaktifkan
  /// Sesuaikan dengan yang diaktifkan di Dashboard Xendit
  static const List<String> enabledPaymentMethods = [
    'BANK_TRANSFER', // Virtual Account
    'EWALLET', // E-Wallet (OVO, DANA, dll)
    'CREDIT_CARD', // Kartu Kredit
    'RETAIL_OUTLET', // Alfamart, Indomaret
    'QR_CODE', // QRIS
  ];

  // ============================================================================
  // BUSINESS INFO
  // ============================================================================

  /// Nama merchant yang muncul di invoice
  static const String merchantName = 'SPE App - Sport Field Booking';

  /// Email untuk notifikasi (opsional)
  static const String merchantEmail = 'admin@speapp.com';

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validasi konfigurasi sebelum digunakan
  static bool get isConfigured {
    return apiKey != 'YOUR_XENDIT_SECRET_API_KEY_HERE' && apiKey.isNotEmpty;
  }

  /// Get error message jika konfigurasi belum lengkap
  static String? get configurationError {
    if (!isConfigured) {
      return 'Xendit API Key belum dikonfigurasi. '
          'Silakan update di lib/core/config/xendit_config.dart';
    }
    return null;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get environment name untuk logging
  static String get environmentName =>
      isDevelopment ? 'Development' : 'Production';

  /// Validasi API Key format
  static bool get isValidApiKey {
    if (!isConfigured) return false;

    if (isDevelopment) {
      return apiKey.startsWith('xnd_development_');
    } else {
      return apiKey.startsWith('xnd_production_');
    }
  }

  /// Get warning jika API Key tidak sesuai environment
  static String? get apiKeyWarning {
    if (!isConfigured) return null;

    if (isDevelopment && !apiKey.startsWith('xnd_development_')) {
      return 'PERINGATAN: Menggunakan Production API Key di Development mode!';
    }

    if (!isDevelopment && !apiKey.startsWith('xnd_production_')) {
      return 'PERINGATAN: Menggunakan Development API Key di Production mode!';
    }

    return null;
  }
}
