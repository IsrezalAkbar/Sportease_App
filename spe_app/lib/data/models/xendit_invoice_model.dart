class XenditInvoiceModel {
  final String? id;
  final String? externalId;
  final String? userId;
  final String status;
  final String? merchantName;
  final int amount;
  final String? payerEmail;
  final String? description;
  final String? invoiceUrl;
  final String? expiryDate;
  final List<XenditInvoiceItem>? items;
  final List<XenditAvailableBank>? availableBanks;
  final DateTime? created;
  final DateTime? updated;

  XenditInvoiceModel({
    this.id,
    this.externalId,
    this.userId,
    required this.status,
    this.merchantName,
    required this.amount,
    this.payerEmail,
    this.description,
    this.invoiceUrl,
    this.expiryDate,
    this.items,
    this.availableBanks,
    this.created,
    this.updated,
  });

  factory XenditInvoiceModel.fromJson(Map<String, dynamic> json) {
    return XenditInvoiceModel(
      id: json['id'] as String?,
      externalId: json['external_id'] as String?,
      userId: json['user_id'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      merchantName: json['merchant_name'] as String?,
      amount: json['amount'] as int? ?? 0,
      payerEmail: json['payer_email'] as String?,
      description: json['description'] as String?,
      invoiceUrl: json['invoice_url'] as String?,
      expiryDate: json['expiry_date'] as String?,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => XenditInvoiceItem.fromJson(item))
                .toList()
          : null,
      availableBanks: json['available_banks'] != null
          ? (json['available_banks'] as List)
                .map((b) => XenditAvailableBank.fromJson(b))
                .toList()
          : null,
      created: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : null,
      updated: json['updated'] != null
          ? DateTime.parse(json['updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (userId != null) 'user_id': userId,
      'status': status,
      if (merchantName != null) 'merchant_name': merchantName,
      'amount': amount,
      if (payerEmail != null) 'payer_email': payerEmail,
      if (description != null) 'description': description,
      if (invoiceUrl != null) 'invoice_url': invoiceUrl,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (availableBanks != null)
        'available_banks': availableBanks!.map((b) => b.toJson()).toList(),
      if (created != null) 'created': created!.toIso8601String(),
      if (updated != null) 'updated': updated!.toIso8601String(),
    };
  }
}

class XenditInvoiceItem {
  final String name;
  final int quantity;
  final int price;

  XenditInvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory XenditInvoiceItem.fromJson(Map<String, dynamic> json) {
    return XenditInvoiceItem(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: json['price'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'price': price};
  }
}

class XenditAvailableBank {
  final String bankCode;
  final String? accountNumber;

  XenditAvailableBank({required this.bankCode, this.accountNumber});

  factory XenditAvailableBank.fromJson(Map<String, dynamic> json) {
    return XenditAvailableBank(
      bankCode: json['bank_code'] as String? ?? '',
      accountNumber: json['account_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_code': bankCode,
      if (accountNumber != null) 'account_number': accountNumber,
    };
  }
}
