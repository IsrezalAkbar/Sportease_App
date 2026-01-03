class BookingModel {
  final String bookingId;
  final String userId;
  final String fieldId;
  final String dateKey; // yyyy-MM-dd for fast queries
  final DateTime date;
  final String time;
  final int price;
  final String paymentStatus;
  final DateTime? createdAt;
  final DateTime? holdExpiresAt;
  final String? xenditInvoiceId;
  final String? xenditInvoiceUrl;
  final String? paymentMethod;
  final DateTime? paidAt;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.fieldId,
    required this.dateKey,
    required this.date,
    required this.time,
    required this.price,
    required this.paymentStatus,
    this.createdAt,
    this.holdExpiresAt,
    this.xenditInvoiceId,
    this.xenditInvoiceUrl,
    this.paymentMethod,
    this.paidAt,
  });

  Map<String, dynamic> toMap() => {
    "bookingId": bookingId,
    "userId": userId,
    "fieldId": fieldId,
    "dateKey": dateKey,
    "date": date.toIso8601String(),
    "time": time,
    "price": price,
    "paymentStatus": paymentStatus,
    if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
    if (holdExpiresAt != null)
      "holdExpiresAt": holdExpiresAt!.toIso8601String(),
    if (xenditInvoiceId != null) "xenditInvoiceId": xenditInvoiceId,
    if (xenditInvoiceUrl != null) "xenditInvoiceUrl": xenditInvoiceUrl,
    if (paymentMethod != null) "paymentMethod": paymentMethod,
    if (paidAt != null) "paidAt": paidAt!.toIso8601String(),
  };

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    bookingId: map["bookingId"],
    userId: map["userId"],
    fieldId: map["fieldId"],
    dateKey: map["dateKey"] ?? _buildDateKey(DateTime.parse(map["date"])),
    date: DateTime.parse(map["date"]),
    time: map["time"],
    price: map["price"],
    paymentStatus: map["paymentStatus"],
    createdAt: map["createdAt"] != null
        ? DateTime.parse(map["createdAt"])
        : null,
    holdExpiresAt: map["holdExpiresAt"] != null
        ? DateTime.parse(map["holdExpiresAt"])
        : null,
    xenditInvoiceId: map["xenditInvoiceId"],
    xenditInvoiceUrl: map["xenditInvoiceUrl"],
    paymentMethod: map["paymentMethod"],
    paidAt: map["paidAt"] != null ? DateTime.parse(map["paidAt"]) : null,
  );

  static String _buildDateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
