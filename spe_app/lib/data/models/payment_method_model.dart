/// Model untuk metode pembayaran yang didukung Xendit
class PaymentMethod {
  final String id;
  final String name;
  final String displayName;
  final String? icon; // Asset path untuk icon
  final String description;
  final String xenditCode; // Kode yang dikirim ke Xendit API
  final bool isActive;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.displayName,
    this.icon,
    required this.description,
    required this.xenditCode,
    this.isActive = true,
  });
}

/// List metode pembayaran yang didukung
class PaymentMethods {
  // E-Wallet
  static const goPay = PaymentMethod(
    id: 'gopay',
    name: 'GoPay',
    displayName: 'GoPay',
    description: 'Pembayaran dengan GoPay',
    xenditCode: 'GOPAY',
  );

  static const ovo = PaymentMethod(
    id: 'ovo',
    name: 'OVO',
    displayName: 'OVO',
    description: 'Pembayaran dengan OVO',
    xenditCode: 'OVO',
  );

  static const dana = PaymentMethod(
    id: 'dana',
    name: 'DANA',
    displayName: 'DANA',
    description: 'Pembayaran dengan DANA',
    xenditCode: 'DANA',
  );

  static const linkAja = PaymentMethod(
    id: 'link_aja',
    name: 'LinkAja',
    displayName: 'LinkAja',
    description: 'Pembayaran dengan LinkAja',
    xenditCode: 'LINKAJA',
  );

  static const shopeePay = PaymentMethod(
    id: 'shopee_pay',
    name: 'ShopeePay',
    displayName: 'ShopeePay',
    description: 'Pembayaran dengan ShopeePay',
    xenditCode: 'SHOPEEPAY',
  );

  // Bank Virtual Account
  static const bca = PaymentMethod(
    id: 'bca',
    name: 'BCA Virtual Account',
    displayName: 'BCA',
    description: 'Transfer ke Virtual Account BCA',
    xenditCode: 'BCA',
  );

  static const bni = PaymentMethod(
    id: 'bni',
    name: 'BNI Virtual Account',
    displayName: 'BNI',
    description: 'Transfer ke Virtual Account BNI',
    xenditCode: 'BNI',
  );

  static const mandiri = PaymentMethod(
    id: 'mandiri',
    name: 'Mandiri Virtual Account',
    displayName: 'Mandiri',
    description: 'Transfer ke Virtual Account Mandiri',
    xenditCode: 'MANDIRI',
  );

  static const bri = PaymentMethod(
    id: 'bri',
    name: 'BRI Virtual Account',
    displayName: 'BRI',
    description: 'Transfer ke Virtual Account BRI',
    xenditCode: 'BRI',
  );

  static const permata = PaymentMethod(
    id: 'permata',
    name: 'Permata Virtual Account',
    displayName: 'Permata',
    description: 'Transfer ke Virtual Account Permata',
    xenditCode: 'PERMATA',
  );

  // Retail Outlet
  static const alfamart = PaymentMethod(
    id: 'alfamart',
    name: 'Alfamart',
    displayName: 'Alfamart',
    description: 'Bayar di Alfamart',
    xenditCode: 'ALFAMART',
  );

  static const indomaret = PaymentMethod(
    id: 'indomaret',
    name: 'Indomaret',
    displayName: 'Indomaret',
    description: 'Bayar di Indomaret',
    xenditCode: 'INDOMARET',
  );

  // QRIS
  static const qris = PaymentMethod(
    id: 'qris',
    name: 'QRIS',
    displayName: 'QRIS',
    description: 'Scan QRIS dengan e-wallet atau app bank',
    xenditCode: 'QRIS',
  );

  // Kartu Kredit
  static const creditCard = PaymentMethod(
    id: 'credit_card',
    name: 'Kartu Kredit',
    displayName: 'Kartu Kredit',
    description: 'Pembayaran dengan Kartu Kredit/Debit',
    xenditCode: 'CREDIT_CARD',
  );

  // List semua metode pembayaran
  static const List<PaymentMethod> all = [
    // E-Wallet
    goPay,
    ovo,
    dana,
    linkAja,
    shopeePay,
    // Bank Virtual Account
    bca,
    bni,
    mandiri,
    bri,
    permata,
    // Retail
    alfamart,
    indomaret,
    // QRIS
    qris,
    // Kartu Kredit
    creditCard,
  ];

  // Metode pembayaran yang di-highlight (popular)
  static const List<PaymentMethod> popular = [
    goPay,
    ovo,
    dana,
    bni,
    mandiri,
    alfamart,
    shopeePay,
    qris,
    creditCard,
  ];

  // E-Wallet methods
  static const List<PaymentMethod> eWallets = [
    goPay,
    ovo,
    dana,
    linkAja,
    shopeePay,
  ];

  // Bank Virtual Account methods
  static const List<PaymentMethod> banks = [bca, bni, mandiri, bri, permata];

  // Retail methods
  static const List<PaymentMethod> retail = [alfamart, indomaret];
}
