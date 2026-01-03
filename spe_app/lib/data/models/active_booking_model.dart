import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveBookingModel {
  final String bookingId;
  final String lapanganId; // fieldId
  final String userId;
  final DateTime startAt;
  final DateTime endAt;
  final String status; // 'active' | 'canceled' | ...
  final DateTime? createdAt;
  final String dateKey; // YYYY-MM-DD for efficient day queries

  const ActiveBookingModel({
    required this.bookingId,
    required this.lapanganId,
    required this.userId,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.dateKey,
    this.createdAt,
  });

  bool get isExpired => endAt.isBefore(DateTime.now());
  bool get isActiveNow => status == 'active' && !isExpired;

  Map<String, dynamic> toMap() => {
    'bookingId': bookingId,
    'lapanganId': lapanganId,
    'userId': userId,
    'startAt': Timestamp.fromDate(startAt),
    'endAt': Timestamp.fromDate(endAt),
    'status': status,
    'createdAt': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!),
    'dateKey': dateKey,
  };

  factory ActiveBookingModel.fromMap(Map<String, dynamic> map) {
    final startTs = map['startAt'] as Timestamp;
    final endTs = map['endAt'] as Timestamp;
    final created = map['createdAt'];
    return ActiveBookingModel(
      bookingId: map['bookingId'] as String,
      lapanganId: map['lapanganId'] as String,
      userId: map['userId'] as String,
      startAt: startTs.toDate(),
      endAt: endTs.toDate(),
      status: map['status'] as String,
      dateKey: map['dateKey'] as String,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  static String buildDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
