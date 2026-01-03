import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingDataSource {
  final _db = FirebaseFirestore.instance;

  Stream<List<BookingModel>> getUserBookings(String uid) {
    return _db
        .collection("bookings")
        .where("userId", isEqualTo: uid)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => BookingModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> createBooking(BookingModel model) async {
    await _db.collection("bookings").doc(model.bookingId).set(model.toMap());
  }

  Future<void> updatePaymentStatus(String id, String status) async {
    await _db.collection("bookings").doc(id).update({"paymentStatus": status});
  }

  Future<void> updatePaymentSuccess({
    required String bookingId,
    required String paymentMethod,
    required DateTime paidAt,
  }) async {
    await _db.collection("bookings").doc(bookingId).update({
      "paymentStatus": "paid",
      "paymentMethod": paymentMethod,
      "paidAt": paidAt.toIso8601String(),
    });
  }

  Future<List<BookingModel>> getBookingsByInvoice({
    required String userId,
    required String invoiceId,
  }) async {
    final snap = await _db
        .collection("bookings")
        .where("userId", isEqualTo: userId)
        .where("xenditInvoiceId", isEqualTo: invoiceId)
        .get();

    return snap.docs.map((d) => BookingModel.fromMap(d.data())).toList();
  }
}
