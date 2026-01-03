import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/xendit_invoice_model.dart';
import '../config/xendit_config.dart';

class XenditService {
  // API Key dan konfigurasi diambil dari XenditConfig
  String get _apiKey => XenditConfig.apiKey;
  String get _baseUrl => XenditConfig.baseUrl;

  /// Membuat invoice pembayaran baru di Xendit
  ///
  /// Parameters:
  /// - externalId: ID unik untuk invoice (biasanya bookingId)
  /// - amount: Jumlah pembayaran dalam Rupiah
  /// - payerEmail: Email pembayar
  /// - description: Deskripsi pembayaran
  /// - items: List item yang dibeli (optional)
  ///
  /// Returns: XenditInvoiceModel dengan URL pembayaran
  Future<XenditInvoiceModel> createInvoice({
    required String externalId,
    required int amount,
    required String payerEmail,
    required String description,
    List<XenditInvoiceItem>? items,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/invoices');

      // Encode API Key ke Base64 untuk Basic Auth
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}';

      // Validasi konfigurasi
      if (!XenditConfig.isConfigured) {
        throw Exception(XenditConfig.configurationError);
      }

      final body = {
        'external_id': externalId,
        'amount': amount,
        'payer_email': payerEmail,
        'description': description,
        'invoice_duration': XenditConfig.invoiceDuration,
        'currency': XenditConfig.currency,
        'success_redirect_url': XenditConfig.successRedirectUrl,
        'failure_redirect_url': XenditConfig.failureRedirectUrl,
        if (items != null && items.isNotEmpty)
          'items': items.map((item) => item.toJson()).toList(),
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return XenditInvoiceModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Gagal membuat invoice: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error saat membuat invoice Xendit: $e');
    }
  }

  /// Mendapatkan status invoice dari Xendit
  ///
  /// Parameters:
  /// - invoiceId: ID invoice dari Xendit
  ///
  /// Returns: XenditInvoiceModel dengan status terbaru
  Future<XenditInvoiceModel> getInvoice(String invoiceId) async {
    try {
      final url = Uri.parse('$_baseUrl/invoices/$invoiceId');
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}';

      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return XenditInvoiceModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Gagal mendapatkan invoice: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error saat mendapatkan invoice Xendit: $e');
    }
  }

  /// Membatalkan invoice
  ///
  /// Parameters:
  /// - invoiceId: ID invoice dari Xendit
  Future<void> expireInvoice(String invoiceId) async {
    try {
      final url = Uri.parse('$_baseUrl/invoices/$invoiceId/expire!');
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}';

      final response = await http.post(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal membatalkan invoice: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error saat membatalkan invoice Xendit: $e');
    }
  }

  /// Create Invoice with Fixed Virtual Account
  ///
  /// Parameters:
  /// - externalId: Unique ID for this invoice
  /// - bankCode: Bank code (BCA, BNI, MANDIRI, BRI, PERMATA)
  /// - amount: Payment amount
  /// - payerEmail: Customer email
  /// - description: Payment description
  /// - items: Invoice items
  Future<XenditInvoiceModel> createInvoiceWithFixedVA({
    required String externalId,
    required String bankCode,
    required int amount,
    required String payerEmail,
    required String description,
    List<XenditInvoiceItem>? items,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/v2/invoices');
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}';

      if (!XenditConfig.isConfigured) {
        throw Exception(XenditConfig.configurationError);
      }

      final body = {
        'external_id': externalId,
        'amount': amount,
        'payer_email': payerEmail,
        'description': description,
        'invoice_duration': XenditConfig.invoiceDuration,
        'currency': XenditConfig.currency,
        'fixed_va': true, // Enable fixed VA
        'should_send_email': false,
        'payment_methods': [bankCode], // Specific bank only
        if (items != null && items.isNotEmpty)
          'items': items.map((item) => item.toJson()).toList(),
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return XenditInvoiceModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Gagal membuat invoice: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error saat membuat invoice: $e');
    }
  }

  /// Mapping status Xendit ke status internal aplikasi
  ///
  /// Xendit status:
  /// - PENDING: Menunggu pembayaran
  /// - PAID: Sudah dibayar
  /// - EXPIRED: Kadaluarsa
  /// - SETTLED: Pembayaran sudah diselesaikan
  String mapXenditStatusToAppStatus(String xenditStatus) {
    switch (xenditStatus.toUpperCase()) {
      case 'PAID':
      case 'SETTLED':
      case 'ACTIVE':
        return 'paid';
      case 'EXPIRED':
      case 'INACTIVE':
        return 'expired';
      case 'PENDING':
      default:
        return 'pending';
    }
  }
}
